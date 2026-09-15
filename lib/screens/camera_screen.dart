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

  final List<String> _modeNames = const ['Retrato', 'ProShot', 'Docs', 'Experto'];
  final List<IconData> _modeIcons = const [
    Icons.portrait,
    Icons.camera,
    Icons.document_scanner,
    Icons.tune,
  ];

  // ✅ SOLUCIÓN: Usar PageView con keepPage: false para que solo un modo esté activo a la vez
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentMode);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ PageView con keepPage: false destruye y reconstruye los modos al cambiar
      // Esto libera el CameraController anterior e inicializa el nuevo
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Deshabilitar swipe entre modos
        children: const [
          PortraitMode(),
          ProShotMode(),
          DocumentMode(),
          ExpertMode(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentMode,
        onTap: (index) {
          setState(() {
            _currentMode = index;
          });
          // ✅ Navegar al modo seleccionado (destruye el anterior, crea el nuevo)
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        },
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
