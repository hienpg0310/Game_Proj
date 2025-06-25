import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:drawing_board/src/src.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ScoreResultPage extends StatefulWidget {
  final int score;

  const ScoreResultPage({super.key, required this.score});

  @override
  State<ScoreResultPage> createState() => _ScoreResultPageState();
}

class _ScoreResultPageState extends State<ScoreResultPage>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _starsController;
  late AnimationController _confettiController;
  late AnimationController _scoreController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<int> _scoreCountAnimation;

  List<Widget> _confettiPieces = [];

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _starsController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _starsController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeIn));

    _scoreCountAnimation = Tween<int>(
      begin: 0,
      end: widget.score,
    ).animate(CurvedAnimation(parent: _scoreController, curve: Curves.easeOut));

    _generateConfetti();
    _startAnimations();
  }

  void _generateConfetti() {
    final random = math.Random();
    _confettiPieces = List.generate(20, (index) {
      return Positioned(
        left: random.nextDouble() * 400,
        top: -50,
        child: AnimatedBuilder(
          animation: _confettiController,
          builder: (context, child) {
            final progress = _confettiController.value;
            final fallDistance = 800 * progress;
            final rotation = progress * 4 * math.pi;

            return Transform.translate(
              offset: Offset(math.sin(progress * 6) * 50, fallDistance),
              child: Transform.rotate(
                angle: rotation,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        [
                          Colors.red,
                          Colors.blue,
                          Colors.green,
                          Colors.yellow,
                          Colors.purple,
                          Colors.orange,
                        ][random.nextInt(6)],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mainController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _scoreController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _starsController.repeat();
    _confettiController.forward();
  }

  String _getEncouragement() {
    if (widget.score >= 95) return "Tuyệt vời! Bạn là nghệ sĩ thực thụ! 🎨";
    if (widget.score >= 85) return "Xuất sắc! Tranh vẽ rất đẹp! 🌟";
    if (widget.score >= 75) return "Tốt lắm! Bạn vẽ rất hay! 👏";
    return "Hay quá! Tiếp tục cố gắng nhé! 💪";
  }

  String _getEmoji() {
    if (widget.score >= 95) return "🏆";
    if (widget.score >= 85) return "🎖️";
    if (widget.score >= 75) return "🥉";
    return "🎯";
  }

  @override
  void dispose() {
    _mainController.dispose();
    _starsController.dispose();
    _confettiController.dispose();
    _scoreController.dispose();
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
          children: [
            // Confetti
            // ..._confettiPieces,

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
                                    // height: 500,
                                  ),
                                ),
                                // Add 5 star animation
                                // ⭐️ Circle-of-Stars animation
                                // place immediately after the congrat image inside the same Stack
                                // Positioned(
                                //    top: 340,
                                //   left: 0,
                                //   right: 0,
                                //   child: 
                                // ),

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
