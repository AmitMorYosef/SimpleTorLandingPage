import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:management_system_app/models/treatment_model.dart';
import 'package:management_system_app/ui/pages/manually_booking_page/widgets/get_user_details.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../providers/booking_provider.dart';
import '../../../general_widgets/custom_widgets/custom_container.dart';
import '../../../ui_manager.dart';

class TreatmentTypeWidget extends StatelessWidget {
  final String name;
  final Treatment treatment;
  final BuildContext ancestorContext;
  late BookingProvider bookingProvider;
  TreatmentTypeWidget(
      {super.key,
      required this.name,
      required this.treatment,
      required this.ancestorContext});

  @override
  Widget build(BuildContext context) {
    bookingProvider = context.watch<BookingProvider>();
    return GestureDetector(
      onTap: () async {
        if (name != BookingProvider.treatmentName) {
          await UiManager.updateUi(
              context: context,
              perform: Future((() => BookingProvider.setTreatmentName(name))));
          await GetUserDetails().addUserFields(this.ancestorContext);
        }
      },
      child: CustomContainer(
        color: Theme.of(context).colorScheme.secondary,
        needImage: false,
        margin: EdgeInsets.symmetric(horizontal: 8),
        raduis: 40,
        padding: EdgeInsets.all(0),
        opacity: name == BookingProvider.treatmentName ? 1 : 0.5,
        child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    color: Theme.of(context).colorScheme.secondary),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        AutoSizeText(
                          "${name} ",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(fontSize: 17),
                        ),
                        treatment.showTime
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 22),
                                child: AutoSizeText(
                                  "${translate('duration')}: ${treatment.minutesToString()}",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(fontSize: 17),
                                ),
                              )
                            : SizedBox(),
                        treatment.showPrice
                            ? AutoSizeText(
                                "${translate('price')}: ${treatment.priceToString()}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(fontSize: 17),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
