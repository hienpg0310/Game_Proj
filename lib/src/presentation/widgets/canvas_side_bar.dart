import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drawing_board/src/domain/models/drawing_tool.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:drawing_board/main.dart';
import 'package:drawing_board/src/src.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

class CanvasSideBar extends StatefulWidget {
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<double> strokeSize;
  final ValueNotifier<double> eraserSize;
  final ValueNotifier<DrawingTool> drawingTool;
  final CurrentStrokeValueNotifier currentSketch;
  final ValueNotifier<List<Stroke>> allSketches;
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<bool> filled;
  final ValueNotifier<int> polygonSides;
  final ValueNotifier<ui.Image?> backgroundImage;
  final UndoRedoStack undoRedoStack;
  final ValueNotifier<bool> showGrid;
  final VoidCallback? onClose;

  const CanvasSideBar({
    Key? key,
    required this.selectedColor,
    required this.strokeSize,
    required this.eraserSize,
    required this.drawingTool,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
    required this.filled,
    required this.polygonSides,
    required this.backgroundImage,
    required this.undoRedoStack,
    required this.showGrid,
    this.onClose,
  }) : super(key: key);

  @override
  State<CanvasSideBar> createState() => _CanvasSideBarState();
}

class _CanvasSideBarState extends State<CanvasSideBar> {
  UndoRedoStack get undoRedoStack => widget.undoRedoStack;

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: isLandscape ? screenWidth : 300,
      height: isLandscape ? 200 : (screenHeight < 680 ? 450 : 630),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            isLandscape
                ? const BorderRadius.vertical(top: Radius.circular(10))
                : const BorderRadius.horizontal(right: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 3,
            offset: isLandscape ? const Offset(0, -3) : const Offset(3, 3),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          widget.selectedColor,
          widget.strokeSize,
          widget.eraserSize,
          widget.drawingTool,
          widget.filled,
          widget.polygonSides,
          widget.backgroundImage,
          widget.showGrid,
        ]),
        builder: (context, _) {
          return Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            child:
                isLandscape ? _buildHorizontalLayout() : _buildVerticalLayout(),
          );
        },
      ),
    );
  }

  Widget _buildVerticalLayout() {
    return ListView(
      padding: const EdgeInsets.all(10.0),
      controller: scrollController,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
          ),
        ),
        const Text('Shapes', style: TextStyle(fontWeight: FontWeight.bold)),
        const Divider(),
        _buildShapeTools(),
        const SizedBox(height: 8),
        _buildPolygonSlider(),
        const SizedBox(height: 10),
        const Text('Colors', style: TextStyle(fontWeight: FontWeight.bold)),
        const Divider(),
        ColorPalette(selectedColorListenable: widget.selectedColor),
        const SizedBox(height: 20),
        const Text('Size', style: TextStyle(fontWeight: FontWeight.bold)),
        const Divider(),
        _buildSizeSliders(),
        const SizedBox(height: 20),
        const Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
        const Divider(),
        _buildActionButtons(),
        const SizedBox(height: 20),
        const Text('Export', style: TextStyle(fontWeight: FontWeight.bold)),
        const Divider(),
        _buildExportButtons(),
      ],
    );
  }

  Widget _buildHorizontalLayout() {
    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Stack(
        children: [Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Shapes',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  _buildShapeTools(),
                ],
              ),
              const SizedBox(width: 16),
          
              // Colors Section (Compact)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Colors',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 200,
                    height: 60,
                    child: ColorPalette(
                      selectedColorListenable: widget.selectedColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
          
              // Size Controls (Compact)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Size',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 150,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('Stroke:', style: TextStyle(fontSize: 10)),
                            Expanded(
                              child: Slider(
                                value: widget.strokeSize.value,
                                min: 0,
                                max: 50,
                                onChanged: (val) {
                                  widget.strokeSize.value = val;
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Eraser:', style: TextStyle(fontSize: 10)),
                            Expanded(
                              child: Slider(
                                value: widget.eraserSize.value,
                                min: 0,
                                max: 80,
                                onChanged: (val) {
                                  widget.eraserSize.value = val;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
          
              // Actions Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildCompactButton(
                        'Undo',
                        widget.allSketches.value.isNotEmpty
                            ? () => undoRedoStack.undo()
                            : null,
                      ),
                      const SizedBox(width: 4),
                      ValueListenableBuilder<bool>(
                        valueListenable: undoRedoStack.canRedo,
                        builder: (_, canRedo, __) {
                          return _buildCompactButton(
                            'Redo',
                            canRedo ? () => undoRedoStack.redo() : null,
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      _buildCompactButton('Clear', () => undoRedoStack.clear()),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 16),
          
              // Export Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Export',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildCompactButton('PNG', () async {
                        Uint8List? pngBytes = await getBytes();
                        if (pngBytes != null) saveFile(pngBytes, 'png');
                      }),
                      const SizedBox(width: 4),
                      _buildCompactButton('JPEG', () async {
                        Uint8List? pngBytes = await getBytes();
                        if (pngBytes != null) saveFile(pngBytes, 'jpeg');
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onClose,
            ),
          ),
        ]
      ),
    );
  }

  Widget _buildCompactButton(String text, VoidCallback? onPressed) {
    return SizedBox(
      height: 32,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(text, style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  Widget _buildShapeTools() {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 5,
      runSpacing: 5,
      children: [
        _IconBox(
          iconData: FontAwesomeIcons.pencil,
          selected: widget.drawingTool.value == DrawingTool.pencil,
          onTap: () => widget.drawingTool.value = DrawingTool.pencil,
          tooltip: 'Pencil',
        ),
        _IconBox(
          selected: widget.drawingTool.value == DrawingTool.line,
          onTap: () => widget.drawingTool.value = DrawingTool.line,
          tooltip: 'Line',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 2,
                color:
                    widget.drawingTool.value == DrawingTool.line
                        ? Colors.grey[900]
                        : Colors.grey,
              ),
            ],
          ),
        ),
        _IconBox(
          iconData: FontAwesomeIcons.eraser,
          selected: widget.drawingTool.value == DrawingTool.eraser,
          onTap: () => widget.drawingTool.value = DrawingTool.eraser,
          tooltip: 'Eraser',
        ),
      ],
    );
  }

  Widget _buildPolygonSlider() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child:
          widget.drawingTool.value == DrawingTool.polygon
              ? Row(
                children: [
                  const Text('Polygon Sides: ', style: TextStyle(fontSize: 12)),
                  Slider(
                    value: widget.polygonSides.value.toDouble(),
                    min: 3,
                    max: 8,
                    onChanged: (val) {
                      widget.polygonSides.value = val.toInt();
                    },
                    label: '${widget.polygonSides.value}',
                    divisions: 5,
                  ),
                ],
              )
              : const SizedBox.shrink(),
    );
  }

  Widget _buildSizeSliders() {
    return Column(
      children: [
        Row(
          children: [
            const Text('Stroke Size: ', style: TextStyle(fontSize: 12)),
            Slider(
              value: widget.strokeSize.value,
              min: 0,
              max: 50,
              onChanged: (val) {
                widget.strokeSize.value = val;
              },
            ),
          ],
        ),
        Row(
          children: [
            const Text('Eraser Size: ', style: TextStyle(fontSize: 12)),
            Slider(
              value: widget.eraserSize.value,
              min: 0,
              max: 80,
              onChanged: (val) {
                widget.eraserSize.value = val;
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      children: [
        TextButton(
          onPressed:
              widget.allSketches.value.isNotEmpty
                  ? () => undoRedoStack.undo()
                  : null,
          child: const Text('Undo'),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: undoRedoStack.canRedo,
          builder: (_, canRedo, __) {
            return TextButton(
              onPressed: canRedo ? () => undoRedoStack.redo() : null,
              child: const Text('Redo'),
            );
          },
        ),
        TextButton(
          child: const Text('Clear'),
          onPressed: () => undoRedoStack.clear(),
        ),
      ],
    );
  }

  Widget _buildExportButtons() {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: TextButton(
            child: const Text('Export PNG'),
            onPressed: () async {
              Uint8List? pngBytes = await getBytes();
              if (pngBytes != null) saveFile(pngBytes, 'png');
            },
          ),
        ),
        SizedBox(
          width: 140,
          child: TextButton(
            child: const Text('Export JPEG'),
            onPressed: () async {
              Uint8List? pngBytes = await getBytes();
              if (pngBytes != null) saveFile(pngBytes, 'jpeg');
            },
          ),
        ),
      ],
    );
  }

  void saveFile(Uint8List bytes, String extension) async {
    if (kIsWeb) {
      html.AnchorElement()
        ..href = '${Uri.dataFromBytes(bytes, mimeType: 'image/$extension')}'
        ..download =
            'FlutterLetsDraw-${DateTime.now().toIso8601String()}.$extension'
        ..style.display = 'none'
        ..click();
    } else {
      await FileSaver.instance.saveFile(
        name: 'FlutterLetsDraw-${DateTime.now().toIso8601String()}.$extension',
        bytes: bytes,
        ext: extension,
        mimeType: extension == 'png' ? MimeType.png : MimeType.jpeg,
      );
    }
  }

  Future<ui.Image> get _getImage async {
    final completer = Completer<ui.Image>();
    if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
      final file = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (file != null) {
        final filePath = file.files.single.path;
        final bytes =
            filePath == null
                ? file.files.first.bytes
                : File(filePath).readAsBytesSync();
        if (bytes != null) {
          completer.complete(decodeImageFromList(bytes));
        } else {
          completer.completeError('No image selected');
        }
      }
    } else {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        completer.complete(decodeImageFromList(bytes));
      } else {
        completer.completeError('No image selected');
      }
    }

    return completer.future;
  }

  Future<Uint8List?> getBytes() async {
    RenderRepaintBoundary boundary =
        widget.canvasGlobalKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }
}

class _IconBox extends StatelessWidget {
  final IconData? iconData;
  final Widget? child;
  final bool selected;
  final VoidCallback onTap;
  final String? tooltip;

  const _IconBox({
    Key? key,
    this.iconData,
    this.child,
    this.tooltip,
    required this.selected,
    required this.onTap,
  })  : assert(child != null || iconData != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? Colors.grey[900]! : Colors.grey,
              width: 1.5,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Tooltip(
            message: tooltip,
            preferBelow: false,
            child: child ??
                Icon(
                  iconData,
                  color: selected ? Colors.grey[900] : Colors.grey,
                  size: 20,
                ),
          ),
        ),
      ),
    );
  }
}
