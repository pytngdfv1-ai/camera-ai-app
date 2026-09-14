import 'package:flutter/material.dart';
import '../camera/portrait_mode.dart';
import '../camera/proshot_mode.dart';
import '../camera/document_mode.dart';
import '../camera/expert_mode.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  int _currentMode = 0;

  final List<Widget> _modes = const [
    PortraitMode(),
    ProShotMode(),
    DocumentMode(),
    ExpertMode(),
  ];

  final List<String> _modeNames = const ['Retrato', 'ProShot', 'Docs', 'Experto'];
  final List<IconData> _modeIcons = const [
    Icons.portrait,
    Icons.camera,
    Icons.document_scanner,
    Icons.tune,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentMode, children: _modes),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentMode,
        onTap: (i) => setState(() => _currentMode = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: List.generate(4, (i) {
          return BottomNavigationBarItem(
            icon: Icon(_modeIcons[i]),
            label: _modeNames[i],
          );
        }),
      ),
    );
  }
}
