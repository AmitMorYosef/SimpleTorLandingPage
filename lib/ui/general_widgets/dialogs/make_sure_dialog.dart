import 'package:flutter/material.dart';

import '../../../utlis/string_utlis.dart';
import 'genral_dialog.dart';

Future<bool?> makeSureDialog(BuildContext context, String text) async {
  return await genralDialog(
    context: context,
    title: translate('areYouSure') + "?",
    content: Container(
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop(false);
        },
        child: Text(translate('no')),
      ),
      TextButton(
        onPressed: () async {
          Navigator.of(context).pop(true);
        },
        child: Text(translate('yes')),
      ),
    ],
  );
}
