import 'package:flutter/material.dart';
import '../../models/student_model.dart';
import '../teacher/mark_attendance_screen.dart';
import 'fees_screen.dart';

class StudentActionsScreen extends StatelessWidget {
  final StudentModel student;

  const StudentActionsScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final isLinked = (student.studentAuthUid ?? '').trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(student.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.indigo.withOpacity(0.12)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.indigo.withOpacity(0.12),
                    child: const Icon(
                      Icons.person,
                      color: Colors.indigo,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    student.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Class: ${student.className}',
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Roll No: ${student.rollNo}',
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
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
            const SizedBox(height: 24),

            // MARK ATTENDANCE
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.fact_check, color: Colors.white),
                label: const Text(
                  'Mark Attendance',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MarkAttendanceScreen(student: student),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // OPEN FEES MANAGEMENT
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                ),
                label: const Text(
                  'Open Fees Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FeesScreen(isTeacher: true),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Tip: Fees Management opens the full student fees list. '
                'You can select and update this student there.',
                style: TextStyle(fontSize: 12, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
