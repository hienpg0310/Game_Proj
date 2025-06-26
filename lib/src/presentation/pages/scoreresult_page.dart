import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:drawing_board/src/src.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ScoreResultPage extends StatefulWidget {
  final int score;

  const ScoreResultPage({super.key, required this.score});

  @override
  State<ScoreResultPage> createState() => _ScoreResultPageState();
}

class _ScoreResultPageState extends State<ScoreResultPage>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _scoreController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<int> _scoreCountAnimation;

  final List<AnimationController> _starControllers = [];
  final List<Animation<double>> _starAnimations = [];
  final List<Animation<Color?>> _starColorAnimations = [];
  final List<Animation<double>> _starRotationAnimations = [];

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeIn));

    _scoreCountAnimation = Tween<int>(
      begin: 0,
      end: widget.score,
    ).animate(CurvedAnimation(parent: _scoreController, curve: Curves.easeOut));

    // _generateConfetti();
    _initializeStarAnimations();
    _startAnimations();
  }

void _initializeStarAnimations() {
    for (int i = 0; i < 5; i++) {
      final controller = AnimationController(
        duration: const Duration(
          milliseconds: 1000,
        ),
        vsync: this,
      );

      // Animation cho bounce effect
      final scaleAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.bounceOut));

      // Animation cho màu sắc từ xám sang vàng
      final colorAnimation = ColorTween(
        begin: Colors.grey.withOpacity(0.3),
        end: Colors.amber,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.bounceOut));

      // Animation xoay với bounce
      final rotationAnimation = Tween<double>(
        begin: 0.0,
        end: 2 * math.pi, // 360 degrees in radians
      ).animate(CurvedAnimation(parent: controller, curve: Curves.bounceOut));

      _starControllers.add(controller);
      _starAnimations.add(scaleAnimation);
      _starColorAnimations.add(colorAnimation);
      _starRotationAnimations.add(rotationAnimation);
    }
  }

  int _getStarsToShow() {
    if (widget.score >= 9) return 3;
    if (widget.score >= 6) return 2;
    if (widget.score >= 2) return 1;
    return 0;
  }

  Widget _buildStarRating() {
    final int starsToShow = _getStarsToShow();
    const double starSize = 70.0;
    const int starCount = 3;
    const double containerWidth = 300.0;
    const double containerHeight = 80.0;

    final double totalSpacing = containerWidth - (starCount * starSize) - 10;
    final double spacing = totalSpacing / (starCount - 1);
    final double y = (containerHeight - starSize) / 2;

    return SizedBox(
      width: containerWidth,
      height: containerHeight,
      child: Stack(
        children: List.generate(starCount, (index) {
          final double x = index * (starSize + spacing);
          final bool shouldAnimate = index < starsToShow;

          return Positioned(
            left: x,
            top: y,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _starAnimations[index],
                _starColorAnimations[index],
                _starRotationAnimations[index],
              ]),
              builder: (context, child) {
                Color starColor =
                    shouldAnimate
                        ? (_starColorAnimations[index].value ?? Colors.amber)
                        : Colors.grey.withOpacity(0.3);

                bool showShadow =
                    shouldAnimate &&
                    _starColorAnimations[index].value != null &&
                    _starColorAnimations[index].value!.value >
                        Colors.grey.withOpacity(0.5).value;

                return Transform.scale(
                  scale: _starAnimations[index].value,
                  child: Transform.rotate(
                    angle: _starRotationAnimations[index].value,
                    child: FaIcon(
                      FontAwesomeIcons.solidStar,
                      size: starSize,
                      color: starColor,
                      shadows:
                          showShadow
                              ? [
                                Shadow(
                                  color: Colors.amber.withOpacity(0.6),
                                  blurRadius: 8,
                                ),
                              ]
                              : [],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }


  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mainController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _scoreController.forward();

    // Bắt đầu animation cho các ngôi sao dựa trên điểm số
    await Future.delayed(const Duration(milliseconds: 800));

    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      _starControllers[i].forward();
    }
  }

  String _getEncouragement() {
    if (widget.score >= 9) return "Tuyệt vời! Bạn là nghệ sĩ thực thụ! 🎨";
    if (widget.score >= 6) return "Xuất sắc! Tranh vẽ rất đẹp! 🌟";
    if (widget.score >= 2) return "Bạn vẽ rất tốt! Cố gắng để vẽ đẹp hơn nữa nhé! 👏";
    return "Đẹp quá! Tiếp tục cố gắng nhé! 💪";
  }

  @override
  void dispose() {
    _mainController.dispose();
    _scoreController.dispose();
    // Dispose star controllers
    for (final controller in _starControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
          ),
        ),
        child: Stack(
          // clipBehavior: Clip.none,
          children: [
            // Main content
            SafeArea(
              child: Center(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _scaleAnimation,
                    _fadeAnimation,
                    _scoreCountAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                Center(
                                  child: Image.asset(
                                    "assets/congrat_img.png",
                                    width: 360,

                                  ),
                                ),
                                // 5 Star Rating with Arc Layout
                                Positioned(
                                  top: 300,
                                  left: 0,
                                  right: 0,
                                  child: Center(child: _buildStarRating()),
                                ),

                                Positioned(
                                  top: 410,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Text(
                                      _getEncouragement(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF667eea),
                                      ),
                                    ),
                                  ),
                                ),
                                // Buttons
                                Positioned(
                                  top: 540,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Try again button
                                      ElevatedButton(
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          Get.back();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: const Color(
                                            0xFF667eea,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 30,
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                          ),
                                          elevation: 5,
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.refresh),
                                            SizedBox(width: 8),
                                            Text(
                                              'Vẽ lại',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // New drawing button
                                      ElevatedButton(
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          Get.back();
                                          Get.back(); // Go back to category page
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFFFD93D,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 30,
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                          ),
                                          elevation: 5,
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '🎨',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Vẽ mới',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
