import 'package:flutter/material.dart';
import '../../models/attendance_record.dart';
import '../../models/student_model.dart';
import '../../services/firestore_service.dart';

class AttendanceListScreen extends StatefulWidget {
  final bool isTeacher;

  const AttendanceListScreen({
    super.key,
    required this.isTeacher,
  });

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    if (widget.isTeacher) {
      return _buildTeacherView();
    } else {
      return _buildStudentView();
    }
  }

  // =========================
  // STUDENT VIEW
  // =========================

  Widget _buildStudentView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
      ),
      body: StreamBuilder<List<AttendanceRecord>>(
        stream: _firestoreService.getMyAttendance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return const Center(
              child: Text(
                'No attendance records found',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final isPresent = record.status.toLowerCase() == 'present';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: isPresent
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    child: Icon(
                      isPresent ? Icons.check : Icons.close,
                      color: isPresent ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(record.date),
                  subtitle: Text('Status: ${record.status}'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // =========================
  // TEACHER / ADMIN VIEW
  // =========================

  Widget _buildTeacherView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Management'),
      ),
      body: StreamBuilder<List<StudentModel>>(
        stream: _firestoreService.getAllStudents(),
        builder: (context, studentSnapshot) {
          if (studentSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (studentSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error: ${studentSnapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final students = studentSnapshot.data ?? [];

          if (students.isEmpty) {
            return const Center(
              child: Text(
                'No students found.\nAdd student master records first.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.withOpacity(0.15),
                    child: const Icon(Icons.person, color: Colors.indigo),
                  ),
                  title: Text(student.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text('Class: ${student.className}'),
                      Text('Roll No: ${student.rollNo}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      final result = await _firestoreService.markAttendance(
                        student: student,
                        status: value,
                        date: DateTime.now().toString().split(' ').first,
                      );

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result ?? 'Attendance marked successfully',
                          ),
                        ),
                      );
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'Present',
                        child: Text('Mark Present'),
                      ),
                      PopupMenuItem(
                        value: 'Absent',
                        child: Text('Mark Absent'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}