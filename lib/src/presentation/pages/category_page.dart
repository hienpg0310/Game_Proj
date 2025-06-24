import 'package:drawing_board/src/presentation/presentation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  final List<Map<String, String>> categories = const [
    {
      'title': 'Chó',
      'image': 'https://cdn-icons-png.flaticon.com/512/616/616408.png',
    },
    {
      'title': 'Mèo',
      'image':
          'https://png.pngtree.com/png-vector/20240619/ourlarge/pngtree-cute-cat-sticker-2d-illustration-vector-png-image_12798923.png',
    },
    {
      'title': 'Cây',
      'image':
          'https://img.lovepik.com/png/20231006/Green-and-lush-trees-in-summer-lush-greens-with-luxuriant_102289_wh860.png',
    },
    {
      'title': 'Heo',
      'image':
          'https://inkythuatso.com/uploads/thumbnails/800/2023/02/2-hinh-con-heo-de-thuong-inkythuatso-23-14-54-46.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn chủ đề')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 2 cột
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3 / 4,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryCard(
              title: category['title']!,
              imageUrl: category['image']!,
              onTap: () {
                Get.to(DrawingPage());
              },
            );
          },
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 14, // chiếm 3 phần
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.yellow, // màu viền
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 1, // chiếm 1 phần
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
