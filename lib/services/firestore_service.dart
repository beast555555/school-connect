import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/attendance_record.dart';
import '../models/fee_record.dart';
import '../models/homework.dart';
import '../models/notice_model.dart';
import '../models/student_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser?.uid ?? '';

  // =========================
  // STUDENT MASTER
  // =========================

  Future<String?> addStudent({
    required String name,
    required String className,
    required String rollNo,
    String? studentAuthUid,
  }) async {
    try {
      final student = StudentModel(
        id: '',
        name: name.trim(),
        className: className.trim(),
        rollNo: rollNo.trim(),
        studentAuthUid: studentAuthUid?.trim().isEmpty == true
            ? null
            : studentAuthUid?.trim(),
        isActive: true,
        createdBy: currentUid,
      );

      await _firestore.collection('students').add(student.toMap());

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<StudentModel>> getAllStudents() {
    return _firestore.collection('students').snapshots().map((snapshot) {
      final students =
          snapshot.docs.map((doc) => StudentModel.fromDoc(doc)).toList();

      students.removeWhere((student) => student.isActive == false);

      students.sort((a, b) {
        final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });

      return students;
    });
  }

  Stream<List<StudentModel>> getStudentsByClass(String className) {
    return _firestore.collection('students').snapshots().map((snapshot) {
      final students =
          snapshot.docs.map((doc) => StudentModel.fromDoc(doc)).toList();

      final filtered = students.where((student) {
        return student.isActive == true &&
            student.className.toLowerCase() == className.toLowerCase();
      }).toList();

      filtered.sort((a, b) {
        final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });

      return filtered;
    });
  }

  // =========================
  // HOMEWORK
  // =========================

  Future<String?> addHomework({
    required String title,
    required String subject,
    required String description,
    required String dueDate,
    required String className,
  }) async {
    try {
      final homework = Homework(
        id: '',
        title: title.trim(),
        subject: subject.trim(),
        description: description.trim(),
        dueDate: dueDate.trim(),
        className: className.trim(),
        createdBy: currentUid,
      );

      await _firestore.collection('homework').add(homework.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<Homework>> getAllHomework() {
    return _firestore.collection('homework').snapshots().map((snapshot) {
      final items = snapshot.docs.map((doc) => Homework.fromDoc(doc)).toList();

      items.sort((a, b) {
        final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });

      return items;
    });
  }

  Stream<List<Homework>> getHomeworkForStudent(String className) {
    return _firestore.collection('homework').snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => Homework.fromDoc(doc))
          .where(
            (item) => item.className.toLowerCase() == className.toLowerCase(),
          )
          .toList();

      items.sort((a, b) {
        final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });

      return items;
    });
  }

  Future<void> deleteHomework(String homeworkId) async {
    await _firestore.collection('homework').doc(homeworkId).delete();
  }

  // =========================
  // NOTICES
  // =========================

  Future<String?> addNotice({
    required String title,
    required String message,
    required String targetClass,
  }) async {
    try {
      final notice = NoticeModel(
        id: '',
        title: title.trim(),
        message: message.trim(),
        targetClass: targetClass.trim(),
        createdBy: currentUid,
      );

      await _firestore.collection('notices').add(notice.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<NoticeModel>> getAllNotices() {
    return _firestore.collection('notices').snapshots().map((snapshot) {
      final items =
          snapshot.docs.map((doc) => NoticeModel.fromDoc(doc)).toList();

      items.sort((a, b) {
        final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });

      return items;
    });
  }

  Stream<List<NoticeModel>> getNoticesForStudent(String className) {
    return _firestore.collection('notices').snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => NoticeModel.fromDoc(doc))
          .where(
            (item) => item.targetClass.toLowerCase() == className.toLowerCase(),
          )
          .toList();

      items.sort((a, b) {
        final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });

      return items;
    });
  }

  Future<void> deleteNotice(String noticeId) async {
    await _firestore.collection('notices').doc(noticeId).delete();
  }

  // =========================
  // ATTENDANCE
  // =========================

  Future<String?> markAttendance({
    required StudentModel student,
    required String status,
    required String date,
  }) async {
    try {
      final attendance = AttendanceRecord(
        id: '',
        studentId: student.id,
        studentAuthUid: student.studentAuthUid,
        studentName: student.name,
        className: student.className,
        status: status.trim(),
        date: date.trim(),
        markedBy: currentUid,
      );

      await _firestore.collection('attendance').add(attendance.toMap());

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<AttendanceRecord>> getAllAttendance() {
    return _firestore.collection('attendance').snapshots().map((snapshot) {
      final items =
          snapshot.docs.map((doc) => AttendanceRecord.fromDoc(doc)).toList();

      items.sort((a, b) {
        final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });

      return items;
    });
  }

  Stream<List<AttendanceRecord>> getMyAttendance() async* {
    final uid = currentUid;

    if (uid.isEmpty) {
      yield [];
      return;
    }

    try {
      yield* _firestore
          .collection('attendance')
          .where('studentAuthUid', isEqualTo: uid)
          .snapshots()
          .map((snapshot) {
        final items = snapshot.docs
            .map((doc) => AttendanceRecord.fromDoc(doc))
            .toList();

        items.sort((a, b) {
          final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
          final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
          return bTime.compareTo(aTime);
        });

        return items;
      });
    } catch (e) {
      debugPrint('getMyAttendance error: $e');
      yield [];
    }
  }

  // =========================
  // FEES
  // =========================

  Future<String?> upsertFees({
    required StudentModel student,
    required double totalFees,
    required double paidFees,
    required String dueDate,
  }) async {
    try {
      final pendingFees = totalFees - paidFees;

      final fees = FeeRecord(
        studentId: student.id,
        studentAuthUid: student.studentAuthUid,
        studentName: student.name,
        className: student.className,
        totalFees: totalFees,
        paidFees: paidFees,
        pendingFees: pendingFees,
        dueDate: dueDate.trim(),
        status: pendingFees <= 0 ? 'Paid' : 'Pending',
        updatedBy: currentUid,
      );

      await _firestore.collection('fees').doc(student.id).set(
            fees.toMap(),
            SetOptions(merge: true),
          );

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<FeeRecord>> getAllFees() {
    return _firestore.collection('fees').snapshots().map((snapshot) {
      final items = snapshot.docs.map((doc) => FeeRecord.fromDoc(doc)).toList();

      items.sort((a, b) {
        final aTime = a.updatedAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.updatedAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });

      return items;
    });
  }

  Stream<FeeRecord?> getMyFees() async* {
  final uid = currentUid;

  if (uid.isEmpty) {
    yield null;
    return;
  }

  try {
    final userDoc = await _firestore.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      yield null;
      return;
    }

    final userData = userDoc.data() ?? {};
    final studentDocId = (userData['studentDocId'] ?? '').toString().trim();

    if (studentDocId.isEmpty) {
      yield null;
      return;
    }

    // READ ONLY. DO NOT UPDATE ANYTHING HERE.
    yield* _firestore.collection('fees').doc(studentDocId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return FeeRecord.fromDoc(doc);
    });
  } catch (e) {
    debugPrint('getMyFees error: $e');
    rethrow;
  }
}
}