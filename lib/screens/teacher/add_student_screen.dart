import 'package:flutter/material.dart';
import '../../core/widgets/app_text_field.dart';
import '../../services/firestore_service.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController rollNoController = TextEditingController();
  final TextEditingController authUidController = TextEditingController();

  bool isLoading = false;

  Future<void> saveStudent() async {
    if (nameController.text.trim().isEmpty ||
        classController.text.trim().isEmpty ||
        rollNoController.text.trim().isEmpty) {
      showMessage('Please fill required fields');
      return;
    }

    setState(() => isLoading = true);

    final result = await _firestoreService.addStudent(
      name: nameController.text,
      className: classController.text,
      rollNo: rollNoController.text,
      studentAuthUid: authUidController.text.trim().isEmpty
          ? null
          : authUidController.text,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (result != null) {
      showMessage(result);
      return;
    }

    showMessage('Student added successfully');
    Navigator.pop(context);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    classController.dispose();
    rollNoController.dispose();
    authUidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppTextField(
              controller: nameController,
              label: 'Student Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: classController,
              label: 'Class (Example: 10A)',
              icon: Icons.class_,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: rollNoController,
              label: 'Roll Number',
              icon: Icons.confirmation_number,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: authUidController,
              label: 'Student Auth UID (optional for now)',
              icon: Icons.badge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Student',
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