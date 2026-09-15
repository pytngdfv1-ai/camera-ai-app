import 'package:flutter/material.dart';
import 'screens/camera_screen.dart'; // ✅ CORREGIDO: Ruta simplificada

class CameraAIProApp extends StatelessWidget {
  const CameraAIProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera AI Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const CameraScreen(),
    );
  }
}
