import 'package:bulleted_list/bulleted_list.dart';
import 'package:flutter/material.dart';

class BulletListText extends StatelessWidget {
  final List<String?> lines;
  final double fontSize;
  BulletListText({super.key, required this.lines, this.fontSize = 16});

  @override
  Widget build(BuildContext context) {
    return BulletedList(
      bullet: Padding(
        padding: EdgeInsets.only(top: 3),
        child: Icon(Icons.circle,
            color: Theme.of(context)
                .textTheme
                .displaySmall!
                .color!
                .withOpacity(0.8),
            size: fontSize * 0.7),
      ),
      listItems: getListItems(context),
    );
  }

  List<dynamic> getListItems(BuildContext context) {
    List<dynamic> items = [];
    lines.forEach((text) {
      if (text != null) items.add(line(text, context));
    });
    return items;
  }

  Widget line(String txt, BuildContext context) {
    return Text(
      txt,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontSize: fontSize,
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
      textAlign: TextAlign.center,
    );
  }
}
