import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFExportService {
  static Future<String> exportSingleImageToPDF({
    required String imagePath,
    String? title,
  }) async {
    final imageFile = File(imagePath);
    if (!await imageFile.exists()) throw Exception('Imagen no encontrada');

    final imageBytes = await imageFile.readAsBytes();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            children: [
              if (title != null)
                pw.Padding(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Text(
                    title,
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              pw.Expanded(
                child: pw.Center(
                  child: pw.Image(pw.MemoryImage(imageBytes), fit: pw.BoxFit.contain),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(10),
                child: pw.Text(
                  'Fecha: ${DateTime.now().toString().substring(0, 19)}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/doc_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await File(path).writeAsBytes(await pdf.save());
    return path;
  }

  static Future<String> exportMultipleImagesToPDF({
    required List<String> imagePaths,
    String documentTitle = 'Documento_Escaneado',
  }) async {
    final pdf = pw.Document();

    // CORREGIDO: Limpiar el título para que sea un nombre de archivo válido
    final safeTitle = documentTitle.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

    // Portada
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(documentTitle.replaceAll('_', ' '),
                    style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('Fecha: ${DateTime.now().toString().substring(0, 10)}',
                    style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey)),
                pw.Text('Páginas: ${imagePaths.length}',
                    style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey)),
              ],
            ),
          );
        },
      ),
    );

    // Páginas
    for (int i = 0; i < imagePaths.length; i++) {
      final file = File(imagePaths[i]);
      if (!await file.exists()) continue;
      final bytes = await file.readAsBytes();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Stack(
              children: [
                pw.Center(child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain)),
                pw.Positioned(
                  bottom: 20,
                  right: 20,
                  child: pw.Text('${i + 1}',
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
                ),
              ],
            );
          },
        ),
      );
    }

    final directory = await getApplicationDocumentsDirectory();
    // CORREGIDO: Interpolación de string correcta usando ${safeTitle}
    final path = '${directory.path}/${safeTitle}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await File(path).writeAsBytes(await pdf.save());
    return path;
  }
}
