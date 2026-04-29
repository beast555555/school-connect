import 'package:flutter/material.dart';
import '../../models/homework.dart';
import '../../services/firestore_service.dart';

class HomeworkListScreen extends StatelessWidget {
  final bool isTeacher;
  final String? studentClass;

  const HomeworkListScreen({
    super.key,
    required this.isTeacher,
    this.studentClass,
  });

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    final stream = isTeacher
        ? firestoreService.getAllHomework()
        : firestoreService.getHomeworkForStudent(studentClass ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework'),
      ),
      body: StreamBuilder<List<Homework>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          final homeworkList = snapshot.data ?? [];

          if (homeworkList.isEmpty) {
            return const Center(
              child: Text(
                'No homework found',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: homeworkList.length,
            itemBuilder: (context, index) {
              final homework = homeworkList[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    homework.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Subject: ${homework.subject}'),
                        const SizedBox(height: 4),
                        Text('Description: ${homework.description}'),
                        const SizedBox(height: 4),
                        Text('Due Date: ${homework.dueDate}'),
                        const SizedBox(height: 4),
                        Text('Class: ${homework.className}'),
                      ],
                    ),
                  ),
                  trailing: isTeacher
                      ? IconButton(
                          onPressed: () async {
                            await firestoreService.deleteHomework(homework.id);
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}