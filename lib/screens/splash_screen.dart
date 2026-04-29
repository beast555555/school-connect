import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 90, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'SchoolConnect',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}