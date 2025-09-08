import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Generate a unique 6-digit class code globally and per-user
Future<String> generateUniqueClassCode() async {
  final rnd = Random();
  const int maxAttempts = 100; // safety limit
  int attempts = 0;

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("User not logged in");

  final userClasses = FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .collection("classes");

  final globalClasses = FirebaseFirestore.instance
      .collection("global")
      .doc("classes")
      .collection("allClasses");

  String code = "";

  while (true) {
    if (attempts >= maxAttempts) {
      throw Exception("Unable to generate unique class code. Try again.");
    }

    code = (100000 + rnd.nextInt(900000)).toString();

    final userSnap = await userClasses.doc(code).get();
    final globalSnap = await globalClasses.doc(code).get();

    attempts++;

    if (!userSnap.exists && !globalSnap.exists) {
      break;
    }
  }

  return code;
}
