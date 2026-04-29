import 'package:cloud_firestore/cloud_firestore.dart';

class Homework {
  final String id;
  final String title;
  final String subject;
  final String description;
  final String dueDate;
  final String className;
  final String createdBy;
  final Timestamp? createdAt;

  Homework({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.dueDate,
    required this.className,
    required this.createdBy,
    this.createdAt,
  });

  factory Homework.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Homework(
      id: doc.id,
      title: data['title'] ?? '',
      subject: data['subject'] ?? '',
      description: data['description'] ?? '',
      dueDate: data['dueDate'] ?? '',
      className: data['className'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subject': subject,
      'description': description,
      'dueDate': dueDate,
      'className': className,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}