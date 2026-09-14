import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class PortraitMode extends StatefulWidget {
  const PortraitMode({super.key});
  @override
  State<PortraitMode> createState() => _PortraitModeState();
}

class _PortraitModeState extends State<PortraitMode> {
  CameraController? _controller;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _controller = CameraController(front, ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _capture() async {
    if (_isBusy || _controller == null) return;
    _isBusy = true;
    try {
      final xfile = await _controller!.takePicture();
      final bytes = await xfile.readAsBytes();
      await StorageService.saveToGallery(
        imageData: bytes,
        mode: CaptureMode.portrait,
      );
      await StorageService.saveToPrivateStorage(
        imageData: bytes,
        mode: CaptureMode.portrait,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Retrato guardado'), backgroundColor: Colors.green),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        CameraPreview(_controller!),
        CustomPaint(
          size: Size.infinite,
          painter: PortraitFramePainter(),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _capture,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
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
    );
  }
}

class PortraitFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.6,
      height: size.height * 0.7,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(100)), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
