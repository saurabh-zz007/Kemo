import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowService {
  Future<void> resizeForListening() async {
    await windowManager.setSize(
      const Size(150, 100),
    );
    await windowManager.setAlignment(
      Alignment.topCenter,
    );
  }

  Future<void> expandWindow({
    required bool hasMessages,
  }) async {
    double targetHeight = hasMessages ? 350 : 140;
    await windowManager.setSize(
      Size(650, targetHeight),
    );
    await windowManager.setAlignment(
      Alignment.topCenter,
    );
  }

  Future<void> shrinkWindow() async {
    await windowManager.setSize(
      const Size(100, 100),
    );
    await windowManager.setAlignment(
      Alignment.topCenter,
    );
  }
}
