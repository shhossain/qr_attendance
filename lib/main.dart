import 'package:basic_flutter/login_page.dart';
import 'package:basic_flutter/register_page.dart';
import 'package:basic_flutter/routes.dart';
import 'package:basic_flutter/student_profile.dart';
import 'package:basic_flutter/teacher_profile.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Naimul',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 19, 2, 99),
        ),
      ),
      home: TeacherProfile(),
      routes: {
        login: (context) => const Login(),
        register: (context) => const Register(),
        student: (context) => StudentProfile(),
        teacher: (context) => const TeacherProfile(),
      },
    ),
  );
}
