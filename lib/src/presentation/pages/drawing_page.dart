import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:drawing_board/src/presentation/pages/scoreresult_page.dart';
import 'package:drawing_board/src/service/scoring_service.dart';
import 'package:flutter/material.dart';
import 'package:drawing_board/src/src.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class DrawingPage extends StatefulWidget {
  final int hintCount;
  final String title;

  const DrawingPage({super.key, required this.hintCount, required this.title});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  final ValueNotifier<Color> selectedColor = ValueNotifier(Colors.black);
  final ValueNotifier<double> strokeSize = ValueNotifier(8.0);
  final ValueNotifier<double> eraserSize = ValueNotifier(30.0);
  final ValueNotifier<DrawingTool> drawingTool = ValueNotifier(
    DrawingTool.pencil,
  );
  final GlobalKey canvasGlobalKey = GlobalKey();
  final ValueNotifier<bool> filled = ValueNotifier(false);
  final ValueNotifier<int> polygonSides = ValueNotifier(3);
  final ValueNotifier<ui.Image?> backgroundImage = ValueNotifier(null);
  final CurrentStrokeValueNotifier currentStroke = CurrentStrokeValueNotifier();
  final ValueNotifier<List<Stroke>> allStrokes = ValueNotifier([]);
  late final UndoRedoStack undoRedoStack;
  final ValueNotifier<bool> showGrid = ValueNotifier(false);
  final ValueNotifier<int> passedHintCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    undoRedoStack = UndoRedoStack(
      currentStrokeNotifier: currentStroke,
      strokesNotifier: allStrokes,
    );
  }

  Future<String> _getImageBase64(GlobalKey canvasKey) async {
    final boundary =
        canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    final String base64Image = base64Encode(pngBytes);
    return base64Encode(pngBytes);
  }

  Future<File> saveBase64ToFile(String base64String, String fileName) async {
    // Loại bỏ header nếu có
    final cleanBase64 = base64String.split(',').last;

    // Giải mã base64
    final bytes = base64Decode(cleanBase64);

    // Lấy thư mục tạm thời
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');

    // Ghi dữ liệu vào file
    await file.writeAsBytes(bytes);

    return file;
  }

  void handleSaveBase64(String base64Image) async {
    final file = await saveBase64ToFile(base64Image, 'drawing.png');
    print('Đã lưu file tại: ${file.path}');
  }

  void _showScoreDialog() async {
    HapticFeedback.mediumImpact();

    final base64Image = await _getImageBase64(canvasGlobalKey);

    final score = await ScoringService.sendToGemini(base64Image, widget.title);

    print(score);

    if (score != null) {
      Get.to(
        () => ScoreResultPage(score: score),
        transition: Transition.zoom,
        duration: const Duration(milliseconds: 200),
      );

      // Get.to(Base64ImagePreview(base64String: base64Image));
      // handleSaveBase64(base64Image);
    } else {
      // fallback nếu gọi API lỗi
      Get.snackbar("Lỗi", "Không thể chấm điểm lúc này");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: kCanvasColor,
        body: HotkeyListener(
          onRedo: undoRedoStack.redo,
          onUndo: undoRedoStack.undo,
          child: Padding(
            padding: EdgeInsets.only(top: isLandscape ? 10 : 40),
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: Listenable.merge([
                    currentStroke,
                    allStrokes,
                    selectedColor,
                    strokeSize,
                    eraserSize,
                    drawingTool,
                    filled,
                    polygonSides,
                    backgroundImage,
                    showGrid,
                  ]),
                  builder: (context, _) {
                    return DrawingCanvas(
                      options: DrawingCanvasOptions(
                        currentTool: drawingTool.value,
                        size: strokeSize.value,
                        strokeColor: selectedColor.value,
                        backgroundColor: kCanvasColor,
                        polygonSides: polygonSides.value,
                        showGrid: showGrid.value,
                        fillShape: filled.value,
                      ),
                      numberOfHintButtons: widget.hintCount,
                      canvasKey: canvasGlobalKey,
                      currentStrokeListenable: currentStroke,
                      strokesListenable: allStrokes,
                      backgroundImageListenable: backgroundImage,
                      onHintPassed: () {
                        if (passedHintCount.value < widget.hintCount) {
                          passedHintCount.value += 1;
                        }
                      },
                    );
                  },
                ),
                _CustomAppBar(
                  animationController: animationController,
                  title: widget.title,
                ),
                Positioned(
                  bottom: isLandscape ? 0 : null,
                  top: isLandscape ? null : kToolbarHeight,
                  left: isLandscape ? 0 : null,
                  right: isLandscape ? null : 0,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin:
                          isLandscape ? const Offset(0, 1) : const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animationController,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: CanvasSideBar(
                      drawingTool: drawingTool,
                      selectedColor: selectedColor,
                      strokeSize: strokeSize,
                      eraserSize: eraserSize,
                      currentSketch: currentStroke,
                      allSketches: allStrokes,
                      canvasGlobalKey: canvasGlobalKey,
                      filled: filled,
                      polygonSides: polygonSides,
                      backgroundImage: backgroundImage,
                      undoRedoStack: undoRedoStack,
                      showGrid: showGrid,
                      onClose: () => animationController.reverse(),
                    ),
                  ),
                ),

                ValueListenableBuilder<int>(
                  valueListenable: passedHintCount,
                  builder: (context, count, _) {
                    if (count < widget.hintCount) return const SizedBox();
                    return _ScoreButton(onScore: _showScoreDialog);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final AnimationController animationController;
  final String title;

  const _CustomAppBar({
    Key? key,
    required this.animationController,
    required this.title,
  }) : super(key: key);

  void _handleBackPress() {
    // Add haptic feedback for better UX
    HapticFeedback.lightImpact();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return SizedBox(
      height: kToolbarHeight,
      width: double.maxFinite,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isLandscape ? 25 : 16,
          vertical: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: _handleBackPress,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            Text(
              "Vẽ chú ${title.toLowerCase()}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            // Tools button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (animationController.value == 0) {
                  animationController.forward();
                } else {
                  animationController.reverse();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.palette,
                  size: 20,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreButton extends StatefulWidget {
  final VoidCallback onScore;

  const _ScoreButton({Key? key, required this.onScore}) : super(key: key);

  @override
  State<_ScoreButton> createState() => _ScoreButtonState();
}

class _ScoreButtonState extends State<_ScoreButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Positioned(
      bottom: isLandscape ? 20 : 30,
      left: 0,
      right: isLandscape ? 40 : 0,
      child: Align(
        alignment: isLandscape ? Alignment.bottomRight : Alignment.bottomCenter,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  widget.onScore();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFFD93D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      const Text(
                        'Chấm điểm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Base64ImagePreview extends StatelessWidget {
  final String base64String;

  const Base64ImagePreview({super.key, required this.base64String});

  @override
  Widget build(BuildContext context) {
    final Uint8List imageBytes = base64Decode(base64String);

    return Scaffold(
      appBar: AppBar(title: const Text('Preview Image')),
      body: Center(child: Image.memory(imageBytes, fit: BoxFit.contain)),
    );
  }
}
