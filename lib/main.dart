import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'screens/config_error/config_error_screen.dart';
import 'wrapper/auth_wrapper.dart';

/// Satu konstanta warna seed untuk tema aplikasi (Modul 1).
const Color kSeedColor = Colors.indigo;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Format tanggal dan waktu memakai intl dengan locale id_ID
  await initializeDateFormatting('id_ID', null);

  try {
    // Inisialisasi Firebase menggunakan DefaultFirebaseOptions (stub awal)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const AttendanceApp());
  } catch (e) {
    // Bila inisialisasi gagal (stub / belum dikonfigurasi), tampilkan ConfigErrorScreen
    runApp(ConfigErrorScreen(errorMessage: e.toString()));
  }
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Presensi Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kSeedColor,
          brightness: Brightness.light,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
