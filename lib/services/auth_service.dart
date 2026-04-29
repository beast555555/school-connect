import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // =========================
  // LOGIN / LOGOUT
  // =========================

  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      return doc.data();
    } catch (e) {
      return null;
    }
  }

  // =========================
  // INTERNAL: CREATE USER WITH SECONDARY APP
  // =========================

  Future<UserCredential> _createUserWithoutLosingAdminSession({
    required String email,
    required String password,
  }) async {
    FirebaseApp? secondaryApp;

    try {
      const appName = 'SecondaryAuthApp';

      // Try deleting old leftover app if it exists (safe cleanup)
      try {
        final existing = Firebase.apps.where((app) => app.name == appName);
        if (existing.isNotEmpty) {
          await existing.first.delete();
        }
      } catch (_) {}

      final primary = Firebase.app();

      secondaryApp = await Firebase.initializeApp(
        name: appName,
        options: primary.options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Sign out secondary auth so it doesn't keep session
      await secondaryAuth.signOut();

      return credential;
    } finally {
      // Delete secondary app after use
      if (secondaryApp != null) {
        try {
          await secondaryApp.delete();
        } catch (_) {}
      }
    }
  }

  // =========================
  // GENERIC USER CREATE (TEACHER / ADMIN if needed)
  // =========================

  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? className,
  }) async {
    try {
      final userCredential = await _createUserWithoutLosingAdminSession(
        email: email,
        password: password,
      );

      final newUser = userCredential.user;
      if (newUser == null) {
        return 'User creation failed';
      }

      await _firestore.collection('users').doc(newUser.uid).set({
        'uid': newUser.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': role.trim().toLowerCase(),
        'className': (className ?? '').trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Registration failed';
    } catch (e) {
      return e.toString();
    }
  }

  // =========================
  // STUDENT CREATE + AUTO LINK TO STUDENT MASTER
  // =========================

  Future<String?> registerStudentAndLink({
    required String name,
    required String email,
    required String password,
    required String className,
    required String studentDocId,
  }) async {
    try {
      final userCredential = await _createUserWithoutLosingAdminSession(
        email: email,
        password: password,
      );

      final newUser = userCredential.user;
      if (newUser == null) {
        return 'Student account creation failed';
      }

      // Create user document
      await _firestore.collection('users').doc(newUser.uid).set({
        'uid': newUser.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': 'student',
        'className': className.trim(),
        'studentDocId': studentDocId.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Link student master document
      await _firestore.collection('students').doc(studentDocId).update({
        'studentAuthUid': newUser.uid,
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Student registration failed';
    } catch (e) {
      return e.toString();
    }
  }
}