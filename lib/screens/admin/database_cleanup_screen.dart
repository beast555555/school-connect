import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseCleanupScreen extends StatefulWidget {
  const DatabaseCleanupScreen({super.key});

  @override
  State<DatabaseCleanupScreen> createState() => _DatabaseCleanupScreenState();
}

class _DatabaseCleanupScreenState extends State<DatabaseCleanupScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  final TextEditingController confirmController = TextEditingController();

  Future<void> _deleteCollection(String collectionName) async {
    final snapshot = await _firestore.collection(collectionName).get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  Future<void> _deleteNonAdminUsers() async {
    final snapshot = await _firestore.collection('users').get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final role = (data['role'] ?? '').toString().toLowerCase();

      if (role != 'admin') {
        batch.delete(doc.reference);
      }
    }

    final nonAdminCount = snapshot.docs.where((doc) {
      final data = doc.data();
      final role = (data['role'] ?? '').toString().toLowerCase();
      return role != 'admin';
    }).length;

    if (nonAdminCount > 0) {
      await batch.commit();
    }
  }

  Future<void> _cleanDatabase() async {
    if (confirmController.text.trim().toUpperCase() != 'DELETE ALL') {
      _showMessage('Type DELETE ALL to confirm');
      return;
    }

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permanent Cleanup'),
            content: const Text(
              'This will permanently delete all school data and all non-admin user documents.\n\n'
              'This does NOT delete Firebase Authentication users.\n'
              'You must remove teacher/student auth users manually in Firebase Console.\n\n'
              'Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    setState(() => isLoading = true);

    try {
      // Delete data collections
      await _deleteCollection('students');
      await _deleteCollection('homework');
      await _deleteCollection('notices');
      await _deleteCollection('attendance');
      await _deleteCollection('fees');

      // Delete all non-admin user docs
      await _deleteNonAdminUsers();

      if (!mounted) return;

      setState(() => isLoading = false);
      confirmController.clear();

      _showMessage(
        'Database cleaned successfully. Now delete teacher/student Auth users manually in Firebase Console.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showMessage('Cleanup failed: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Cleanup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.withOpacity(0.25)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danger Zone',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This will permanently delete:\n'
                    '• students\n'
                    '• homework\n'
                    '• notices\n'
                    '• attendance\n'
                    '• fees\n'
                    '• all non-admin user documents\n\n'
                    'Admin user documents are preserved.\n'
                    'Firebase Authentication users must be deleted manually in Firebase Console.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmController,
              enabled: !isLoading,
              decoration: InputDecoration(
                labelText: 'Type DELETE ALL to confirm',
                prefixIcon: const Icon(Icons.warning_amber_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: isLoading ? null : _cleanDatabase,
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Permanently Clean Database'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}