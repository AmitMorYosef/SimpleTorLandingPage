import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';

import '../../../utlis/general_utlis.dart';
import '../../../utlis/string_utlis.dart';

Future<dynamic> genralDeleteDialog(
    {required BuildContext context,
    Widget? content,
    void Function()? onDelete,
    void Function()? onCancel,
    double backgroundOpacity = 1,
    String? title,
    bool dismissible = true,
    DialogTransitionType animationType = DialogTransitionType.slideFromLeftFade,
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
        actions: <Widget>[
          TextButton(
            onPressed: onCancel,
            child: Text(translate("cancel")),
          ),
          TextButton(
            onPressed: onDelete,
            child: Text(translate("delete")),
          )
        ],
      ),
    ),
    animationType: animationType,
    curve: curve,
    duration: duration,
  ).whenComplete(() => overLaysHandling());
}
