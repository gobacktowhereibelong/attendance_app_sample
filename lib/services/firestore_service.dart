import '../models/attendance_record.dart';
import 'attendance_service.dart';

// Nama kelas belum berarti membaca Firestore. Versi ini hanya meneruskan ke AttendanceService.
class FirestoreService {
  final AttendanceService _attendanceService;

  FirestoreService({AttendanceService? attendanceService})
      : _attendanceService = attendanceService ?? AttendanceService();

  Stream<List<AttendanceRecord>> getAttendanceRecords(String userId) {
    return _attendanceService.getAttendanceRecords(userId);
  }

  Stream<AttendanceRecord?> getTodayRecordStream(String userId) {
    return _attendanceService.getTodayRecordStream(userId);
  }

  Future<String> createAttendanceRecord(AttendanceRecord record) {
    return _attendanceService.createAttendanceRecord(record);
  }

  Future<void> updateAttendanceRecord(AttendanceRecord record) {
    return _attendanceService.updateAttendanceRecord(record);
  }
}
