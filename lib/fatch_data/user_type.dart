import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> getUserType() async {
  final user = FirebaseAuth.instance.currentUser;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .get();

  return doc['userType'] as String;
}
