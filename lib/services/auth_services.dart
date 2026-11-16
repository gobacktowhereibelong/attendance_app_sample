import 'package:firebase_auth/firebase_auth.dart';

/// Layanan pembungkus Firebase Authentication.
class AuthServices {
  final FirebaseAuth _auth;

  AuthServices({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Stream perubahan status autentikasi pengguna.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Pengguna yang sedang masuk saat ini.
  User? get currentUser => _auth.currentUser;

  /// Masuk dengan email dan kata sandi.
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Mendaftar akun baru dengan email dan kata sandi.
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Keluar dari akun saat ini.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
