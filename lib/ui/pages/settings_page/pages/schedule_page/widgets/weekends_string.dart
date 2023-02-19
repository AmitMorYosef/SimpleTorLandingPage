import 'package:flutter/material.dart';
import 'package:management_system_app/providers/worker_provider.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../../../app_const/worker_scedule.dart';
import '../../../../../../app_statics.dart/worker_data.dart';

class WeekendString extends StatelessWidget {
  const WeekendString({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<WorkerProvider>();
    String text = "";
    WorkerData.worker.weekendDays.forEach(
      (day) {
        text += ", " + translate(weekDays[day]);
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
