import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ProShotMode extends StatefulWidget {
  const ProShotMode({super.key});
  @override
  State<ProShotMode> createState() => _ProShotModeState();
}

class _ProShotModeState extends State<ProShotMode> {
  CameraController? _controller;
  double _exposure = 0.0;
  double _zoom = 1.0;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _controller = CameraController(cameras.first, ResolutionPreset.veryHigh);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _capture() async {
    if (_isBusy || _controller == null) return;
    _isBusy = true;
    try {
      await _controller!.setExposureOffset(_exposure);
      await _controller!.setZoomLevel(_zoom);
      final xfile = await _controller!.takePicture();
      final bytes = await xfile.readAsBytes();
      await StorageService.saveToGallery(imageData: bytes, mode: CaptureMode.proshot);
      await StorageService.saveToPrivateStorage(imageData: bytes, mode: CaptureMode.proshot);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Foto Pro guardada'), backgroundColor: Colors.green),
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
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text('Exposición: ${_exposure.toStringAsFixed(1)}',
                    style: const TextStyle(color: Colors.white)),
                Slider(
                  value: _exposure,
                  min: -3,
                  max: 3,
                  onChanged: (v) => setState(() => _exposure = v),
                ),
                Text('Zoom: ${_zoom.toStringAsFixed(1)}x',
                    style: const TextStyle(color: Colors.white)),
                Slider(
                  value: _zoom,
                  min: 1,
                  max: 5,
                  onChanged: (v) => setState(() => _zoom = v),
                ),
              ],
            ),
          ),
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
