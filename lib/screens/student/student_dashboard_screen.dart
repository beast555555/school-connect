import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../shared/homework_list_screen.dart';
import '../shared/notice_list_screen.dart';
import '../shared/attendance_list_screen.dart';
import '../shared/fees_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final AuthService _authService = AuthService();

  String studentName = 'Student';
  bool _isLoadingName = true;

  @override
  void initState() {
    super.initState();
    _loadStudentName();
  }

  Future<void> _loadStudentName() async {
    try {
      final userData = await _authService.getCurrentUserData();

      if (!mounted) return;

      setState(() {
        studentName = (userData?['name'] ?? 'Student').toString();
        _isLoadingName = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        studentName = 'Student';
        _isLoadingName = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logoutUser();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildCard({
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
        title: 'Homework',
        subtitle: 'View homework for your class',
        icon: Icons.menu_book_outlined,
        color: Colors.orange,
        screen: const HomeworkListScreen(isTeacher: false),
      ),
      _buildCard(
        title: 'Notices',
        subtitle: 'View class and school notices',
        icon: Icons.campaign_outlined,
        color: Colors.redAccent,
        screen: const NoticeListScreen(isTeacher: false),
      ),
      _buildCard(
        title: 'Attendance',
        subtitle: 'View your attendance records',
        icon: Icons.fact_check_outlined,
        color: Colors.deepOrange,
        screen: const AttendanceListScreen(isTeacher: false),
      ),
      _buildCard(
        title: 'Fees',
        subtitle: 'View your fee status',
        icon: Icons.account_balance_wallet_outlined,
        color: Colors.green,
        screen: const FeesScreen(isTeacher: false),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoadingName ? 'Welcome' : 'Welcome, $studentName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Access your homework, notices, attendance and fee details.',
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
