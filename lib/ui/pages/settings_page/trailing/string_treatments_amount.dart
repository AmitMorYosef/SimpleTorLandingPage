import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app_statics.dart/worker_data.dart';
import '../../../../providers/worker_provider.dart';
import '../../../../utlis/string_utlis.dart';

class StirngTreatmentsAmount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.watch<WorkerProvider>();

    return Text(
      WorkerData.worker.treatments.length == 1
          ? translate("oneTreatment")
          : "${WorkerData.worker.treatments.length} ${translate("treatments")}",
      style: Theme.of(context)
          .textTheme
          .titleLarge!
          .copyWith(fontStyle: FontStyle.italic, fontSize: 11),
    );
  }
}
