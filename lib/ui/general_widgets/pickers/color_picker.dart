import 'package:flutter/material.dart';

import '../../../utlis/string_utlis.dart';

class ColorPicker extends StatefulWidget {
  static int selectedColor = 0xFF2196F3;
  final Map<String, int> Colors = {
    translate("red"): 0xFFF44336,
    translate("blue"): 0xFF2196F3,
    translate("yellow"): 0xFFFFEB3B,
    translate("white"): 0xFFFFFDFD,
  };
  ColorPicker({super.key});

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  List<Widget> colorWidgets = [];
  @override
  Widget build(BuildContext context) {
    colorWidgets = [];
    widget.Colors.forEach(
      (name, color) => colorWidgets.add(colorItem(name, color)),
    );
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: colorWidgets),
        )
      ],
    );
  }

  Widget colorItem(String name, int color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          ColorPicker.selectedColor = color;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Opacity(
          opacity: ColorPicker.selectedColor == color ? 1 : 0.3,
          child: Column(
            children: [
              Container(
                width: 50.0,
                height: 50.0,
                decoration: new BoxDecoration(
                  color: Color(color),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(
                height: 3,
              ),
              Text(name)
            ],
          ),
        ),
      ),
    );
  }
}
