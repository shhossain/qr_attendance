import 'package:basic_flutter/firebase_options.dart';
import 'package:basic_flutter/login_view.dart';
import 'package:basic_flutter/register_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Naimul',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 12, 26, 186),
        ),
      ),
      home: const Homepage(),
    ),
  );
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 242, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 189, 193, 245),
        title: const Text('Home Page'),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final user = FirebaseAuth.instance.currentUser;

            if (user?.emailVerified ?? false) {
              return Text('verified');
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const VerifyEmail()),
              );
              return Text('Done');
            }
          } else {
            return Text('Loading');
          }
        },
      ),
    );
  }
}

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify email')),
      body: Column(
        children: [
          Text('Please verify your email'),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();
            },
            child: Text('Send email verification'),
          ),
        ],
      ),
    );
  }
}
