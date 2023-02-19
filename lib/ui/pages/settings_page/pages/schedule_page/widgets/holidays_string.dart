import 'package:flutter/material.dart';
import 'package:management_system_app/providers/worker_provider.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../../../app_const/worker_scedule.dart';
import '../../../../../../app_statics.dart/worker_data.dart';

class HolidaysString extends StatelessWidget {
  const HolidaysString({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<WorkerProvider>();
    String text = "";
    WorkerData.worker.religions.forEach(
      (religion) {
        switch (religion) {
          case Religion.muslim:
            // TODO: Handle this case.
            break;
          case Religion.christian:
            text += ", " + translate("christianHolidays");
            break;
          case Religion.jewish:
            text += ", " + translate("jewishHolidays");
            break;
        }
      },
    );

    return text != ""
        ? Text(
            text.substring(2),
            style:
                Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11),
          )
        : SizedBox();
  }
}
