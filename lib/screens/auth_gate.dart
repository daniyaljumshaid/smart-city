import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../complaint_store.dart';
import 'admin_dashboard.dart';
import 'citizen_dashboard.dart';
import 'login_screen.dart';
import 'officer_dashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Widget _dashboardForRole(String role) {
    if (role == UserRole.officer) {
      return const OfficerDashboardScreen();
    }
    if (role == UserRole.admin) {
      return const AdminDashboardScreen();
    }
    return const CitizenDashboard();
  }

  Future<String> _roleForUser(User user) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return snapshot.data()?['role'] as String? ?? UserRole.citizen;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final user = snapshot.data!;
        return FutureBuilder<String>(
          future: _roleForUser(user),
          builder: (context, roleSnapshot) {
            if (!roleSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return _dashboardForRole(roleSnapshot.data!);
          },
        );
      },
    );
  }
}