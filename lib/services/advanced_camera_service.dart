import 'dart:math';
import 'package:flutter/material.dart';

class AdvancedCameraService {
  static double calculateExposureValue({
    required int iso,
    required double shutterSpeed,
    required double aperture,
  }) {
    final ev = (log(aperture * aperture) / log(2)) -
        (log(shutterSpeed) / log(2)) +
        (log(iso / 100) / log(2));
    return ev;
  }

  static int suggestISO({required double brightness}) {
    if (brightness > 0.7) return 100;
    if (brightness > 0.4) return 400;
    if (brightness > 0.2) return 800;
    if (brightness > 0.1) return 1600;
    return 3200;
  }

  static double suggestShutterSpeed({
    required int iso,
    required bool isMoving,
  }) {
    if (isMoving) return 1 / 500;
    return 1 / 60;
  }

  static String formatShutterSpeed(double speed) {
    if (speed >= 1) return '${speed.toStringAsFixed(1)}s';
    return '1/${(1 / speed).round()}s';
  }
}
