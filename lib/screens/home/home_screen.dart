import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/attendance_record.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_services.dart';
import '../../services/permission_service.dart';
import '../../services/storage_services.dart';
import '../auth/login_screen.dart';
import '../history/history_screen.dart';
import 'widgets/action_button.dart';
import 'widgets/attendance_card.dart';
import 'widgets/camera_button.dart';
import 'widgets/logout_dialog.dart';
import 'widgets/profile_card.dart';

/// Layar utama presensi digital.
class HomeScreen extends StatefulWidget {
  final AuthServices? authServices;
  final AttendanceService? attendanceService;
  final PhotoStorage? photoStorage;
  final PermissionService? permissionService;

  const HomeScreen({
    super.key,
    this.authServices,
    this.attendanceService,
    this.photoStorage,
    this.permissionService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final AuthServices _authServices;
  late final AttendanceService _attendanceService;
  late final PhotoStorage _photoStorage;
  late final PermissionService _permissionService;

  StreamSubscription<AttendanceRecord?>? _todaySubscription;
  AttendanceRecord? _todayRecord;
  String? _streamErrorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authServices = widget.authServices ?? AuthServices();
    _attendanceService = widget.attendanceService ?? AttendanceService();
    _photoStorage = widget.photoStorage ?? StorageServices();
    _permissionService = widget.permissionService ?? PermissionService();

    _subscribeTodayStream();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _todaySubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _subscribeTodayStream();
    }
  }

  void _subscribeTodayStream() {
    final user = _authServices.currentUser;
    if (user == null) return;

    _todaySubscription?.cancel();
    _todaySubscription =
        _attendanceService.getTodayRecordStream(user.uid).listen(
      (record) {
        if (mounted) {
          setState(() {
            _todayRecord = record;
            _streamErrorMessage = null;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _streamErrorMessage = 'Gagal memuat status presensi: $error';
          });
        }
      },
    );
  }

  Future<void> _checkIn() async {
    if (_isLoading) return;
    final user = _authServices.currentUser;
    if (user == null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Ambil foto terlebih dahulu (wajib)
      final photoPath = await CameraButton.capturePhoto(
        context,
        photoType: 'checkin',
        photoStorage: _photoStorage,
        permissionService: _permissionService,
      );

      // Jika dibatalkan pengguna, hentikan alur tanpa membuat record
      if (photoPath == null) {
        return;
      }

      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);

      final newRecord = AttendanceRecord(
        id: '',
        userId: user.uid,
        checkInTime: now,
        date: todayDate,
        checkInPhotoPath: photoPath,
      );

      await _attendanceService.createAttendanceRecord(newRecord);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Presensi masuk berhasil dicatat!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal melakukan presensi masuk: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkOut() async {
    if (_isLoading) return;
    final user = _authServices.currentUser;
    if (user == null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return;
    }

    final currentRecord = _todayRecord;
    if (currentRecord == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda belum melakukan presensi masuk hari ini.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Ambil foto pulang terlebih dahulu (wajib)
      final photoPath = await CameraButton.capturePhoto(
        context,
        photoType: 'checkout',
        photoStorage: _photoStorage,
        permissionService: _permissionService,
      );

      if (photoPath == null) {
        return;
      }

      final now = DateTime.now();
      final updatedRecord = currentRecord.copyWith(
        checkOutTime: now,
        checkOutPhotoPath: photoPath,
      );

      await _attendanceService.updateAttendanceRecord(updatedRecord);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Presensi pulang berhasil dicatat!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal melakukan presensi pulang: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await LogoutDialog.show(context);
    if (confirmed == true) {
      await _authServices.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authServices.currentUser;
    final email = currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Presensi Digital'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Riwayat Presensi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(
                    authServices: _authServices,
                    attendanceService: _attendanceService,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _subscribeTodayStream();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileCard(email: email),
                const SizedBox(height: 16),
                if (_streamErrorMessage != null) ...[
                  Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red.shade700),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _streamErrorMessage!,
                              style: TextStyle(
                                  color: Colors.red.shade900, fontSize: 13),
                            ),
                          ),
                          TextButton(
                            onPressed: _subscribeTodayStream,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                AttendanceCard(record: _todayRecord),
                const SizedBox(height: 24),
                ActionButton(
                  record: _todayRecord,
                  onCheckIn: _checkIn,
                  onCheckOut: _checkOut,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HistoryScreen(
                          authServices: _authServices,
                          attendanceService: _attendanceService,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('Lihat Riwayat Presensi'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

