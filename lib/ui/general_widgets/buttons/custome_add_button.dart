import 'package:flutter/material.dart';

class CustomeAddButton extends StatelessWidget {
  final void Function() onTap;
  final bool showWidget;
  final Color? color;
  final Color? iconColor;
  final double size;
  final double padding;
  const CustomeAddButton(
      {super.key,
      required this.onTap,
      this.color,
      this.iconColor,
      this.showWidget = true,
      this.size = 25,
      this.padding = 5});

  @override
  Widget build(BuildContext context) {
    if (!this.showWidget) {
      return SizedBox();
    }
    return GestureDetector(
        onTap: () => onTap(),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
              color: this.color ?? Theme.of(context).colorScheme.background,
              shape: BoxShape.circle),
          child: Icon(
            Icons.edit,
            size: size,
            color: this.iconColor ?? Theme.of(context).colorScheme.secondary,
          ),
        ));
  }
}
