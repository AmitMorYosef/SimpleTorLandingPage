import 'package:flutter/material.dart';
import 'package:management_system_app/providers/device_provider.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

class StringBeforeNotify extends StatelessWidget {
  StringBeforeNotify({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<DeviceProvider>();
    return context.read<DeviceProvider>().isAllowedNotification
        ? Text(
            durationToString(
                Duration(
                    minutes:
                        context.read<DeviceProvider>().minutesBeforeNotify),
                shortTime: 10),
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontStyle: FontStyle.italic, fontSize: 12),
          )
        : SizedBox();
  }
}

Future<dynamic> needToTurnOnTheNotification(BuildContext context) async {
  await genralDialog(
      context: context,
      title: translate("error"),
      content: Center(
          child: Text(
        translate("firsttTurnOnNotification"),
        textAlign: TextAlign.center,
      )),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translate("ok")))
      ]);

  return null;
}
