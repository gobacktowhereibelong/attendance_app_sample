import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

/// Layar penampil foto layar penuh dengan InteractiveViewer (zoom).
class PhotoViewer extends StatelessWidget {
  final String? photoPath;
  final String title;

  const PhotoViewer({
    super.key,
    required this.photoPath,
    this.title = 'Lihat Foto',
  });

  bool _isBase64(String str) {
    if (str.length % 4 != 0) return false;
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return base64Regex.hasMatch(str);
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'Foto tidak tersedia',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    final path = photoPath;
    if (path == null || path.trim().isEmpty) {
      return _buildPlaceholder();
    }

    // Cabang 1: Cloud Storage Path (persiapan sesi lanjutan)
    // TODO (Sesi Cloud): Tambahkan pengecekan URL / Cloud Storage di sini:
    // if (path.startsWith('http://') || path.startsWith('https://')) {
    //   return Image.network(path, fit: BoxFit.contain);
    // }

    // Cabang 2: File lokal di penyimpanan perangkat
    final file = File(path);
    if (file.existsSync()) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Image.file(
            file,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => _buildPlaceholder(),
          ),
        ),
      );
    }

    // Cabang 3: String Base64 (dipertahankan untuk kompatibilitas modul)
    if (_isBase64(path)) {
      try {
        final bytes = base64Decode(path);
        return InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: Image.memory(
              bytes,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _buildPlaceholder(),
            ),
          ),
        );
      } catch (_) {
        return _buildPlaceholder();
      }
    }

    // Cabang 4: Placeholder bila file hilang atau tidak dapat dikenali
    return _buildPlaceholder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(child: _buildImageContent()),
    );
  }
}
