import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:management_system_app/models/worker_model.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/gender.dart';
import '../../../../app_const/resources.dart';
import '../../../../providers/booking_provider.dart';
import '../../../../utlis/image_utlis.dart';
import '../../../helpers/fonts_helper.dart';

// ignore: must_be_immutable
class WorkerPicker {
  BuildContext context;
  Map<String, WorkerModel> workers;
  WorkerPicker({required this.context, required this.workers});

  late BookingProvider bookingProvider;

  late int workerIndex;

  Widget picker() {
    bookingProvider = context.read<BookingProvider>();
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text(
          //   translate('order'),
          //   style: Theme.of(context).textTheme.titleLarge,
          // ),
          SizedBox(height: 10),
          Text(
            translate('pickWorker'),
            style: FontsHelper().businessStyle(
                currentStyle: Theme.of(context).textTheme.headlineSmall),
          ),
          workers.length == 0
              ? Text(translate('noWorkersAvailbles'),
                  style: FontsHelper().businessStyle(
                      currentStyle: Theme.of(context).textTheme.headlineSmall))
              : workersList()
        ],
      ),
    );
  }

  Widget workersList() {
    List<String> workersNames = workers.keys.toList();
    return SizedBox(
      height: gHeight * .15,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: workers.length,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.only(top: 10),
              alignment: Alignment.topCenter,
              child: GestureDetector(
                  onTap: () {
                    if (BookingProvider.workerPhone != workersNames[index]) {
                      UiManager.updateUi(
                          context: context,
                          perform: Future(
                            () {
                              BookingProvider.setWorkerPhone(
                                  newWorkerPhone: workersNames[index]);
                              BookingProvider.setDate(DateTime(0));
                              BookingProvider.setTimeIndex(-1);
                              BookingProvider.setTreatmentName("");
                            },
                          ));
                    }
                  },
                  child: workerCard(workersNames[index])),
            );
          }),
    );
  }

  Widget workerCard(String workerPhone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: [
          showCircleCachedImage(
              workers[workerPhone]!.profileImg,
              43,
              workers[workerPhone]!.gender == Gender.female
                  ? defaultWomanImage
                  : defaultManImage),
          Opacity(
            opacity: workerPhone == BookingProvider.workerPhone ? 1 : 0.5,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  color: Theme.of(context).colorScheme.secondary),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: AutoSizeText(
                    workers[workerPhone]!.name,
                    style: FontsHelper().businessStyle(
                        currentStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: 17)),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
