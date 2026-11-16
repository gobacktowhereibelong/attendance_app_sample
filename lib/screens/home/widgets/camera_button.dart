import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../services/permission_service.dart';
import '../../../services/storage_services.dart';

/// Widget tombol kamera dan pengendali alur pengambilan foto presensi.
class CameraButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String photoType; // 'checkin' atau 'checkout'
  final PhotoStorage photoStorage;
  final PermissionService? permissionService;
  final ValueChanged<String> onPhotoCaptured;
  final bool isLoading;

  const CameraButton({
    super.key,
    required this.label,
    this.icon = Icons.camera_alt,
    required this.photoType,
    required this.photoStorage,
    this.permissionService,
    required this.onPhotoCaptured,
    this.isLoading = false,
  });

  /// Alur utama pengambilan foto:
  /// 1. Cek & minta izin kamera
  /// 2. Buka kamera
  /// 3. Tangani pembatalan (return null)
  /// 4. Simpan & kompresi foto via PhotoStorage
  /// 5. Dialog izin ditolak biasa / permanen
  static Future<String?> capturePhoto(
    BuildContext context, {
    required String photoType,
    required PhotoStorage photoStorage,
    PermissionService? permissionService,
    ImagePicker? imagePicker,
  }) async {
    final permissions = permissionService ?? PermissionService();
    final picker = imagePicker ?? ImagePicker();

    var status = await permissions.cameraStatus;
    if (status.isDenied) {
      status = await permissions.requestCameraPermission();
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermanentlyDeniedDialog(context, permissions);
      }
      return null;
    }

    if (status.isDenied) {
      if (!context.mounted) return null;
      final retry = await _showDeniedDialog(context);
      if (retry == true) {
        status = await permissions.requestCameraPermission();
        if (status.isPermanentlyDenied && context.mounted) {
          await _showPermanentlyDeniedDialog(context, permissions);
          return null;
        }
        if (!status.isGranted) return null;
      } else {
        return null;
      }
    }

    if (!status.isGranted) {
      return null;
    }

    // Ambil foto menggunakan image_picker (hanya kamera, tanpa galeri)
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo == null) {
      // Pembatalan oleh pengguna: hentikan tanpa error
      return null;
    }

    // Simpan dan kompres foto. Jika gagal, error akan dilempar ke pemanggil.
    final savedPath = await photoStorage.savePhoto(photo.path, photoType);
    return savedPath;
  }

  static Future<bool?> _showDeniedDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Izin Kamera Diperlukan'),
        content: const Text(
          'Aplikasi presensi memerlukan akses kamera untuk mengambil foto bukti kehadiran saat masuk dan pulang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  static Future<void> _showPermanentlyDeniedDialog(
    BuildContext context,
    PermissionService permissions,
  ) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Izin Kamera Ditolak Permanen'),
        content: const Text(
          'Akses kamera ditolak permanen. Buka pengaturan aplikasi untuk memberikan izin kamera.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              permissions.openSettings();
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isLoading
          ? null
          : () async {
              try {
                final path = await capturePhoto(
                  context,
                  photoType: photoType,
                  photoStorage: photoStorage,
                  permissionService: permissionService,
                );
                if (path != null) {
                  onPhotoCaptured(path);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal mengambil foto: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
