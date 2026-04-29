import 'package:flutter/material.dart';
import '../../models/student_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class CreateStudentScreen extends StatefulWidget {
  const CreateStudentScreen({super.key});

  @override
  State<CreateStudentScreen> createState() => _CreateStudentScreenState();
}

class _CreateStudentScreenState extends State<CreateStudentScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedStudentId;
  bool isLoading = false;

  Future<void> createStudentLogin() async {
    if (selectedStudentId == null) {
      showMessage('Please select a student');
      return;
    }

    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showMessage('Please enter email and password');
      return;
    }

    if (passwordController.text.trim().length < 6) {
      showMessage('Password must be at least 6 characters');
      return;
    }

    setState(() => isLoading = true);

    try {
      // get latest students safely
      final students = await _firestoreService.getAllStudents().first;

      StudentModel? selectedStudent;
      try {
        selectedStudent = students.firstWhere((s) => s.id == selectedStudentId);
      } catch (_) {
        selectedStudent = null;
      }

      if (selectedStudent == null) {
        if (!mounted) return;
        setState(() => isLoading = false);
        showMessage('Selected student not found. Please reselect.');
        return;
      }

      if ((selectedStudent.studentAuthUid ?? '').isNotEmpty) {
        if (!mounted) return;
        setState(() => isLoading = false);
        showMessage('This student is already linked to a login account');
        return;
      }

      final result = await _authService.registerStudentAndLink(
        studentDocId: selectedStudent.id,
        name: selectedStudent.name,
        className: selectedStudent.className,
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      if (result != null) {
        showMessage(result);
        return;
      }

      showMessage('Student login created and linked successfully');

      // reset form instead of forcing weird navigation
      setState(() {
        selectedStudentId = null;
      });
      emailController.clear();
      passwordController.clear();
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      showMessage('Failed to create student login: $e');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Student Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<List<StudentModel>>(
                stream: _firestoreService.getAllStudents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Error loading students: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final students = (snapshot.data ?? [])
                      .where((s) => (s.studentAuthUid ?? '').isEmpty)
                      .toList();

                  // keep selected value valid only if still present
                  final validSelectedId = students.any((s) => s.id == selectedStudentId)
                      ? selectedStudentId
                      : null;

                  if (validSelectedId != selectedStudentId) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          selectedStudentId = null;
                        });
                      }
                    });
                  }

                  if (students.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'No unlinked students found.\nAdd student master records first or all students are already linked.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    value: validSelectedId,
                    decoration: InputDecoration(
                      labelText: 'Select Student',
                      prefixIcon: const Icon(Icons.person_search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: students.map((student) {
                      return DropdownMenuItem<String>(
                        value: student.id,
                        child: Text(
                          '${student.name} • ${student.className} • Roll ${student.rollNo}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              selectedStudentId = value;
                            });
                          },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'Student Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                enabled: !isLoading,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
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
                  onPressed: isLoading ? null : createStudentLogin,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Student Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}