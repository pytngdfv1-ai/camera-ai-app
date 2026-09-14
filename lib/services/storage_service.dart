import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';

enum CaptureMode { portrait, proshot, document, expert }

class StorageService {
  static const String _appFolderName = 'CameraAIApp';

  static Future<bool> requestStoragePermission() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        final status = await Permission.photos.request();
        return status.isGranted;
      } else if (sdkInt >= 30) {
        return true;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } catch (e) {
      return false;
    }
  }

  // CORREGIDO: De 'AppleResult' a 'SaveResult'
  static Future<SaveResult> saveToGallery({
    required Uint8List imageData,
    required CaptureMode mode,
    String? customName,
  }) async {
    final hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      throw Exception('Permisos no concedidos');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final modePrefix = _getModePrefix(mode);
    final fileName = customName ?? '${modePrefix}_$timestamp.jpg';
    final albumName = '$_appFolderName/${_getAlbumName(mode)}';

    return await SaverGallery.saveImage(
      imageData,
      name: fileName,
      androidRelativePath: 'Pictures/$albumName',
      androidExistNotSave: false,
    );
  }

  static Future<String> saveToPrivateStorage({
    required Uint8List imageData,
    required CaptureMode mode,
    String? customName,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final folderPath = '${directory.path}/$_appFolderName/${_getAlbumName(mode)}';
    final folder = Directory(folderPath);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = customName ?? '${_getModePrefix(mode)}_$timestamp.jpg';
    final file = File('$folderPath/$fileName');
    await file.writeAsBytes(imageData);
    return file.path;
  }

  static Future<List<File>> listLocalPhotos({CaptureMode? mode}) async {
    final directory = await getApplicationDocumentsDirectory();
    final folderPath = mode != null
        ? '${directory.path}/$_appFolderName/${_getAlbumName(mode)}'
        : '${directory.path}/$_appFolderName';

    final folder = Directory(folderPath);
    if (!await folder.exists()) return [];

    final files = <File>[];
    await for (final entity in folder.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.jpg')) {
        files.add(entity);
      }
    }
    return files;
  }

  static Future<void> deleteLocalPhoto(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) await file.delete();
  }

  static String _getAlbumName(CaptureMode mode) {
    switch (mode) {
      case CaptureMode.portrait: return 'Retratos';
      case CaptureMode.proshot: return 'ProShot';
      case CaptureMode.document: return 'Documentos';
      case CaptureMode.expert: return 'Experto';
    }
  }

  static String _getModePrefix(CaptureMode mode) {
    switch (mode) {
      case CaptureMode.portrait: return 'PORTRAIT';
      case CaptureMode.proshot: return 'PRO';
      case CaptureMode.document: return 'DOC';
      case CaptureMode.expert: return 'EXPERT';
    }
  }
}
