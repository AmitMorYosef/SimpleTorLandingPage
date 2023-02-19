import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';

import '../../../utlis/general_utlis.dart';

Future<dynamic> genralDialog(
    {required BuildContext context,
    Widget? content,
    List<Widget>? actions,
    double backgroundOpacity = 1,
    String? title,
    bool dismissible = true,
    DialogTransitionType animationType = DialogTransitionType.fade,
    Cubic curve = Curves.fastOutSlowIn,
    Duration duration = const Duration(milliseconds: 200)}) {
  return showAnimatedDialog<dynamic>(
    barrierDismissible: dismissible,
    context: context,
    builder: (BuildContext context) => GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: AlertDialog(
        backgroundColor: Theme.of(context)
            .dialogBackgroundColor
            .withOpacity(backgroundOpacity),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        title: title != null
            ? Center(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              )
            : null,
        content: SingleChildScrollView(child: content),
        actions: actions,
      ),
    ),
    animationType: animationType,
    curve: curve,
    duration: duration,
  ).whenComplete(() => overLaysHandling());
}
