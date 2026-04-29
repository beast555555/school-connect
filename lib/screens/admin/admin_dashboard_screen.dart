import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'create_teacher_screen.dart';
import 'create_student_screen.dart';
import 'users_list_screen.dart';
import '../shared/student_list_screen.dart';
import '../shared/homework_list_screen.dart';
import '../shared/notice_list_screen.dart';
import '../shared/attendance_list_screen.dart';
import '../shared/fees_screen.dart';
import 'add_student_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logoutUser();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _buildCard(
        context: context,
        title: 'Create Teacher',
        subtitle: 'Add teacher login account',
        icon: Icons.person_add_alt_1,
        color: Colors.indigo,
        screen: const CreateTeacherScreen(),
      ),
      _buildCard(
        context: context,
        title: 'Add Student Master',
        subtitle: 'Create base student record',
        icon: Icons.person_add_alt,
        color: Colors.teal,
        screen: const AddStudentScreen(),
      ),
      _buildCard(
        context: context,
        title: 'Create Student Login',
        subtitle: 'Create and link student login account',
        icon: Icons.badge_outlined,
        color: Colors.deepPurple,
        screen: const CreateStudentScreen(),
      ),
      _buildCard(
        context: context,
        title: 'All Users',
        subtitle: 'View admin / teacher / student accounts',
        icon: Icons.groups_outlined,
        color: Colors.blue,
        screen: const UsersListScreen(),
      ),
      _buildCard(
        context: context,
        title: 'Students Master',
        subtitle: 'Manage student records',
        icon: Icons.school_outlined,
        color: Colors.teal,
        screen: const StudentListScreen(),
      ),
      _buildCard(
        context: context,
        title: 'Homework',
        subtitle: 'View assigned homework',
        icon: Icons.menu_book_outlined,
        color: Colors.orange,
        screen: const HomeworkListScreen(isTeacher: true),
      ),
      _buildCard(
        context: context,
        title: 'Notices',
        subtitle: 'View school notices',
        icon: Icons.campaign_outlined,
        color: Colors.redAccent,
        screen: const NoticeListScreen(isTeacher: true),
      ),
      _buildCard(
        context: context,
        title: 'Attendance',
        subtitle: 'View attendance records',
        icon: Icons.fact_check_outlined,
        color: Colors.deepOrange,
        screen: const AttendanceListScreen(isTeacher: true),
      ),
      _buildCard(
        context: context,
        title: 'Fees',
        subtitle: 'View all fee records',
        icon: Icons.account_balance_wallet_outlined,
        color: Colors.green,
        screen: const FeesScreen(isTeacher: true),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'School Connect Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Manage users, student records and school operations.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...items.map(
            (e) =>
                Padding(padding: const EdgeInsets.only(bottom: 12), child: e),
          ),
        ],
      ),
    );
  }
}
