import 'package:flutter/material.dart';
import 'package:management_system_app/providers/worker_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../../app_statics.dart/worker_data.dart';
import '../../../../../../utlis/string_utlis.dart';
import '../../../../../general_widgets/loading_widgets/loading_dialog.dart';

class CloseScheduleOnHolidaysSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.watch<WorkerProvider>();
    print(
      WorkerData.worker.closeScheduleOnHolidays,
    );
    return Container(
      height: 20,
      width: 25,
      child: Switch(
          activeColor: Theme.of(context).colorScheme.secondary,
          value: WorkerData.worker.closeScheduleOnHolidays,
          onChanged: (val) async {
            if (val) {
              await Loading(
                      context: context,
                      navigator: Navigator.of(context),
                      future:
                          WorkerData.setCloseScheduleOnHolidays(val, context),
                      msg: translate("updatedSuccessfully"))
                  .dialog();
            } else {
              WorkerData.setCloseScheduleOnHolidays(val, context,
                  onLoading: false);
            }
          }),
    );
  }
}
