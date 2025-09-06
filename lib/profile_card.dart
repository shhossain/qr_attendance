import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String studentId;
  final String section;
  final bool verified;

  const ProfileCard({
    super.key,
    required this.name,
    required this.studentId,
    required this.section,
    required this.verified,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Student ID
            Text(
              "ID: $studentId",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 4),

            // Section
            Text(
              "Section: $section",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            // Verified Status
            Row(
              children: [
                Icon(
                  verified ? Icons.verified : Icons.warning_amber_rounded,
                  color: verified ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  verified ? "University Verified" : "University not verified",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: verified ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
