import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String id;
  final String name;
  final String className;
  final String rollNo;
  final String? studentAuthUid;
  final bool isActive;
  final String createdBy;
  final Timestamp? createdAt;

  StudentModel({
    required this.id,
    required this.name,
    required this.className,
    required this.rollNo,
    this.studentAuthUid,
    required this.isActive,
    required this.createdBy,
    this.createdAt,
  });

  factory StudentModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return StudentModel(
      id: doc.id,
      name: data['name'] ?? '',
      className: data['className'] ?? '',
      rollNo: data['rollNo'] ?? '',
      studentAuthUid: data['studentAuthUid'],
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'className': className,
      'rollNo': rollNo,
      'studentAuthUid': studentAuthUid,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}