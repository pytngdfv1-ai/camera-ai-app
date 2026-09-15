import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'services/storage_service.dart'; // ✅ CORREGIDO: Usamos el servicio que ya tienes

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Forzar orientación vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // 2. Solicitar permisos al iniciar
  await StorageService.requestStoragePermission();
  
  runApp(const CameraAIProApp());
}
