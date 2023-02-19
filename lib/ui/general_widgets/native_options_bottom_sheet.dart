import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';

import '../../utlis/string_utlis.dart';

class BottomSheetActionDetails {
  final void Function(BuildContext) onPressed;
  final Widget title;
  BottomSheetActionDetails({required this.title, required this.onPressed});
}

Future<dynamic> showNativeOptionsBottomSheet(BuildContext context, Widget title,
    List<BottomSheetActionDetails> options) async {
  List<BottomSheetAction> actions = [];
  options.forEach((option) {
    actions.add(BottomSheetAction(
      onPressed: option.onPressed,
      title: option.title,
    ));
  });

  return await showAdaptiveActionSheet(
    title: title,
    context: context,
    actions: actions,
    cancelAction: CancelAction(
      onPressed: (_) {
        Navigator.pop(context);
      },
      title: Text(
        translate("cancel"),
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
