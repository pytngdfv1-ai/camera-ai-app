import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  static Future<bool> requestCameraAndStoragePermissions() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    // Solicitar cámara siempre
    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) return false;

    // Solicitar almacenamiento según versión de Android
    if (sdkInt >= 33) {
      final photosStatus = await Permission.photos.request();
      return photosStatus.isGranted;
    } else if (sdkInt >= 30) {
      return true; // Android 11-12 no requiere permiso explícito para escribir en carpetas propias
    } else {
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }
  }
}
