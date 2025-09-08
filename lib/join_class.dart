import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinClassPage extends StatefulWidget {
  const JoinClassPage({super.key});

  @override
  State<JoinClassPage> createState() => _JoinClassPageState();
}

class _JoinClassPageState extends State<JoinClassPage> {
  final TextEditingController _section = TextEditingController();
  final TextEditingController _code = TextEditingController();

  void _joinClass() async {
    final studentId = FirebaseAuth.instance.currentUser!.uid;
    final section = _section.text.trim();
    final code = _code.text.trim();

    if (section.isEmpty || code.isEmpty) {
      _showMessage("Both Section and Code are required");
      return;
    }

    // Search class in all teachers
    final teacherSnapshot = await FirebaseFirestore.instance.collection('teachers').get();
    bool joined = false;

    for (var teacherDoc in teacherSnapshot.docs) {
      final classesSnapshot = await teacherDoc.reference.collection('classes').get();
      for (var classDoc in classesSnapshot.docs) {
        final data = classDoc.data();
        if (data['section'] == section && data['code'] == code) {
          // Add to student's joinedClasses
          await FirebaseFirestore.instance
              .collection('students')
              .doc(studentId)
              .collection('joinedClasses')
              .doc(classDoc.id)
              .set({
            'teacherId': teacherDoc.id,
            'name': data['name'],
            'dept': data['dept'],
            'section': data['section'],
          });

          joined = true;
          _showMessage("Class Joined Successfully");
          break;
        }
      }
      if (joined) break;
    }

    if (!joined) {
      _showMessage("No class found with this Section & Code");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Join Class")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _section, decoration: const InputDecoration(labelText: "Section")),
            TextField(controller: _code, decoration: const InputDecoration(labelText: "Class Code")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _joinClass,
              child: const Text("Join Class"),
            ),
          ],
        ),
      ),
    );
  }
}
