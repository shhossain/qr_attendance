import 'package:basic_flutter/login_page.dart';
import 'package:basic_flutter/register_page.dart';
import 'package:basic_flutter/sub_pages/firebase_options.dart';
import 'package:basic_flutter/sub_pages/routes.dart';
import 'package:basic_flutter/student_profile.dart';
import 'package:basic_flutter/teacher_profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getStartPage() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Login();
    }
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userType = doc['userType'];

    if (userType == 'student') {
      return const StudentProfile();
    } else {
      return const TeacherProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qr Attendance',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 19, 2, 99),
        ),
      ),
      routes: {
        login: (context) => const Login(),
        register: (context) => const Register(),
        student: (context) => const StudentProfile(),
        teacher: (context) => const TeacherProfile(),
      },

      home: FutureBuilder<Widget>(
        future: _getStartPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return snapshot.data!;
          }
          return const Login();
        },
      ),
    );
  }
}
