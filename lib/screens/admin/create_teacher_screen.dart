import 'package:flutter/material.dart';
import '../../core/widgets/app_text_field.dart';
import '../../services/auth_service.dart';

class CreateTeacherScreen extends StatefulWidget {
  const CreateTeacherScreen({super.key});

  @override
  State<CreateTeacherScreen> createState() => _CreateTeacherScreenState();
}

class _CreateTeacherScreenState extends State<CreateTeacherScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController classController = TextEditingController();

  bool isLoading = false;

  Future<void> createTeacher() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        classController.text.trim().isEmpty) {
      showMessage('Please fill all fields');
      return;
    }

    if (passwordController.text.trim().length < 6) {
      showMessage('Password must be at least 6 characters');
      return;
    }

    setState(() => isLoading = true);

    final result = await _authService.registerUser(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      role: 'teacher',
      className: classController.text,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (result != null) {
      showMessage(result);
      return;
    }

    showMessage(
      'Teacher created successfully.\nFor this MVP, log in again as admin to continue.',
    );

    if (!mounted) return;
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
    emailController.dispose();
    passwordController.dispose();
    classController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Teacher'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppTextField(
              controller: nameController,
              label: 'Teacher Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: passwordController,
              label: 'Password',
              icon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: classController,
              label: 'Assigned Class (Example: 10A)',
              icon: Icons.class_,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : createTeacher,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Create Teacher',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Production note: after creating a teacher, log in again as admin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}