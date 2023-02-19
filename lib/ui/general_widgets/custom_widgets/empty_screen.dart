import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:management_system_app/app_const/application_general.dart';

import '../../../app_const/resources.dart';

class EmptyScreen extends StatelessWidget {
  final String text;
  final double height, width, fontSize;
  const EmptyScreen(
      {super.key,
      required this.text,
      this.height = 100,
      this.width = 120,
      this.fontSize = 16});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
          height: height,
          width: width,
          child: Stack(
            children: [
              Lottie.asset(emptyAnimation,
                  height: height, width: width, repeat: false),
              Align(
                alignment: Alignment.topCenter,
                child: Text(text,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: fontSize,
                        )),
              )
            ],
          )),
    ]);
  }
}
