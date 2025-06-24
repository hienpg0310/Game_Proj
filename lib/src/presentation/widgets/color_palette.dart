import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/svg.dart';

class ColorPalette extends StatelessWidget {
  final ValueNotifier<Color> selectedColorListenable;

  const ColorPalette({Key? key, required this.selectedColorListenable})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    List<Color> colors = [Colors.black, Colors.white, ...Colors.primaries];

    // For landscape, show all colors but in a more compact way
    List<Color> landscapeColors = [
      Colors.black,
      Colors.white,
      ...Colors.primaries,
    ];

    return ValueListenableBuilder(
      valueListenable: selectedColorListenable,
      builder: (context, selectedColor, child) {
        return isLandscape
            ? _buildLandscapeLayout(context, selectedColor, landscapeColors)
            : _buildPortraitLayout(context, selectedColor, colors);
      },
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    Color selectedColor,
    List<Color> colors,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 2,
          runSpacing: 2,
          children: [
            for (Color color in colors)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => selectedColorListenable.value = color,
                  child: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color:
                            selectedColor == color ? Colors.blue : Colors.grey,
                        width: 1.5,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: selectedColor,
                border: Border.all(color: Colors.blue, width: 1.5),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
            ),
            const SizedBox(width: 10),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  showColorWheel(context, selectedColorListenable);
                },
                child: Image.asset(
                  'assets/color-wheel.png',
                  height: 40,
                  width: 40,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    Color selectedColor,
    List<Color> colors,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Current color indicator
        Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            color: selectedColor,
            border: Border.all(color: Colors.blue, width: 1.2),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
        ),
        const SizedBox(width: 6),

        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < colors.length; i++) ...[
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => selectedColorListenable.value = colors[i],
                      child: Container(
                        height: 16,
                        width: 16,
                        decoration: BoxDecoration(
                          color: colors[i],
                          border: Border.all(
                            color:
                                selectedColor == colors[i]
                                    ? Colors.blue
                                    : Colors.grey.shade400,
                            width: 1.0,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (i < colors.length - 1) const SizedBox(width: 2),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Color wheel button
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              showColorWheel(context, selectedColorListenable);
            },
            child: Image.asset('assets/color-wheel.png', height: 25, width: 25),
          ),
        ),
      ],
    );
  }

  void showColorWheel(BuildContext context, ValueNotifier<Color> color) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!', ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: color.value,
              onColorChanged: (value) {
                color.value = value;
              },
              colorPickerWidth: MediaQuery.of(context).orientation == Orientation.landscape ? 200 : 300,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
