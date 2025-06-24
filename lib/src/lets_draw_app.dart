import 'package:drawing_board/src/presentation/pages/drawing_page.dart';
import 'package:drawing_board/src/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LetsDrawApp extends StatelessWidget {
  const LetsDrawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Let/'s Draw",
      theme: lightTheme,
      home: const DrawingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
