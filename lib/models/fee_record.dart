import 'package:cloud_firestore/cloud_firestore.dart';

class FeeRecord {
  final String studentId; // student master doc id
  final String? studentAuthUid; // login uid if linked
  final String studentName;
  final String className;
  final double totalFees;
  final double paidFees;
  final double pendingFees;
  final String dueDate;
  final String status;
  final String updatedBy;
  final Timestamp? updatedAt;

  FeeRecord({
    required this.studentId,
    this.studentAuthUid,
    required this.studentName,
    required this.className,
    required this.totalFees,
    required this.paidFees,
    required this.pendingFees,
    required this.dueDate,
    required this.status,
    required this.updatedBy,
    this.updatedAt,
  });

  factory FeeRecord.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FeeRecord(
      studentId: data['studentId'] ?? doc.id,
      studentAuthUid: data['studentAuthUid'],
      studentName: data['studentName'] ?? '',
      className: data['className'] ?? '',
      totalFees: (data['totalFees'] ?? 0).toDouble(),
      paidFees: (data['paidFees'] ?? 0).toDouble(),
      pendingFees: (data['pendingFees'] ?? 0).toDouble(),
      dueDate: data['dueDate'] ?? '',
      status: data['status'] ?? '',
      updatedBy: data['updatedBy'] ?? '',
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentAuthUid': studentAuthUid,
      'studentName': studentName,
      'className': className,
      'totalFees': totalFees,
      'paidFees': paidFees,
      'pendingFees': pendingFees,
      'dueDate': dueDate,
      'status': status,
      'updatedBy': updatedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}