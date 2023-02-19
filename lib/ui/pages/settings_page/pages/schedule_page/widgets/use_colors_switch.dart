import 'package:flutter/material.dart';

import '../../../../../../app_statics.dart/worker_data.dart';

class UseColorSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //context.watch<WorkerProvider>();
    return Container(
      height: 20,
      width: 25,
      child: Switch(
          splashRadius: 0,
          activeColor: Theme.of(context).colorScheme.secondary,
          value: WorkerData.worker.showSceduleColors,
          onChanged: (val) async {
            WorkerData.updateShowSceduleColors(val, context);
          }),
    );
  }
}
