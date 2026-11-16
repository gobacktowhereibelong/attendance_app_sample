import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_app/models/attendance_record.dart';

void main() {
  group('AttendanceRecord Model Tests', () {
    final sampleRecord = AttendanceRecord(
      id: 'rec_123',
      userId: 'user_abc',
      checkInTime: DateTime.parse('2026-11-12T08:00:00.000'),
      checkOutTime: DateTime.parse('2026-11-12T16:00:00.000'),
      date: DateTime.parse('2026-11-12'),
      location: null,
      notes: null,
      checkInPhotoPath: '/path/to/in.jpg',
      checkOutPhotoPath: '/path/to/out.jpg',
    );

    test('Round-trip toJson and fromJson', () {
      final json = sampleRecord.toJson();
      final fromJson = AttendanceRecord.fromJson(json);

      expect(fromJson.id, sampleRecord.id);
      expect(fromJson.userId, sampleRecord.userId);
      expect(fromJson.checkInTime, sampleRecord.checkInTime);
      expect(fromJson.checkOutTime, sampleRecord.checkOutTime);
      expect(fromJson.date, sampleRecord.date);
      expect(fromJson.location, sampleRecord.location);
      expect(fromJson.notes, sampleRecord.notes);
      expect(fromJson.checkInPhotoPath, sampleRecord.checkInPhotoPath);
      expect(fromJson.checkOutPhotoPath, sampleRecord.checkOutPhotoPath);
    });

    test('Tanggal berformat YYYY-MM-DD di JSON', () {
      final json = sampleRecord.toJson();
      expect(json['date'], '2026-11-12');
    });

    test('copyWith melengkapi checkOutTime', () {
      final inOnlyRecord = AttendanceRecord(
        id: 'rec_456',
        userId: 'user_def',
        checkInTime: DateTime.parse('2026-11-12T08:15:00.000'),
        date: DateTime.parse('2026-11-12'),
        checkInPhotoPath: '/path/to/in.jpg',
      );

      expect(inOnlyRecord.checkOutTime, isNull);

      final outTime = DateTime.parse('2026-11-12T16:45:00.000');
      final updated = inOnlyRecord.copyWith(
        checkOutTime: outTime,
        checkOutPhotoPath: '/path/to/out.jpg',
      );

      expect(updated.id, inOnlyRecord.id);
      expect(updated.checkOutTime, outTime);
      expect(updated.checkOutPhotoPath, '/path/to/out.jpg');
    });

    test('totalHours null sebelum pulang dan 8 jam untuk 08.00 sampai 16.00', () {
      final inOnlyRecord = AttendanceRecord(
        id: 'rec_1',
        userId: 'u1',
        checkInTime: DateTime.parse('2026-11-12T08:00:00.000'),
        date: DateTime.parse('2026-11-12'),
      );
      expect(inOnlyRecord.totalHours, isNull);

      final completedRecord = inOnlyRecord.copyWith(
        checkOutTime: DateTime.parse('2026-11-12T16:00:00.000'),
      );
      expect(completedRecord.totalHours, const Duration(hours: 8));
    });

    test('Waktu 08.15 sampai 16.45 menghasilkan 8 jam 30 menit', () {
      final record = AttendanceRecord(
        id: 'rec_2',
        userId: 'u1',
        checkInTime: DateTime.parse('2026-11-12T08:15:00.000'),
        checkOutTime: DateTime.parse('2026-11-12T16:45:00.000'),
        date: DateTime.parse('2026-11-12'),
      );
      expect(record.totalHours, const Duration(hours: 8, minutes: 30));
    });
  });
}
