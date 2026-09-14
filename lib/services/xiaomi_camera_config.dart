import 'package:flutter/material.dart';

class XiaomiCameraConfig {
  static const String deviceModel = 'Xiaomi Redmi Note 13 Pro 5G';
  static const int sensorResolution = 200;
  static const double aperture = 1.7;

  static const RangeValues isoRange = RangeValues(50, 12800);
  static const RangeValues shutterRange = RangeValues(1 / 10000, 30);

  static const List<CameraLens> availableLenses = [
    CameraLens(id: 0, name: 'Principal 200MP', focalLength: 24, aperture: 1.7, hasOIS: true),
    CameraLens(id: 1, name: 'Ultra Wide 8MP', focalLength: 13, aperture: 2.2, hasOIS: false),
    CameraLens(id: 2, name: 'Macro 2MP', focalLength: 50, aperture: 2.4, hasOIS: false),
  ];
}

class CameraLens {
  final int id;
  final String name;
  final int focalLength;
  final double aperture;
  final bool hasOIS;

  const CameraLens({
    required this.id,
    required this.name,
    required this.focalLength,
    required this.aperture,
    required this.hasOIS,
  });
}

class CameraPreset {
  final String name;
  final int iso;
  final double shutterSpeed;
  final bool enableOIS;
  final int? lensId;

  const CameraPreset({
    required this.name,
    required this.iso,
    required this.shutterSpeed,
    required this.enableOIS,
    this.lensId,
  });

  static const presets = [
    CameraPreset(name: 'Retrato Nocturno', iso: 3200, shutterSpeed: 1 / 60, enableOIS: true),
    CameraPreset(name: 'Paisaje', iso: 100, shutterSpeed: 1 / 250, enableOIS: false),
    CameraPreset(name: 'Macro', iso: 400, shutterSpeed: 1 / 125, enableOIS: false, lensId: 2),
    CameraPreset(name: 'Ultra Wide', iso: 200, shutterSpeed: 1 / 500, enableOIS: false, lensId: 1),
    CameraPreset(name: 'Larga Exposición', iso: 100, shutterSpeed: 30, enableOIS: true),
  ];
}
