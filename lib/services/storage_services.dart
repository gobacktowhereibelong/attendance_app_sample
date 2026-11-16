import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Antarmuka penyimpanan foto presensi.
abstract class PhotoStorage {
  Future<String> savePhoto(String sourcePath, String photoType);
}

/// Implementasi lokal penyimpanan foto presensi.
class StorageServices implements PhotoStorage {
  // Meski bernama upload, versi ini hanya menyimpan lokal.
  Future<String> uploadAttendancePhoto(
    String sourcePath,
    String photoType,
  ) async {
    return await savePhoto(sourcePath, photoType);
  }

  @override
  Future<String> savePhoto(String sourcePath, String photoType) async {
    if (photoType != 'checkin' && photoType != 'checkout') {
      throw ArgumentError(
        "photoType hanya 'checkin' atau 'checkout'; nilai lain tidak diizinkan.",
      );
    }

    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw FileSystemException(
        'File foto sumber tidak ditemukan pada path: $sourcePath',
      );
    }

    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(appDir.path, 'attendance_photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final targetFileName = '${timestamp}_$photoType.jpg';
    final targetPath = p.join(photosDir.path, targetFileName);

    try {
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        targetPath,
        quality: 75,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        throw const FileSystemException(
          'Hasil kompresi foto null. Kompresi gagal.',
        );
      }

      final savedFile = File(compressedFile.path);
      if (!await savedFile.exists()) {
        throw const FileSystemException(
          'File hasil kompresi tidak ditemukan di disk.',
        );
      }

      return compressedFile.path;
    } catch (e) {
      // Jangan diam-diam memakai path asli bila kompresi/simpan gagal
      throw Exception('Gagal menyimpan foto presensi: $e');
    }
  }
}
