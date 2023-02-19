import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';

class ShortCutItem extends StatelessWidget {
  final Widget icon;
  final String name;
  final void Function() onTap;
  final bool showItem;
  final bool clickable;
  const ShortCutItem(
      {super.key,
      required this.icon,
      required this.name,
      required this.onTap,
      this.clickable = true,
      this.showItem = true});

  @override
  Widget build(BuildContext context) {
    if (!showItem) {
      return SizedBox();
    }
    return Expanded(
      child: BouncingWidget(
          scaleFactor: 0.3,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(opacity: clickable ? 1 : 0.5, child: this.icon),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    name,
                    style: TextStyle(fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
          onPressed: () {
            if (!clickable) {
              return;
            }
            onTap();
          }),
    );
  }
}
