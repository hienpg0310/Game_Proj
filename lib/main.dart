import 'package:drawing_board/src/lets_draw_app.dart';
import 'package:drawing_board/src/presentation/pages/category_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Chọn Chủ Đề',
      debugShowCheckedModeBanner: false,
      home: const CategoryPage(),
    );
  }
}

const Color kCanvasColor = Color(0xfff2f3f7);
const String kGithubRepo = 'https://github.com/JideGuru/flutter_drawing_board';
