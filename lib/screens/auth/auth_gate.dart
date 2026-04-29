import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../admin/admin_dashboard_screen.dart';
import '../student/student_dashboard_screen.dart';
import '../teacher/teacher_dashboard_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const LoginScreen();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final role = data['role'] ?? '';

        if (role == 'admin') {
          return const AdminDashboardScreen();
        } else if (role == 'teacher') {
          return const TeacherDashboardScreen();
        } else {
          return const StudentDashboardScreen();
        }
      },
    );
  }
}