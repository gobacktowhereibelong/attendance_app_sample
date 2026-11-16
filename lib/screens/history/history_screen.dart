import 'package:flutter/material.dart';
import '../../models/attendance_record.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_services.dart';
import 'widgets/record_card.dart';

/// Layar riwayat presensi pengguna.
class HistoryScreen extends StatelessWidget {
  final AuthServices? authServices;
  final AttendanceService? attendanceService;

  const HistoryScreen({
    super.key,
    this.authServices,
    this.attendanceService,
  });

  @override
  Widget build(BuildContext context) {
    final auth = authServices ?? AuthServices();
    final attendance = attendanceService ?? AttendanceService();
    final user = auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat Presensi')),
        body: const Center(
          child: Text('Sesi telah berakhir. Silakan masuk kembali.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Presensi'),
      ),
      body: StreamBuilder<List<AttendanceRecord>>(
        stream: attendance.getAttendanceRecords(user.uid),
        builder: (context, snapshot) {
          // Tangani kondisi error: tampilkan pesan error, bukan daftar kosong
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat riwayat presensi: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Kondisi loading awal
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final records = snapshot.data ?? [];

          // Urutkan di klien: terbaru dulu berdasarkan checkInTime
          final sortedRecords = List<AttendanceRecord>.from(records)
            ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

          // Daftar kosong: tampilkan pesan netral
          if (sortedRecords.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_busy_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada riwayat presensi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: sortedRecords.length,
            itemBuilder: (context, index) {
              return RecordCard(record: sortedRecords[index]);
            },
          );
        },
      ),
    );
  }
}

