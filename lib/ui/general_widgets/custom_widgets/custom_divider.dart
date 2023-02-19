import 'package:flutter/material.dart';
import 'package:management_system_app/app_const/application_general.dart';

import '../../../app_const/app_sizes.dart';

class CustomDivider extends StatelessWidget {
  final double height;
  final Color color;
  final Widget? txt;
  const CustomDivider({
    super.key,
    this.height = 1,
    this.color = Colors.grey,
    this.txt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      width: gWidth,
      height: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: color,
              height: this.height,
            ),
          ),
          this.txt == null
              ? SizedBox()
              : Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: this.txt),
          Expanded(
            flex: 2,
            child: Container(
              color: color,
              height: this.height,
            ),
          ),
        ],
      ),
    );
  }
}
