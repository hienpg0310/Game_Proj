import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:drawing_board/src/src.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

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
                      canvasKey: canvasGlobalKey,
                      currentStrokeListenable: currentStroke,
                      strokesListenable: allStrokes,
                      backgroundImageListenable: backgroundImage,
                    );
                  },
                ),
                _CustomAppBar(animationController: animationController),
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

  const _CustomAppBar({Key? key, required this.animationController})
    : super(key: key);

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
