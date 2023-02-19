import 'package:flutter/material.dart';
import 'package:management_system_app/providers/worker_provider.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../app_statics.dart/worker_data.dart';

class AllowNotLoggedInToOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WorkerProvider _workerProvider = context.watch<WorkerProvider>();
    return Switch(
        activeColor: Theme.of(context).colorScheme.secondary,
        value: WorkerData.worker.allowNotLoggedInBookings,
        onChanged: (val) async {
          bool applay = true;
          if (val) {
            dynamic resp = await genralDialog(
                title: translate("warning") + '!',
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, "CANCEL"),
                      child: Text(translate('cancel'))),
                  TextButton(
                      onPressed: () => Navigator.pop(context, "OK"),
                      child: Text(translate('ok')))
                ],
                context: context,
                content: Text(
                  translate("allowNotLoggedInbookingsInfo"),
                  textAlign: TextAlign.center,
                ));
            applay = resp == "OK";
          }
          if (applay)
            UiManager.updateUi(
                context: context,
                perform: Future(
                    () => _workerProvider.updateAllowNotLoggedInToOrder(val)));
        });
  }
}
