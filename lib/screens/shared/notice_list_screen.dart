import 'package:flutter/material.dart';
import '../../models/notice_model.dart';
import '../../services/firestore_service.dart';

class NoticeListScreen extends StatelessWidget {
  final bool isTeacher;
  final String? studentClass;

  const NoticeListScreen({
    super.key,
    required this.isTeacher,
    this.studentClass,
  });

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    final stream = isTeacher
        ? firestoreService.getAllNotices()
        : firestoreService.getNoticesForStudent(studentClass ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notices'),
      ),
      body: StreamBuilder<List<NoticeModel>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          final noticeList = snapshot.data ?? [];

          if (noticeList.isEmpty) {
            return const Center(
              child: Text(
                'No notices found',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: noticeList.length,
            itemBuilder: (context, index) {
              final notice = noticeList[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    notice.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notice.message),
                        const SizedBox(height: 8),
                        Text('Target Class: ${notice.targetClass}'),
                      ],
                    ),
                  ),
                  trailing: isTeacher
                      ? IconButton(
                          onPressed: () async {
                            await firestoreService.deleteNotice(notice.id);
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