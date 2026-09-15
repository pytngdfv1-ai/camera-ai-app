import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class PortraitMode extends StatefulWidget {
  const PortraitMode({super.key});

  @override
  State<PortraitMode> createState() => _PortraitModeState();
}

class _PortraitModeState extends State<PortraitMode> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isBusy = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      
      final targetCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        targetCamera,
        ResolutionPreset.high, // Preset estable para vista previa
        enableAudio: false,
      );
      
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      print('Error iniciando cámara retrato: $e');
    }
  }

  Future<void> _capture() async {
    if (_isBusy || _controller == null || !_controller!.value.isInitialized) return;
    _isBusy = true;
    try {
      final xfile = await _controller!.takePicture();
      final bytes = await xfile.readAsBytes();
      
      await StorageService.saveToGallery(imageData: bytes, mode: CaptureMode.portrait);
      await StorageService.saveToPrivateStorage(imageData: bytes, mode: CaptureMode.portrait);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Retrato con IA guardado'), backgroundColor: Colors.green),
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

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();
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
          // ✅ CORRECCIÓN CRÍTICA: Center + AspectRatio garantizan que el preview se renderice
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(
                _controller!,
                key: ValueKey(_controller), // Fuerza la reconstrucción del view nativo
              ),
            ),
          ),
          
          // Overlay de IA (Marco de retrato animado)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: PortraitAIPainter(progress: _animationController.value),
                );
              },
            ),
          ),

          // Badge de IA visible
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('IA: Desenfoque de fondo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          // Botón de captura
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
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
            ),
          ),
        ],
      ),
    );
  }
}

class PortraitAIPainter extends CustomPainter {
  final double progress;
  PortraitAIPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6 + (progress * 0.4))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.65,
      height: size.height * 0.75,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(120)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
