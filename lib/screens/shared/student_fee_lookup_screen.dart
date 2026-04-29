import 'package:flutter/material.dart';
import 'fees_screen.dart';

class StudentFeeLookupScreen extends StatelessWidget {
  const StudentFeeLookupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Fees'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.receipt_long),
              label: const Text('Open Fees Management'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FeesScreen(
                      isTeacher: true,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}