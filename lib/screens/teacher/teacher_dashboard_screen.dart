import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'add_homework_screen.dart';
import 'add_notice_screen.dart';
import '../shared/student_list_screen.dart';
import '../shared/homework_list_screen.dart';
import '../shared/notice_list_screen.dart';
import '../shared/attendance_list_screen.dart';
import '../shared/fees_screen.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

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
        title: 'Add Homework',
        subtitle: 'Assign homework to students',
        icon: Icons.menu_book_outlined,
        color: Colors.orange,
        screen: const AddHomeworkScreen(),
      ),
      _buildCard(
        context: context,
        title: 'Add Notice',
        subtitle: 'Post class or school notice',
        icon: Icons.campaign_outlined,
        color: Colors.redAccent,
        screen: const AddNoticeScreen(),
      ),
      _buildCard(
        context: context,
        title: 'Students',
        subtitle: 'Open student list and take actions',
        icon: Icons.school_outlined,
        color: Colors.teal,
        screen: const StudentListScreen(),
      ),
      _buildCard(
        context: context,
        title: 'Homework Records',
        subtitle: 'View all homework records',
        icon: Icons.assignment_outlined,
        color: Colors.deepPurple,
        screen: const HomeworkListScreen(isTeacher: true),
      ),
      _buildCard(
        context: context,
        title: 'Notice Records',
        subtitle: 'View all notices',
        icon: Icons.notifications_active_outlined,
        color: Colors.blue,
        screen: const NoticeListScreen(isTeacher: true),
      ),
      _buildCard(
        context: context,
        title: 'Attendance Records',
        subtitle: 'View and manage attendance',
        icon: Icons.fact_check_outlined,
        color: Colors.deepOrange,
        screen: const AttendanceListScreen(isTeacher: true),
      ),
      _buildCard(
        context: context,
        title: 'Fees Records',
        subtitle: 'View and manage fees',
        icon: Icons.account_balance_wallet_outlined,
        color: Colors.green,
        screen: const FeesScreen(isTeacher: true),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
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
                  'Teacher Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Manage homework, notices, attendance and fees efficiently.',
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
