import 'package:flutter/material.dart';

/// Dialog konfirmasi keluar dari akun.
class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  /// Fungsi helper untuk memunculkan dialog.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const LogoutDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Konfirmasi'),
      content: const Text('Keluar dari akun?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Keluar'),
        ),
      ],
    );
  }
}
