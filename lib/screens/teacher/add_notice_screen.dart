import 'package:flutter/material.dart';
import '../../core/widgets/app_text_field.dart';
import '../../services/firestore_service.dart';

class AddNoticeScreen extends StatefulWidget {
  const AddNoticeScreen({super.key});

  @override
  State<AddNoticeScreen> createState() => _AddNoticeScreenState();
}

class _AddNoticeScreenState extends State<AddNoticeScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController targetClassController = TextEditingController();

  bool isLoading = false;

  Future<void> saveNotice() async {
    if (titleController.text.trim().isEmpty ||
        messageController.text.trim().isEmpty ||
        targetClassController.text.trim().isEmpty) {
      showMessage('Please fill all fields');
      return;
    }

    setState(() => isLoading = true);

    final result = await _firestoreService.addNotice(
      title: titleController.text,
      message: messageController.text,
      targetClass: targetClassController.text,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (result != null) {
      showMessage(result);
      return;
    }

    showMessage('Notice added successfully');
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
    messageController.dispose();
    targetClassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Notice'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppTextField(
              controller: titleController,
              label: 'Notice Title',
              icon: Icons.title,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: messageController,
              label: 'Notice Message',
              icon: Icons.message,
              maxLines: 4,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: targetClassController,
              label: 'Target Class (Example: 10A or all)',
              icon: Icons.class_,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveNotice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Notice',
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