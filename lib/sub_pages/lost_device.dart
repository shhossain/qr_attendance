import 'package:basic_flutter/sub_pages/routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class LostDevice extends StatefulWidget {
  const LostDevice({super.key});

  @override
  State<LostDevice> createState() => _LostDeviceState();
}

class _LostDeviceState extends State<LostDevice> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id; // unique ID
  }

  Future<void> _login() async {
    final email = _email.text.trim();
    final password = _password.text.trim();

    try {
      final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user?.uid;
      if (uid == null) return;

      final newDeviceId = await _getDeviceId();
      final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

      final snapshot = await userDoc.get();
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final lastRequest = data["lostDeviceRequestedAt"] as Timestamp?;

      // cooldown check (only show date)
      final now = DateTime.now();
      if (lastRequest != null) {
        final nextAllowed = lastRequest.toDate().add(const Duration(days: 30));
        if (now.isBefore(nextAllowed)) {
          final formattedDate =
              "${nextAllowed.day}-${nextAllowed.month}-${nextAllowed.year}";
          _showError("You can change your device again after: $formattedDate");
          return;
        }
      }

      // confirmation popup
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Confirm Device Change"),
          content: const Text(
            "Same device can banned both account. Do you want to proceed?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Proceed"),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await userDoc.update({
          "DeviceId": newDeviceId,
          "lostDeviceRequestedAt": FieldValue.serverTimestamp(),
        });
        await FirebaseAuth.instance.signOut();

        // ✅ Success popup
        await showDialog(
          context: context,
          barrierDismissible: false, // must press OK
          builder: (ctx) => AlertDialog(
            title: const Text("Success"),
            content: const Text("Device change successful."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(login, (route) => false);
        }
      } else {
        await FirebaseAuth.instance.signOut();
      }
    } on FirebaseAuthException catch (e) {
      _showError("Login failed: ${e.message}");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 0, 161, 115),
            title: const Text("Lost Device"),
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    enableSuggestions: false,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 161, 115),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _login,
                      child: const Text("Change Device"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color.fromARGB(255, 0, 161, 115),
                          width: 2,
                        ),
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil(login, (route) => false);
                      },
                      child: const Text("Go to Login Page"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              "💡 Tip: Multiple attempts can lead to account lost or longer waiting time",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: const Color.fromARGB(255, 46, 45, 45),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      },
    );
  }
}
