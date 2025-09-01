import 'package:basic_flutter/email_verify.dart';
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
      routes: {
        '/login/': (context) => const LoginView(),
        '/home/': (context) => const Homepage(),
        '/register/': (context) => const Register(),
        '/e_verify/': (context) => const VerifyEmail(),
      },
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
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text("Please verify your email"),
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/e_verify/', (route) => false);
                    },
                    child: const Text("Go to Email Verification"),
                  ),
                ],
              );
            }

            // Navigator.of(context).push(
            //   MaterialPageRoute(builder: (context) => const VerifyEmail()),
            // );
          } else {
            return Text('Loading');
          }
        },
      ),
    );
  }
}
