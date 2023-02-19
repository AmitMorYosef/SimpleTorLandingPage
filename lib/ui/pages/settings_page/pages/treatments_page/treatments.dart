import 'package:flutter/material.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/treatments_page/add_treatment.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/treatments_page/treatment_item.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../../app_const/app_sizes.dart';
import '../../../../../app_const/limitations.dart';
import '../../../../../app_statics.dart/worker_data.dart';
import '../../../../../models/treatment_model.dart';
import '../../../../../providers/worker_provider.dart';
import '../../../../../utlis/validations_utlis.dart';
import '../../../../general_widgets/buttons/info_button.dart';
import '../../../../general_widgets/custom_widgets/custom_text_form_field.dart';

// ignore: must_be_immutable
class Treatments extends StatelessWidget {
  Treatments({super.key});
  late WorkerProvider workerProvider;
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  late CustomTextFormField title, price;
  Map<String, Treatment> treatments = {};
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    title = CustomTextFormField(
        context: context,
        typeInput: TextInputType.text,
        isValid: treatmentNameValidation,
        contentController: nameController,
        hintText: translate("typeHere"));
    price = CustomTextFormField(
        context: context,
        typeInput: TextInputType.number,
        isValid: priceValidation,
        contentController: priceController,
        hintText: translate("priceInShekels"));

    workerProvider = context.watch<WorkerProvider>();

    treatments = WorkerData.worker.treatments;
    return Scaffold(
        appBar: AppBar(
          actions: [
            infoButton(
                context: context, text: translate("hereYouAddTreatments"))
          ],
          elevation: 0,
          title: Text(translate("myTreatments")),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: gWidth,
              child: WorkerData.worker.treatments.keys.length == 0
                  ? emptyTreatments(context)
                  : allTreatmentsAndAdd(context),
            ),
          ),
        ));
  }

  Widget emptyTreatments(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
            child: Column(children: [
      SizedBox(
        width: gWidth * .95,
        child: Text(
          translate('TreatmentsNotify'),
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          textAlign: TextAlign.center,
        ),
      ),
      AddTreatment(
        scrollController: scrollController,
      )
    ])));
  }

  Widget allTreatmentsAndAdd(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: gWidth * .9,
            child: Text(
              translate('TreatmentsNotify'),
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: SizedBox(
              width: gWidth * .95,
              child: ListView.builder(
                  controller: scrollController,
                  itemCount: WorkerData.worker.treatments.keys.length + 1,
                  itemBuilder: ((context, index) {
                    if (index == WorkerData.worker.treatments.keys.length) {
                      return WorkerData.worker.treatments.length >=
                              treatmentLimit
                          ? Container(
                              alignment: Alignment.center,
                              width: gWidth * 0.6,
                              height: gHeight * 0.3,
                              child: Text(
                                translate("crossTreatmentLimit"),
                                textAlign: TextAlign.center,
                              ))
                          : AddTreatment(scrollController: scrollController);
                    }
                    Treatment treatment =
                        treatments[treatments.keys.elementAt(index)]!;
                    return TreatmentItem(
                      treatment: treatment,
                      treatmentName: treatments.keys.elementAt(index),
                    );
                  })),
            ),
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}

class ShowPrice extends StatefulWidget {
  static bool showPrice = true;
  final bool initVal;
  ShowPrice({super.key, this.initVal = true});

  @override
  State<ShowPrice> createState() => _ShowPriceState();
}

class _ShowPriceState extends State<ShowPrice> {
  @override
  void initState() {
    ShowPrice.showPrice = widget.initVal;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(translate("showPrice")),
        Checkbox(
          value: ShowPrice.showPrice,
          onChanged: (value) => setState(() {
            ShowPrice.showPrice = value!;
          }),
        )
      ],
    );
  }
}

class ShowTime extends StatefulWidget {
  static bool showTime = true;
  final bool initVal;
  ShowTime({super.key, this.initVal = true});

  @override
  State<ShowTime> createState() => _ShowTimeState();
}

class _ShowTimeState extends State<ShowTime> {
  @override
  void initState() {
    ShowTime.showTime = widget.initVal;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(translate("showTime")),
        Checkbox(
          value: ShowTime.showTime,
          onChanged: (value) => setState(() {
            ShowTime.showTime = value!;
          }),
        )
      ],
    );
  }
}
