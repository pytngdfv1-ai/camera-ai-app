import 'package:get_it/get_it.dart';
import '../../services/storage_service.dart';
import '../../services/share_service.dart';
import '../../services/pdf_export_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Servicios
  getIt.registerLazySingleton<StorageService>(() => StorageService());
  getIt.registerLazySingleton<ShareService>(() => ShareService());
  getIt.registerLazySingleton<PDFExportService>(() => PDFExportService());
  
  // Aquí se registrarán los BLoCs y Repositorios en el Lote 2
}
