import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:simple_tor_web/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';

Widget infoButton(
    {required BuildContext context,
    required String text,
    EdgeInsets padding = const EdgeInsets.all(15.0),
    Widget child = const Icon(
      Icons.info,
      size: 30,
    )}) {
  return Padding(
    padding: padding,
    child: GestureDetector(
      onTap: () => explainDialog(context, text),
      child: Container(
          alignment: Alignment.center,
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.background),
          child: child),
    ),
  );
}

Future<void> explainDialog(BuildContext context, String text) async {
  await genralDialog(
      animationType: DialogTransitionType.size,
      context: context,
      title: translate('explanation'),
      content: Text(
        text,
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(context),
            child: Text(translate('ok')))
      ]);
}
