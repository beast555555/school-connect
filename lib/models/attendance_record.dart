import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String id;
  final String studentId; // student master doc id
  final String? studentAuthUid; // login uid if linked
  final String studentName;
  final String className;
  final String status;
  final String date;
  final String markedBy;
  final Timestamp? createdAt;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    this.studentAuthUid,
    required this.studentName,
    required this.className,
    required this.status,
    required this.date,
    required this.markedBy,
    this.createdAt,
  });

  factory AttendanceRecord.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AttendanceRecord(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentAuthUid: data['studentAuthUid'],
      studentName: data['studentName'] ?? '',
      className: data['className'] ?? '',
      status: data['status'] ?? '',
      date: data['date'] ?? '',
      markedBy: data['markedBy'] ?? '',
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentAuthUid': studentAuthUid,
      'studentName': studentName,
      'className': className,
      'status': status,
      'date': date,
      'markedBy': markedBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}