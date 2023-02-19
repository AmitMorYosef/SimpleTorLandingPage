import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app_statics.dart/worker_data.dart';
import '../../../../providers/worker_provider.dart';
import '../../../../utlis/string_utlis.dart';

class StringNearTheBookingTime extends StatelessWidget {
  const StringNearTheBookingTime({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<WorkerProvider>();

    return Text(
      durationToString(Duration(minutes: WorkerData.worker.onHoldMinutes),
          shortTime: 10),
      style: Theme.of(context)
          .textTheme
          .titleLarge!
          .copyWith(fontStyle: FontStyle.italic, fontSize: 11),
    );
  }
}
