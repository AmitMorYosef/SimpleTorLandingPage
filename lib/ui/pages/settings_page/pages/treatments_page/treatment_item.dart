import 'dart:math';

import 'package:flutter/material.dart';
import 'package:management_system_app/models/treatment_model.dart';
import 'package:management_system_app/providers/worker_provider.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/treatments_page/update_treatment.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../../app_const/app_sizes.dart';

class TreatmentItem extends StatelessWidget {
  final Treatment treatment;
  final String treatmentName;
  const TreatmentItem(
      {super.key, required this.treatment, required this.treatmentName});

  void initialTimesTexts(List<Widget> timesTexts) {
    treatment.times.forEach((timeIndex, timeData) {
      String duration =
          durationToString(Duration(minutes: timeData['duration']));
      if (timeIndex == '0') {
        // first segment
        timesTexts.add(Text(
          "התחלה - $duration",
          style: TextStyle(fontSize: 14),
        ));
        return;
      } else {
        String previusKey = '${int.parse(timeIndex) - 1}';
        String breakBefore = durationToString(
            Duration(minutes: treatment.times[previusKey]!['break']));
        timesTexts.add(Text(
          "הפסקה - $breakBefore",
          style: TextStyle(fontSize: 14),
        ));
        timesTexts.add(Text(
          "${timeData['title']} - $duration",
          style: TextStyle(fontSize: 14),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> timesTexts = [];
    initialTimesTexts(timesTexts);
    // timesTexts.add(Text(
    //   "sss",
    //   style: TextStyle(fontSize: 18),
    // ));
    // timesTexts.add(Text(
    //   "sss",
    //   style: TextStyle(fontSize: 18),
    // ));
    // timesTexts.add(Text(
    //   "sss",
    //   style: TextStyle(fontSize: 18),
    // ));
    // timesTexts.add(Text(
    //   "sss",
    //   style: TextStyle(fontSize: 18),
    // ));
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => UpdateTreatment(
                      treatment: treatment,
                      treatmentName: treatmentName,
                    )));
      },
      child: CustomContainer(
        image: null,
        height: 120 + min(125, (33.0 * treatment.times.keys.length)),
        margin: EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            title(context),
            SizedBox(
              height: 5,
            ),
            Container(
              constraints: BoxConstraints(
                maxHeight: min(125, (33.0 * treatment.times.keys.length)),
              ),
              width: gWidth,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: timesTexts,
                ),
              ),
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                durationToString(Duration(minutes: treatment.totalMinutes)),
                style: TextStyle(fontSize: 16),
              ),
            ),
            Spacer(),
            priceAndDelete(context)
          ],
        ),
      ),
    );
  }

  Widget priceAndDelete(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () =>
                makeSureDeleteDialog(context, treatment, treatmentName),
          ),
          CustomContainer(
            raduis: 15,
            margin: EdgeInsets.all(3),
            boxBorder:
                Border.all(color: Theme.of(context).colorScheme.tertiary),
            image: null,
            color: Theme.of(context).colorScheme.tertiary,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              translate("price") + ": " + treatment.priceToString(),
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget title(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomContainer(
        boxBorder: Border.all(color: Theme.of(context).colorScheme.tertiary),
        constraints: BoxConstraints(minWidth: gWidth * .5),
        image: null,
        color: Theme.of(context).colorScheme.tertiary,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        geometryRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit,
              size: 20,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              treatmentName,
              //translate("treatmentType") + ": " + widget.treatmentName,
              style: TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  Future<dynamic> makeSureDeleteDialog(
      BuildContext context, Treatment treatment, String treatmentName) {
    return genralDialog(
      context: context,
      title: translate("deleting"),
      content: Text(
        translate("doDeleteTreatment") + " - " + treatmentName + "?",
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: Text(translate("no")),
        ),
        TextButton(
          onPressed: () {
            UiManager.updateUi(
                context: context,
                perform: context
                    .read<WorkerProvider>()
                    .removeTreatment(treatment, treatmentName));

            Navigator.pop(context);
          },
          child: Text(translate("yes")),
        ),
      ],
    );
  }
}
