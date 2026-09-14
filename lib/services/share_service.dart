import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareImage({
    required String filePath,
    String? subject,
    String? text,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Archivo no encontrado');
    }
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: subject ?? 'Foto de CameraAIApp',
      text: text ?? 'Tomada con Camera AI App',
    );
  }

  static Future<void> shareMultipleImages({
    required List<String> filePaths,
    String? subject,
  }) async {
    final xFiles = <XFile>[];
    for (final path in filePaths) {
      if (await File(path).exists()) {
        xFiles.add(XFile(path));
      }
    }
    if (xFiles.isEmpty) throw Exception('No hay archivos válidos');
    await Share.shareXFiles(xFiles, subject: subject);
  }

  static Future<void> sharePDF({
    required String pdfPath,
    String? subject,
  }) async {
    if (!await File(pdfPath).exists()) {
      throw Exception('PDF no encontrado');
    }
    await Share.shareXFiles(
      [XFile(pdfPath)],
      subject: subject ?? 'Documento PDF',
    );
  }
}
