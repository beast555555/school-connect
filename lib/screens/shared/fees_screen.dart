import 'package:flutter/material.dart';
import '../../models/fee_record.dart';
import '../../models/student_model.dart';
import '../../services/firestore_service.dart';

class FeesScreen extends StatefulWidget {
  final bool isTeacher;

  const FeesScreen({
    super.key,
    required this.isTeacher,
  });

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    if (widget.isTeacher) {
      return _buildTeacherView();
    } else {
      return _buildStudentView();
    }
  }

  Widget _buildStudentView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Fees'),
      ),
      body: StreamBuilder<FeeRecord?>(
        stream: _firestoreService.getMyFees(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final fee = snapshot.data;

          if (fee == null) {
            return const Center(
              child: Text('No fee record found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fee Summary',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRow('Student Name', fee.studentName),
                    _buildRow('Class', fee.className),
                    _buildRow('Total Fees', '₹ ${fee.totalFees.toStringAsFixed(0)}'),
                    _buildRow('Paid Fees', '₹ ${fee.paidFees.toStringAsFixed(0)}'),
                    _buildRow('Pending Fees', '₹ ${fee.pendingFees.toStringAsFixed(0)}'),
                    _buildRow('Due Date', fee.dueDate),
                    _buildRow('Status', fee.status),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeacherView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees Management'),
      ),
      body: StreamBuilder<List<FeeRecord>>(
        stream: _firestoreService.getAllFees(),
        builder: (context, feeSnapshot) {
          if (feeSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final fees = feeSnapshot.data ?? [];

          return StreamBuilder<List<StudentModel>>(
            stream: _firestoreService.getAllStudents(),
            builder: (context, studentSnapshot) {
              if (studentSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final students = studentSnapshot.data ?? [];

              if (students.isEmpty) {
                return const Center(
                  child: Text('No students found'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];

                  FeeRecord? feeRecord;
                  try {
                    feeRecord = fees.firstWhere((f) => f.studentId == student.id);
                  } catch (_) {
                    feeRecord = null;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(student.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Class: ${student.className}'),
                          Text('Roll No: ${student.rollNo}'),
                          if (feeRecord != null) ...[
                            Text('Paid: ₹ ${feeRecord.paidFees.toStringAsFixed(0)}'),
                            Text('Pending: ₹ ${feeRecord.pendingFees.toStringAsFixed(0)}'),
                          ] else
                            const Text('No fee record yet'),
                        ],
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _showFeeDialog(
                        context: context,
                        student: student,
                        existing: feeRecord,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showFeeDialog({
    required BuildContext context,
    required StudentModel student,
    FeeRecord? existing,
  }) async {
    final totalController = TextEditingController(
      text: existing != null ? existing.totalFees.toStringAsFixed(0) : '',
    );
    final paidController = TextEditingController(
      text: existing != null ? existing.paidFees.toStringAsFixed(0) : '',
    );
    final dueDateController = TextEditingController(
      text: existing?.dueDate ?? '',
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Update Fees - ${student.name}'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: totalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Total Fees'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: paidController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Paid Fees'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dueDateController,
                  decoration: const InputDecoration(labelText: 'Due Date'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final total = double.tryParse(totalController.text.trim());
                final paid = double.tryParse(paidController.text.trim());
                final dueDate = dueDateController.text.trim();

                if (total == null || paid == null || dueDate.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter valid fee details')),
                  );
                  return;
                }

                final result = await _firestoreService.upsertFees(
                  student: student,
                  totalFees: total,
                  paidFees: paid,
                  dueDate: dueDate,
                );

                if (!mounted) return;

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result ?? 'Fees updated successfully'),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}