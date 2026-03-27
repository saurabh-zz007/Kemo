import 'package:flutter/material.dart';
import 'package:frontend/views/kemo_view_final.dart';
import 'package:get/get.dart';

void main() async {
  runApp(const KemoApp());
}

class KemoApp extends StatelessWidget {
  const KemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KEMO Assistant',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: KemoViewFinal(),
    );
  }
}
