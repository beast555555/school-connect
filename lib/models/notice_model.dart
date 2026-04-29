import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeModel {
  final String id;
  final String title;
  final String message;
  final String targetClass;
  final String createdBy;
  final Timestamp? createdAt;

  NoticeModel({
    required this.id,
    required this.title,
    required this.message,
    required this.targetClass,
    required this.createdBy,
    this.createdAt,
  });

  factory NoticeModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return NoticeModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      targetClass: data['targetClass'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'targetClass': targetClass,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}