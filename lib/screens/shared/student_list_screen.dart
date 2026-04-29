import 'package:flutter/material.dart';
import '../../models/student_model.dart';
import '../../services/firestore_service.dart';
import 'student_actions_screen.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
      ),
      body: StreamBuilder<List<StudentModel>>(
        stream: firestoreService.getAllStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final students = snapshot.data ?? [];

          if (students.isEmpty) {
            return const Center(
              child: Text(
                'No students found',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final isLinked =
                  (student.studentAuthUid ?? '').trim().isNotEmpty;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.indigo.withOpacity(0.15),
                    child: const Icon(
                      Icons.person,
                      color: Colors.indigo,
                    ),
                  ),
                  title: Text(
                    student.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Class: ${student.className}'),
                        const SizedBox(height: 4),
                        Text('Roll No: ${student.rollNo}'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isLinked
                                ? Colors.green.withOpacity(0.12)
                                : Colors.orange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isLinked ? 'Login Linked' : 'Login Not Linked',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isLinked ? Colors.green : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentActionsScreen(student: student),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}