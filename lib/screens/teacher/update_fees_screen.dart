import 'package:flutter/material.dart';
import '../../models/student_model.dart';
import '../../services/firestore_service.dart';

class UpdateFeesScreen extends StatefulWidget {
  final StudentModel student;

  const UpdateFeesScreen({
    super.key,
    required this.student,
  });

  @override
  State<UpdateFeesScreen> createState() => _UpdateFeesScreenState();
}

class _UpdateFeesScreenState extends State<UpdateFeesScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController totalFeesController = TextEditingController();
  final TextEditingController paidFeesController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();

  bool isLoading = false;

  Future<void> saveFees() async {
    if (totalFeesController.text.trim().isEmpty ||
        paidFeesController.text.trim().isEmpty ||
        dueDateController.text.trim().isEmpty) {
      showMessage('Please fill all fields');
      return;
    }

    final totalFees = double.tryParse(totalFeesController.text.trim());
    final paidFees = double.tryParse(paidFeesController.text.trim());

    if (totalFees == null || paidFees == null) {
      showMessage('Enter valid numeric fees');
      return;
    }

    setState(() => isLoading = true);

    final result = await _firestoreService.upsertFees(
      student: widget.student,
      totalFees: totalFees,
      paidFees: paidFees,
      dueDate: dueDateController.text,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (result != null) {
      showMessage(result);
      return;
    }

    showMessage('Fees updated successfully');
    Navigator.pop(context);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    totalFeesController.dispose();
    paidFeesController.dispose();
    dueDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fees • ${widget.student.name}'),
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
              controller: totalFeesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Total Fees',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: paidFeesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Paid Fees',
                prefixIcon: const Icon(Icons.payments),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dueDateController,
              decoration: InputDecoration(
                labelText: 'Due Date',
                prefixIcon: const Icon(Icons.date_range),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveFees,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Fees',
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