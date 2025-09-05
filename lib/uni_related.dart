import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String kBaseUrl = "http://10.0.2.2:5000";

class UniVerify extends StatefulWidget {
  const UniVerify({super.key});

  @override
  State<UniVerify> createState() => _UniVerifyState();
}

class _UniVerifyState extends State<UniVerify> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _verifyStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final uri = Uri.parse("$kBaseUrl/api/login");
      final resp = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userid": _idCtrl.text.trim(),
          "password": _pwCtrl.text,
        }),
      );

      final data = jsonDecode(resp.body);

      if (!mounted) return;

      if (resp.statusCode == 200 && data["ok"] == true) {
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Verified Student"),
            content: Text("Name: ${data['name']}\nID: ${data['sid']}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(
                  ctx,
                ).pop({'verified': true, 'sid': data['sid']}),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        Navigator.of(context).pop(result);
      } else {
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Verification Failed"),
            content: Text(
              data["error"] ?? "Verification failed (HTTP ${resp.statusCode})",
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(ctx).pop({'verified': false, 'sid': null}),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Network Error"),
          content: Text("Network error: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 161, 115),
        title: const Text(
          "University Verification",
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Image.asset("assets/su_logo.png", height: 200),
              const SizedBox(height: 30),

              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _idCtrl,
                      decoration: inputDecoration("Student ID"),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pwCtrl,
                      obscureText: true,
                      decoration: inputDecoration("University Password"),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "Required" : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _verifyStudent,
                        icon: _loading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.verified_user),
                        label: Text(
                          _loading ? "Verifying..." : "Verify Student",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            0,
                            161,
                            115,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                   
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
