import 'package:flutter/material.dart';
import 'package:management_system_app/app_const/app_sizes.dart';
import 'package:management_system_app/app_const/gender.dart';
import 'package:management_system_app/utlis/image_utlis.dart';

import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../models/worker_model.dart';

class CrewMembering extends StatelessWidget {
  const CrewMembering({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: gDiagnol * 0.13,
      width: gWidthOriginal,
      alignment: Alignment.center,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: SettingsData.workers.length,
        itemBuilder: (context, index) {
          final workerPhone = SettingsData.workers.keys.elementAt(index);
          return workerItem(SettingsData.workers[workerPhone]!);
        },
      ),
    );
  }

  Widget workerItem(WorkerModel worker) {
    return Container(
      child: Column(
        children: [
          showCircleCachedImage(
              worker.profileImg,
              gDiagnol * 0.1,
              worker.gender == Gender.female
                  ? defaultWomanImage
                  : defaultManImage),
          SizedBox(
            height: 10,
          ),
          Text(worker.name)
        ],
      ),
    );
  }
}
