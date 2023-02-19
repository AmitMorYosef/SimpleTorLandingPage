import 'package:flutter/material.dart';

class DropDownMenu extends StatefulWidget {
  final Map<String, String> values;
  static String? value;
  Function(String value)? onChanged;
  final String? initialValue;
  double ratio;
  DropDownMenu(
      {super.key,
      required this.values,
      this.onChanged,
      this.ratio = 1,
      this.initialValue});

  @override
  State<DropDownMenu> createState() => _DropDownMenuState();
}

class _DropDownMenuState extends State<DropDownMenu> {
  @override
  void initState() {
    if (widget.initialValue != null) {
      DropDownMenu.value = widget.initialValue;
    }
    if (DropDownMenu.value == null && widget.values.isNotEmpty)
      DropDownMenu.value = widget.values.keys.elementAt(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.values.containsKey(DropDownMenu.value) &&
        widget.values.isNotEmpty) {
      DropDownMenu.value = widget.values.keys.elementAt(0);
    }
    if (DropDownMenu.value == null && widget.values.isNotEmpty) {
      DropDownMenu.value = widget.values.keys.elementAt(0);
    }
    if (widget.values.length == 1) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          widget.values.values.elementAt(0),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }
    return widget.values.isEmpty
        ? SizedBox()
        : SizedBox(
            height: 20 * widget.ratio,
            child: DropdownButton<String>(
              alignment: Alignment.center,
              value: DropDownMenu.value,
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 13 * widget.ratio,
              ),
              borderRadius: BorderRadius.circular(14),
              menuMaxHeight: 200,
              underline: SizedBox(),
              onChanged: (String? value) {
                setState(() {
                  DropDownMenu.value = value;
                });
                if (widget.onChanged != null && value != null) {
                  widget.onChanged!(value);
                }
              },
              items: widget.values.keys
                  .map((item) => DropdownMenuItem<String>(
                        value: item,
                        child: Center(
                          child: Text(
                            widget.values[item]!,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontSize: 13 * widget.ratio),
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          );
  }
}
