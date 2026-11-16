import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/attendance_record.dart';
import '../../home/widgets/photo_viewer.dart';

/// Kartu untuk menampilkan satu riwayat presensi harian.
class RecordCard extends StatelessWidget {
  final AttendanceRecord record;

  const RecordCard({
    super.key,
    required this.record,
  });

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) {
      return '$hours jam $minutes menit';
    } else if (hours > 0) {
      return '$hours jam';
    } else {
      return '$minutes menit';
    }
  }

  Widget _buildThumbnail(
    BuildContext context, {
    required String? photoPath,
    required String label,
  }) {
    final hasFile = photoPath != null &&
        photoPath.isNotEmpty &&
        File(photoPath).existsSync();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhotoViewer(
              photoPath: photoPath,
              title: 'Foto $label',
            ),
          ),
        );
      },
      child: Tooltip(
        message: 'Lihat foto $label',
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade100,
          ),
          clipBehavior: Clip.antiAlias,
          child: hasFile
              ? Image.file(
                  File(photoPath),
                  fit: BoxFit.cover,
                )
              : const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');
    // Format Indonesia: "Kamis, 12 November 2026"
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

    final isCheckedOut = record.checkOutTime != null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dateFormat.format(record.date),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (record.totalHours != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      _formatDuration(record.totalHours!),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.login, size: 16, color: Colors.blue),
                          const SizedBox(width: 6),
                          Text(
                            'Masuk: ${timeFormat.format(record.checkInTime)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.logout,
                            size: 16,
                            color: isCheckedOut ? Colors.orange : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isCheckedOut
                                ? 'Pulang: ${timeFormat.format(record.checkOutTime!)}'
                                : 'Pulang: Belum pulang',
                            style: TextStyle(
                              fontSize: 13,
                              color: isCheckedOut ? Colors.black87 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _buildThumbnail(
                      context,
                      photoPath: record.checkInPhotoPath,
                      label: 'Masuk',
                    ),
                    if (isCheckedOut) ...[
                      const SizedBox(width: 8),
                      _buildThumbnail(
                        context,
                        photoPath: record.checkOutPhotoPath,
                        label: 'Pulang',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
