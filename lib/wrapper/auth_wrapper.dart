import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../services/auth_services.dart';

/// Wrapper navigasi yang mendengarkan perubahan status autentikasi.
class AuthWrapper extends StatelessWidget {
  final AuthServices? authServices;

  const AuthWrapper({super.key, this.authServices});

  @override
  Widget build(BuildContext context) {
    final services = authServices ?? AuthServices();

    return StreamBuilder<User?>(
      stream: services.authStateChanges,
      builder: (context, snapshot) {
        // Status menunggu / koneksi awal
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;

        // User null: arahkan ke LoginScreen (tanpa fallback local_user)
        if (user == null) {
          return LoginScreen(authServices: services);
        }

        // User ada: arahkan ke HomeScreen
        return HomeScreen(authServices: services);
      },
    );
  }
}

