import 'package:drawing_board/src/presentation/presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> categories = const [
    {
      'title': 'Chó',
      'emoji': 'assets/dog-icon.png',
      'color': Color(0xFF6B73FF),
      'shadowColor': Color(0xFF9B59B6),
      'description': 'Vẽ chú chó đáng yêu',
    },
    {
      'title': 'Mèo',
      'emoji': 'assets/cat-icon.png',
      'color': Color(0xFFFF6B6B),
      'shadowColor': Color(0xFFE74C3C),
      'description': 'Vẽ em mèo xinh xắn',
    },
    {
      'title': 'Cây',
      'emoji': 'assets/tree-icon.png',
      'color': Color(0xFF4ECDC4),
      'shadowColor': Color(0xFF16A085),
      'description': 'Vẽ cây xanh tươi mát',
    },
    {
      'title': 'Xe hơi',
      'emoji': 'assets/car-icon.png',
      'color': Color(0xFFFFD93D),
      'shadowColor': Color(0xFFF39C12),
      'description': 'Vẽ chiếc xe hơi',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showInstructions() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text('🎨', style: TextStyle(fontSize: 40)),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Hướng dẫn chơi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    '1. Chọn một chủ đề yêu thích\n'
                    '2. Sử dụng ngón tay để vẽ trên màn hình\n'
                    '3. Thỏa sức sáng tạo với nhiều màu sắc\n'
                    '4. Lưu lại tác phẩm của bạn\n'
                    '5. Chia sẻ với bạn bè và gia đình!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF667eea),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Bắt đầu vẽ! 🚀',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
      final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with title and help button
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chọn chủ đề vẽ',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Hãy chọn một chủ đề yêu thích!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _showInstructions,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.help_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Categories Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: categories.length,
                          gridDelegate:
                               SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isLandscape ? 4 : 2,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                childAspectRatio: 0.85,
                              ),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return AnimatedContainer(
                              duration: Duration(
                                milliseconds: 200 + (index * 100),
                              ),
                              child: CategoryCard(
                                title: category['title']!,
                                emoji: category['emoji']!,
                                color: category['color']!,
                                shadowColor: category['shadowColor']!,
                                description: category['description']!,
                                delay: index * 100,
                                onTap: () {
                                  // Add haptic feedback
                                  HapticFeedback.lightImpact();
                                  Get.to(
                                    () => DrawingPage(),
                                    transition: Transition.rightToLeftWithFade,
                                    duration: const Duration(milliseconds: 300),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Bottom padding
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatefulWidget {
  final String title;
  final String emoji;
  final Color color;
  final Color shadowColor;
  final String description;
  final VoidCallback onTap;
  final int delay;

  const CategoryCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.color,
    required this.shadowColor,
    required this.description,
    required this.onTap,
    required this.delay,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
      final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: widget.shadowColor.withOpacity(0.3),
                    blurRadius: _isPressed ? 8 : 15,
                    offset:
                        _isPressed ? const Offset(0, 4) : const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [widget.color, widget.color.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Emoji with animated background
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image.asset(
                        widget.emoji,
                        // style: const TextStyle(fontSize: 50),
                        width: isLandscape ? 70: 70,
                        height: isLandscape ? 70 : 70,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Title
                    Text(
                      widget.title,
                      style:  TextStyle(
                        fontSize: isLandscape ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: isLandscape ? 12 :14,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // const SizedBox(height: 15),

                    // // Decorative dots
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: List.generate(3, (index) {
                    //     return Container(
                    //       margin: const EdgeInsets.symmetric(horizontal: 2),
                    //       width: 6,
                    //       height: 6,
                    //       decoration: BoxDecoration(
                    //         color: Colors.white.withOpacity(0.6),
                    //         borderRadius: BorderRadius.circular(3),
                    //       ),
                    //     );
                    //   }),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
