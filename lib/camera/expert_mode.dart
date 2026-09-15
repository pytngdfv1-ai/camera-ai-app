import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/xiaomi_camera_config.dart';
import '../services/advanced_camera_service.dart';

class ExpertMode extends StatefulWidget {
  const ExpertMode({super.key});

  @override
  State<ExpertMode> createState() => _ExpertModeState();
}

class _ExpertModeState extends State<ExpertMode> {
  CameraController? _controller;
  int _iso = 100;
  double _shutterSpeed = 1 / 125;
  int _wb = 5500;
  bool _enableOIS = true;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.max,
        enableAudio: false,
      );
      
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      print('Error iniciando cámara experta: $e');
    }
  }

  Future<void> _capture() async {
    if (_isBusy || _controller == null || !_controller!.value.isInitialized) return;
    _isBusy = true;
    try {
      final xfile = await _controller!.takePicture();
      final bytes = await xfile.readAsBytes();
      
      await StorageService.saveToGallery(imageData: bytes, mode: CaptureMode.expert);
      await StorageService.saveToPrivateStorage(imageData: bytes, mode: CaptureMode.expert);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Foto Experta guardada'), backgroundColor: Colors.green),
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

  void _applyPreset(CameraPreset preset) {
    setState(() {
      _iso = preset.iso;
      _shutterSpeed = preset.shutterSpeed;
      _enableOIS = preset.enableOIS;
    });
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
        fit: StackFit.expand,
        children: [
          // 1. Vista previa
          CameraPreview(_controller!),
          
          // 2. Grid de regla de tercios
          CustomPaint(size: Size.infinite, painter: GridPainter()),

          // 3. Presets
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: CameraPreset.presets.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(p.name, style: const TextStyle(fontSize: 11, color: Colors.white)),
                      onPressed: () => _applyPreset(p),
                      backgroundColor: Colors.orange.withOpacity(0.8),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 4. Controles manuales
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSlider(
                    label: 'ISO',
                    value: _iso.toDouble(),
                    min: XiaomiCameraConfig.isoRange.start,
                    max: XiaomiCameraConfig.isoRange.end,
                    format: (v) => v.round().toString(),
                    onChanged: (v) => setState(() => _iso = v.round()),
                  ),
                  _buildSlider(
                    label: 'Shutter',
                    value: _shutterSpeed,
                    min: XiaomiCameraConfig.shutterRange.start,
                    max: XiaomiCameraConfig.shutterRange.end,
                    format: AdvancedCameraService.formatShutterSpeed,
                    onChanged: (v) => setState(() => _shutterSpeed = v),
                  ),
                  _buildSlider(
                    label: 'WB',
                    value: _wb.toDouble(),
                    min: 2000,
                    max: 8000,
                    format: (v) => '${v.round()}K',
                    onChanged: (v) => setState(() => _wb = v.round()),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoChip('ISO', _iso.toString()),
                      _infoChip('Shutter', AdvancedCameraService.formatShutterSpeed(_shutterSpeed)),
                      _infoChip('WB', '${_wb}K'),
                      _infoChip('OIS', _enableOIS ? 'ON' : 'OFF'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 5. Botón de captura
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _capture,
                child: Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.green, Colors.blue],
                      ),
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

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String Function(double) format,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            activeColor: Colors.green,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 70,
          child: Text(
            format(value),
            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _infoChip(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;
    final w3 = size.width / 3;
    final h3 = size.height / 3;
    canvas.drawLine(Offset(w3, 0), Offset(w3, size.height), paint);
    canvas.drawLine(Offset(w3 * 2, 0), Offset(w3 * 2, size.height), paint);
    canvas.drawLine(Offset(0, h3), Offset(size.width, h3), paint);
    canvas.drawLine(Offset(0, h3 * 2), Offset(size.width, h3 * 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
