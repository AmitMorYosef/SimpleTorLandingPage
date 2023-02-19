import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:simple_tor_web/models/treatment_model.dart';
import 'package:simple_tor_web/models/worker_model.dart';
import 'package:simple_tor_web/ui/ui_manager.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../providers/booking_provider.dart';
import '../../../helpers/fonts_helper.dart';

// ignore: must_be_immutable
class TypePicker {
  BuildContext context;
  WorkerModel? worker;
  TypePicker({required this.context, required this.worker});

  late BookingProvider bookingProvider;

  late String workerPhone;

  Map<String, Treatment> treatments = {};

  Widget picker() {
    bookingProvider = context.watch<BookingProvider>();
    workerPhone = BookingProvider.workerPhone;
    if (worker == null) return SizedBox();
    treatments = worker!.treatments;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          treatments.length > 0
              ? Text(translate('pichTreatment'),
                  style: FontsHelper().businessStyle(
                    currentStyle: Theme.of(context).textTheme.headlineSmall,
                  ))
              : SizedBox(),
          treatments.length == 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Text(
                    translate('noAvailableTretments'),
                    style: FontsHelper().businessStyle(
                      currentStyle: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                )
              : typesList(context)
        ],
      ),
    );
  }

  Widget typesList(BuildContext context) {
    List<String> treatmentsNames = treatments.keys.toList();
    return SizedBox(
      height: gHeight * .15,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: treatments.length,
          itemBuilder: (context, index) {
            return GestureDetector(
                onTap: () {
                  if (treatmentsNames[index] != BookingProvider.treatmentName) {
                    UiManager.updateUi(
                        context: context,
                        perform: Future((() => BookingProvider.setTreatmentName(
                            treatmentsNames[index]))));
                  }
                },
                child: typeCard(treatmentsNames[index]));
          }),
    );
  }

  Widget typeCard(String name) {
    return treatments[name]!.totalMinutes < 1
        ? SizedBox()
        : Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            children: [
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Opacity(
                      opacity: name == BookingProvider.treatmentName ? 1 : 0.5,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: Theme.of(context).colorScheme.secondary),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 22),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            AutoSizeText(
                              "${name} ",
                              style: FontsHelper().businessStyle(
                                currentStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(fontSize: 17),
                              ),
                            ),
                            treatments[name]!.showTime
                                ? AutoSizeText(
                                    translate('duration') +
                                        ": " +
                                        treatments[name]!.minutesToString(),
                                    textAlign: TextAlign.center,
                                    style: FontsHelper().businessStyle(
                                      currentStyle: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(fontSize: 17),
                                    ),
                                  )
                                : SizedBox(),
                            treatments[name]!.showPrice
                                ? AutoSizeText(
                                    "${translate('price')}: ${treatments[name]!.priceToString()}",
                                    style: FontsHelper().businessStyle(
                                      currentStyle: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(fontSize: 17),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                    )),
              ]);
  }
}
