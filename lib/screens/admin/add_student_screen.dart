import 'package:flutter/material.dart';
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

  bool isLoading = false;

  Future<void> addStudent() async {
    final name = nameController.text.trim();
    final className = classController.text.trim();
    final rollNo = rollNoController.text.trim();

    if (name.isEmpty || className.isEmpty || rollNo.isEmpty) {
      showMessage('Please fill all fields');
      return;
    }

    setState(() => isLoading = true);

    final result = await _firestoreService.addStudent(
      name: name,
      className: className,
      rollNo: rollNo,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (result != null) {
      showMessage(result);
      return;
    }

    showMessage('Student master record added successfully');

    nameController.clear();
    classController.clear();
    rollNoController.clear();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student Master'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Student Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: classController,
              decoration: InputDecoration(
                labelText: 'Class',
                prefixIcon: const Icon(Icons.class_),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: rollNoController,
              decoration: InputDecoration(
                labelText: 'Roll No',
                prefixIcon: const Icon(Icons.confirmation_number_outlined),
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
                onPressed: isLoading ? null : addStudent,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Add Student'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}