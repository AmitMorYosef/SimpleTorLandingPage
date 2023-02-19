import 'package:flutter/material.dart';
import 'package:management_system_app/app_const/application_general.dart';

import '../../../app_const/app_sizes.dart';

class InAppMessageWidget extends StatelessWidget {
  final String title;
  final String content;
  final double? heigth;
  final double? width;
  const InAppMessageWidget(
      {super.key,
      required this.title,
      required this.content,
      this.heigth,
      this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: this.heigth ?? gHeight * .3,
      width: this.width ?? gWidth * .6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            this.title,
            style:
                Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          Text(
            this.content,
            style:
                Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 17),
            textAlign: TextAlign.center,
          ),
          SizedBox(),
        ],
      ),
    );
  }
}
