import 'package:flutter/material.dart';
import '../../core/widgets/app_text_field.dart';
import '../../services/firestore_service.dart';

class AddHomeworkScreen extends StatefulWidget {
  const AddHomeworkScreen({super.key});

  @override
  State<AddHomeworkScreen> createState() => _AddHomeworkScreenState();
}

class _AddHomeworkScreenState extends State<AddHomeworkScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController classController = TextEditingController();

  bool isLoading = false;

  Future<void> saveHomework() async {
    if (titleController.text.trim().isEmpty ||
        subjectController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        dueDateController.text.trim().isEmpty ||
        classController.text.trim().isEmpty) {
      showMessage('Please fill all fields');
      return;
    }

    setState(() => isLoading = true);

    final result = await _firestoreService.addHomework(
      title: titleController.text,
      subject: subjectController.text,
      description: descriptionController.text,
      dueDate: dueDateController.text,
      className: classController.text,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (result != null) {
      showMessage(result);
      return;
    }

    showMessage('Homework added successfully');
    Navigator.pop(context);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    subjectController.dispose();
    descriptionController.dispose();
    dueDateController.dispose();
    classController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Homework'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppTextField(
              controller: titleController,
              label: 'Homework Title',
              icon: Icons.title,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: subjectController,
              label: 'Subject',
              icon: Icons.book,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: descriptionController,
              label: 'Description',
              icon: Icons.description,
              maxLines: 4,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: dueDateController,
              label: 'Due Date',
              icon: Icons.date_range,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: classController,
              label: 'Class (Example: 10A or all)',
              icon: Icons.class_,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveHomework,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Homework',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}