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
  String _aiStatus = "IA: Analizando escena...";

  @override
  void initState() {
    super.initState();
    _initCamera();
    _simulateAIAnalysis();
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
        ResolutionPreset.high, // Estable para vista previa en Xiaomi
        enableAudio: false,
      );
      
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      print('Error iniciando cámara pro: $e');
    }
  }

  void _simulateAIAnalysis() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _aiStatus = "IA: Escena detectada: Paisaje/Nocturno");
    });
  }

  Future<void> _capture() async {
    if (_isBusy || _controller == null || !_controller!.value.isInitialized) return;
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
          const SnackBar(content: Text('✓ Foto Pro con IA guardada'), backgroundColor: Colors.green),
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
          
          // Panel superior de IA
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text(_aiStatus, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Exposición:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Slider(
                    value: _exposure,
                    min: -3,
                    max: 3,
                    activeColor: Colors.orange,
                    onChanged: (v) => setState(() => _exposure = v),
                  ),
                  const Text('Zoom:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Slider(
                    value: _zoom,
                    min: 1,
                    max: 5,
                    activeColor: Colors.orange,
                    onChanged: (v) => setState(() => _zoom = v),
                  ),
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
