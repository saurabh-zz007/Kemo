import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'views/kemo_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions =
      const WindowOptions(
        size: Size(60, 60),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
        alwaysOnTop: true,
      );

  windowManager.waitUntilReadyToShow(
    windowOptions,
    () async {
      await windowManager.setAsFrameless();
      await windowManager.show();
      await windowManager.focus();
    },
  );

  runApp(const KemoApp());
}

class KemoApp extends StatelessWidget {
  const KemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KEMO Assistant',
      debugShowCheckedModeBanner: false,
      color: Colors.transparent,
      home: KemoView(),
    );
  }
}
