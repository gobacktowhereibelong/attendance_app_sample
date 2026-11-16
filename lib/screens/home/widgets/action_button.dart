import 'package:flutter/material.dart';
import '../../../models/attendance_record.dart';

/// Tombol aksi utama (Presensi Masuk / Presensi Pulang) pada HomeScreen.
class ActionButton extends StatelessWidget {
  final AttendanceRecord? record;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final bool isLoading;

  const ActionButton({
    super.key,
    required this.record,
    required this.onCheckIn,
    required this.onCheckOut,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Status 3: Sudah pulang -> Tidak ada tombol
    if (record != null && record!.checkOutTime != null) {
      return const SizedBox.shrink();
    }

    final bool isCheckIn = record == null;

    final label = isCheckIn ? 'Presensi Masuk' : 'Presensi Pulang';
    final icon = isCheckIn ? Icons.login_rounded : Icons.logout_rounded;
    final buttonColor = isCheckIn ? Colors.blueAccent : Colors.orange.shade800;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: isLoading ? null : (isCheckIn ? onCheckIn : onCheckOut),
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

