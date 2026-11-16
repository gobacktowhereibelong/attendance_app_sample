import 'package:permission_handler/permission_handler.dart';

/// Layanan untuk mengelola izin perangkat (kamera).
class PermissionService {
  Future<PermissionStatus> get cameraStatus => Permission.camera.status;

  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
