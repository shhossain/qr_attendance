import 'dart:math';
import 'package:basic_flutter/sub_pages/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sub_pages/routes.dart';

class CreateClassPage extends StatefulWidget {
  const CreateClassPage({super.key});

  @override
  State<CreateClassPage> createState() => _CreateClassPageState();
}

class _CreateClassPageState extends State<CreateClassPage> {
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  TimeOfDay? _classStartTime;
  bool _isLoading = false;

  /// Generate 5-digit unique code
  String _generateClassCode() {
    final rnd = Random();
    return (10000 + rnd.nextInt(90000)).toString();
  }

  Future<void> _createClass() async {
    final className = _classNameController.text.trim();
    final section = _sectionController.text.trim();

    if (className.isEmpty || section.isEmpty || _classStartTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      String classCode = _generateClassCode();

      // Ensure uniqueness by checking Firestore
      final userClasses = FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("classes");

      final snapshot = await userClasses.doc(classCode).get();
      if (snapshot.exists) {
        // Regenerate if already exists
        classCode = _generateClassCode();
      }

      final classDoc = userClasses.doc(classCode);

      await classDoc.set({
        "name": className,
        "section": section,
        "startTime": "${_classStartTime!.hour}:${_classStartTime!.minute}",
        "code": classCode,
      });

      // Success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Class created successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Go back to teacher profile immediately
      Navigator.of(context).pushNamedAndRemoveUntil(teacher, (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error creating class: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _classStartTime = time;
      });
    }
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _sectionController.dispose();
    super.dispose();
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
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 0, 161, 115),
            title: const Text("Create Class"),
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _classNameController,
                  decoration: const InputDecoration(
                    labelText: "Class Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _sectionController,
                  decoration: const InputDecoration(
                    labelText: "Section",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _pickStartTime,
                        child: Text(
                          _classStartTime == null
                              ? "Pick Class Start Time"
                              : "Start Time: ${_classStartTime!.format(context)}",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createClass,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 161, 115),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Create Class",
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
