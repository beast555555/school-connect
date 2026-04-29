import 'package:flutter/material.dart';
import '../../models/student_model.dart';
import '../../services/firestore_service.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final StudentModel student;

  const MarkAttendanceScreen({
    super.key,
    required this.student,
  });

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController dateController = TextEditingController();
  String selectedStatus = 'Present';
  bool isLoading = false;

  Future<void> saveAttendance() async {
    if (dateController.text.trim().isEmpty) {
      showMessage('Please enter date');
      return;
    }

    setState(() => isLoading = true);

    final result = await _firestoreService.markAttendance(
      student: widget.student,
      status: selectedStatus,
      date: dateController.text,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (result != null) {
      showMessage(result);
      return;
    }

    showMessage('Attendance saved successfully');
    Navigator.pop(context);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance • ${widget.student.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${widget.student.name}\nClass: ${widget.student.className} • Roll: ${widget.student.rollNo}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Date (Example: 23 Apr 2026)',
                prefixIcon: const Icon(Icons.date_range),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                prefixIcon: const Icon(Icons.fact_check),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Present',
                  child: Text('Present'),
                ),
                DropdownMenuItem(
                  value: 'Absent',
                  child: Text('Absent'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedStatus = value);
                }
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Attendance',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}