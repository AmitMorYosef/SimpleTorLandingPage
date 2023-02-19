import 'package:flutter/material.dart';
import 'package:management_system_app/providers/worker_provider.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:provider/provider.dart';

import '../../../../app_statics.dart/worker_data.dart';

class DeleteDataSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WorkerProvider _workerProvider = context.watch<WorkerProvider>();
    return Container(
      height: 20,
      width: 25,
      child: Switch(
          activeColor: Theme.of(context).colorScheme.secondary,
          value: WorkerData.worker.saveData,
          onChanged: (val) async {
            UiManager.updateUi(
                context: context,
                perform:
                    Future(() => _workerProvider.setDeleteWorkerData(val)));
          }),
    );
  }
}
