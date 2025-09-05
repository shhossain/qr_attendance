import 'package:basic_flutter/email_verify.dart';
import 'package:basic_flutter/firebase_options.dart';
import 'package:basic_flutter/login_view.dart';
import 'package:basic_flutter/register_page.dart';
import 'package:basic_flutter/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

void main() {
  runApp(
    MaterialApp(
      title: 'Naimul',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 12, 26, 186),
        ),
      ),
      home: Homepage(),
      routes: {
        login: (context) => const LoginView(),
        home: (context) => const Homepage(),
        register: (context) => const Register(),
        verify: (context) => const VerifyEmail(),
      },
    ),
  );
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection("users").doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 161, 115),
        title: const Text('Home Page'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'login') {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(login, (route) => false);
              } else if (value == 'register') {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(register, (route) => false);
              } else if (value == 'logout') {
                final logout = await showLogout(context);
                devtools.log(logout.toString());
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(value: 'login', child: Text('Login')),
                const PopupMenuItem(value: 'register', child: Text('Register')),
                const PopupMenuItem(value: 'logout', child: Text('Log out')),
              ];
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final user = FirebaseAuth.instance.currentUser;

            if (user?.emailVerified ?? false) {
              // ✅ Fetch Firestore user data
              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text("No user data found"));
                  }

                  final userData = snapshot.data!.data()!;
                  final name = userData['name'] ?? '';
                  final userType = userData['userType'] ?? '';
                  final section = userData['section'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome, $name 👋",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text("User Type: $userType"),
                        if (userType == "Student") 
                              Text("Section: $section"),
                        if (userType == "Teacher")
                          Text("Designation: $section"),
                      ],
                    ),
                  );
                },
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text("Please verify your email"),
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil(verify, (route) => false);
                    },
                    child: const Text("Go to Email Verification"),
                  ),
                ],
              );
            }
          } else {
            return const Center(child: Text('Loading...'));
          }
        },
      ),
    );
  }
}

Future<bool> showLogout(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login/', (route) => false);
            },
            child: const Text('Log out'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
