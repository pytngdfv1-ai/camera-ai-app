import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/pdf_export_service.dart';
import '../services/share_service.dart';

class DocumentMode extends StatefulWidget {
  const DocumentMode({super.key});

  @override
  State<DocumentMode> createState() => _DocumentModeState();
}

class _DocumentModeState extends State<DocumentMode> {
  CameraController? _controller;
  bool _isBusy = false;
  final List<String> _scannedDocs = [];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      
      // ✅ CORRECCIÓN: Forzar cámara trasera principal
      final targetCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        targetCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      print('Error iniciando cámara documento: $e');
    }
  }

  Future<void> _capture() async {
    if (_isBusy || _controller == null || !_controller!.value.isInitialized) return;
    _isBusy = true;
    try {
      final xfile = await _controller!.takePicture();
      final bytes = await xfile.readAsBytes();
      
      await StorageService.saveToGallery(imageData: bytes, mode: CaptureMode.document);
      final path = await StorageService.saveToPrivateStorage(
        imageData: bytes,
        mode: CaptureMode.document,
      );
      
      setState(() {
        _scannedDocs.add(path);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Documento ${_scannedDocs.length} escaneado con IA'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _exportPDF() async {
    if (_scannedDocs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escanea al menos un documento')),
      );
      return;
    }
    try {
      final pdfPath = await PDFExportService.exportMultipleImagesToPDF(
        imagePaths: _scannedDocs,
        documentTitle: 'Documento_IA',
      );
      await ShareService.sharePDF(pdfPath: pdfPath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ✅ CORRECCIÓN CRÍTICA: Center + AspectRatio
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(
                _controller!,
                key: ValueKey(_controller),
              ),
            ),
          ),
          
          // ✅ CORRECCIÓN: Usar Positioned.fill en lugar de Size.infinite para evitar bugs de renderizado
          Positioned.fill(
            child: CustomPaint(
              painter: DocumentAIPainter(),
            ),
          ),

          // Badge de IA
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.document_scanner, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('IA: Detección de bordes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          // Contador de páginas
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: Text(
                'Páginas: ${_scannedDocs.length}',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          // Controles inferiores
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _capture,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                if (_scannedDocs.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _exportPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Exportar PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentAIPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final margin = 40.0;
    final cornerLength = 60.0;

    // Esquina superior izquierda
    canvas.drawLine(Offset(margin, margin + cornerLength), Offset(margin, margin), paint);
    canvas.drawLine(Offset(margin, margin), Offset(margin + cornerLength, margin), paint);

    // Esquina superior derecha
    canvas.drawLine(Offset(size.width - margin - cornerLength, margin), Offset(size.width - margin, margin), paint);
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin, margin + cornerLength), paint);

    // Esquina inferior izquierda
    canvas.drawLine(Offset(margin, size.height - margin - cornerLength), Offset(margin, size.height - margin), paint);
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin + cornerLength, size.height - margin), paint);

    // Esquina inferior derecha
    canvas.drawLine(Offset(size.width - margin - cornerLength, size.height - margin), Offset(size.width - margin, size.height - margin), paint);
    canvas.drawLine(Offset(size.width - margin, size.height - margin - cornerLength), Offset(size.width - margin, size.height - margin), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
