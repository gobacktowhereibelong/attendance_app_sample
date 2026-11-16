import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance_record.dart';

/// Layanan pencatatan presensi lokal (cache memori + SharedPreferences).
/// File ini dirancang untuk dapat digantikan dengan implementasi Firestore di masa mendatang.
class AttendanceService {
  static const String _storageKey = 'local_attendance_records_v1';

  // Singleton instance
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  final StreamController<void> _updateController =
      StreamController<void>.broadcast();

  final List<AttendanceRecord> _cache = [];
  bool _isInitialized = false;

  /// Memuat data dari SharedPreferences ke cache memori.
  Future<void> _initStorage() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
        _cache.clear();
        for (final item in decoded) {
          _cache.add(AttendanceRecord.fromJson(item as Map<String, dynamic>));
        }
      } catch (e) {
        // Jika format rusak, jangan telan tanpa jejak
        throw FormatException('Gagal memproses data lokal presensi: $e');
      }
    }
    _isInitialized = true;
  }

  /// Menyimpan ulang seluruh cache ke SharedPreferences.
  Future<void> _persistRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_cache.map((e) => e.toJson()).toList());
    final success = await prefs.setString(_storageKey, jsonString);
    if (!success) {
      throw Exception('Gagal menyimpan data presensi ke SharedPreferences.');
    }
  }

  void _emitUpdates() {
    _updateController.add(null);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<AttendanceRecord> _getRecordsForUser(String userId) {
    if (userId.trim().isEmpty) {
      throw ArgumentError('userId tidak boleh kosong.');
    }
    final records = _cache.where((r) => r.userId == userId).toList();
    records.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
    return records;
  }

  AttendanceRecord? _getTodayRecordForUser(String userId) {
    if (userId.trim().isEmpty) {
      throw ArgumentError('userId tidak boleh kosong.');
    }
    final now = DateTime.now();
    for (final r in _cache) {
      if (r.userId == userId && _isSameDate(r.date, now)) {
        return r;
      }
    }
    return null;
  }

  /// Stream daftar riwayat presensi milik pengguna tertentu.
  Stream<List<AttendanceRecord>> getAttendanceRecords(String userId) async* {
    if (userId.trim().isEmpty) {
      throw ArgumentError('userId tidak boleh kosong.');
    }
    await _initStorage();
    yield _getRecordsForUser(userId);
    yield* _updateController.stream.map((_) => _getRecordsForUser(userId));
  }

  /// Stream status presensi hari ini untuk pengguna tertentu.
  Stream<AttendanceRecord?> getTodayRecordStream(String userId) async* {
    if (userId.trim().isEmpty) {
      throw ArgumentError('userId tidak boleh kosong.');
    }
    await _initStorage();
    yield _getTodayRecordForUser(userId);
    yield* _updateController.stream.map((_) => _getTodayRecordForUser(userId));
  }

  /// Membuat catatan presensi baru (Masuk).
  Future<String> createAttendanceRecord(AttendanceRecord record) async {
    if (record.userId.trim().isEmpty) {
      throw ArgumentError('userId tidak boleh kosong.');
    }
    await _initStorage();

    final alreadyExists = _cache.any(
      (r) => r.userId == record.userId && _isSameDate(r.date, record.date),
    );
    if (alreadyExists) {
      throw StateError('Presensi hari ini sudah ada.');
    }

    final newId = record.id.isNotEmpty
        ? record.id
        : DateTime.now().microsecondsSinceEpoch.toString();

    final newRecord = record.copyWith(id: newId);
    _cache.add(newRecord);

    await _persistRecords();
    _emitUpdates();

    return newId;
  }

  /// Memperbarui catatan presensi yang sudah ada (Pulang).
  Future<void> updateAttendanceRecord(AttendanceRecord record) async {
    if (record.userId.trim().isEmpty) {
      throw ArgumentError('userId tidak boleh kosong.');
    }
    await _initStorage();

    final index = _cache.indexWhere(
      (r) => r.id == record.id && r.userId == record.userId,
    );
    if (index == -1) {
      throw StateError('Catatan presensi tidak ditemukan.');
    }

    _cache[index] = record;

    await _persistRecords();
    _emitUpdates();
  }
}
