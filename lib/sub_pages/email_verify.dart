import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmail extends StatefulWidget {
  final String email;
  const VerifyEmail({super.key, required this.email});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool _sent = false;
  bool _verified = false;
  String? _uid;

  Future<void> sendVerification() async {
    try {
      // Create user in Firebase temporarily with a random password
      final password = "123456";
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: widget.email,
            password: password,
          );

      _uid = userCredential.user!.uid;

      await userCredential.user!.sendEmailVerification();
      setState(() => _sent = true);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Verification email sent')));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) _uid = user.uid;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Email already in use')));
      }
    }
  }

  Future<void> checkVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    if (user?.emailVerified ?? false) {
      setState(() => _verified = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: const Color.fromARGB(255, 0, 161, 115),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Email: ${widget.email}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sent ? null : sendVerification,
              child: Text(_sent ? 'Email Sent' : 'Send Verification Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await checkVerified();
                if (_verified) {
                  Navigator.of(context).pop({'verified': true, 'uid': _uid});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email not verified yet')),
                  );
                }
              },
              child: const Text('Check Verification'),
            ),
          ],
        ),
      ),
    );
  }
}
