import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/di/injection.dart' as di;
import 'core/utils/permission_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inicializar Inyección de Dependencias
  di.setupDependencies();
  
  // 2. Forzar orientación vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // 3. Solicitar permisos críticos al inicio
  await PermissionManager.requestCameraAndStoragePermissions();
  
  runApp(const CameraAIProApp());
}
