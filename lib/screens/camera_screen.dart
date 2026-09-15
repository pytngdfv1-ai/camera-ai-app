import 'package:flutter/material.dart';
import '../camera/expert_mode.dart';
import '../screens/gallery_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera AI Pro'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            tooltip: 'Galería',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GalleryScreen()),
              );
            },
          ),
        ],
      ),
      body: const ExpertMode(),
    );
  }
}
