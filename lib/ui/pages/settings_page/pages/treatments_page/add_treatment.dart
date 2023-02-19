import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:management_system_app/providers/worker_provider.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/pickers/duration_picker.dart';
import 'package:management_system_app/ui/general_widgets/pickers/price_picker.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/treatments_page/treatments.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:management_system_app/utlis/validations_utlis.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../../app_const/times.dart';
import '../../../../../app_statics.dart/worker_data.dart';
import '../../../../general_widgets/buttons/info_button.dart';
import '../../../../general_widgets/custom_widgets/custom_text_form_field.dart';
import '../../../../general_widgets/custom_widgets/custom_toast.dart';
import '../../../../general_widgets/loading_widgets/loading_dialog.dart';

class AddTreatment extends StatefulWidget {
  final ScrollController scrollController;
  AddTreatment({super.key, required this.scrollController});

  @override
  State<AddTreatment> createState() => _AddTreatmentState();
}

class _AddTreatmentState extends State<AddTreatment> {
  bool firstState = true;
  late CustomTextFormField title;
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  Map<String, DurationPicker> times = {};
  PricePicker priceField = PricePicker();
  /*
  {
    0 -> {
      duration: DurationPicker,
      break: 30
    },
    1 -> {
      duration: DurationPicker,
      break: 50
    }
  }
  */
  Map<String, Widget> timePickers = {};
  List<DurationPicker> breaksDurations = [];
  List<TextEditingController> titles = [];
  List<CustomTextFormField> textFormFields = [];
  @override
  void initState() {
    title = CustomTextFormField(
        context: context,
        typeInput: TextInputType.text,
        isValid: treatmentNameValidation,
        contentController: nameController,
        hintText: translate("typeHere"));

    super.initState();
  }

  void generatePickers(BuildContext context) {
    if (firstState) {
      // addin gthe first duration picker
      times['0'] = DurationPicker(
          jump: 5,
          initData: const {
            TimeUnit.day: 0,
            TimeUnit.hour: 0,
            TimeUnit.minute: 0,
          },
          height: 70,
          backgroundColor: Theme.of(context).colorScheme.tertiary);
      timePickers['0'] = CustomContainer(
        image: null,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 10),
        color: Theme.of(context).colorScheme.tertiary,
        child: Column(
          children: [
            Text(translate("treatmentTimes") + ":"),
            Container(
                padding: EdgeInsets.all(10),
                child: times['0']!.pickerWidget(context)),
          ],
        ),
      );
      firstState = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    generatePickers(context);

    return Container(
      margin: EdgeInsets.only(left: 5, right: 5, top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DottedBorder(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              dashPattern: [25],
              strokeWidth: 3,
              color: Colors.grey.withOpacity(0.5),
              borderType: BorderType.RRect,
              radius: Radius.circular(20),
              child: Column(
                children: [
                  Text(translate("treatmentType") + ":"),
                  SizedBox(height: 10),
                  title,
                  SizedBox(height: 10),
                  Text(translate("price") + ":"),
                  SizedBox(height: 10),
                  priceField,
                  SizedBox(height: 20),

                  //Text(translate("duration") + ":"),
                  Column(
                    children: timePickers.values.toList(),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(translate("additionalTimes")),
                      infoButton(
                          context: context,
                          text: translate("tretmentTimesExplain"))
                    ],
                  ),
                  addTimeSegmentButton(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShowTime(),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        height: 25,
                        width: 1,
                        color: Colors.grey,
                      ),
                      ShowPrice(),
                    ],
                  ),
                ],
              )),
          SizedBox(
            height: 20,
          ),
          saveNewProduct(context)
        ],
      ),
    );
  }

  Widget addTimeSegmentButton() {
    return DottedBorder(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        dashPattern: [25],
        strokeWidth: 3,
        color: Colors.grey.withOpacity(0.5),
        borderType: BorderType.RRect,
        radius: Radius.circular(20),
        child: GestureDetector(
            onTap: () {
              setState(() {
                // createing new key (according to index) & durationPicker
                String newKey = Uuid().v1();
                DurationPicker segmentDurationPicker = DurationPicker(
                    jump: 5,
                    initData: const {
                      TimeUnit.day: 0,
                      TimeUnit.hour: 0,
                      TimeUnit.minute: 0,
                    },
                    height: 70,
                    backgroundColor: Theme.of(context).colorScheme.tertiary);
                DurationPicker breakDurationPicker = DurationPicker(
                    jump: 5,
                    initData: const {
                      TimeUnit.day: 0,
                      TimeUnit.hour: 0,
                      TimeUnit.minute: 0,
                    },
                    height: 70,
                    backgroundColor: Theme.of(context).colorScheme.tertiary);
                TextEditingController controller = TextEditingController();
                //
                CustomTextFormField textForm = CustomTextFormField(
                    context: context,
                    typeInput: TextInputType.text,
                    isValid: treatmentNameValidation,
                    contentController: controller,
                    hintText: translate("typeHere"));
                // adding text controller to get the name of the segment
                titles.add(controller);
                // addint the customTextFormField to validate it later
                textFormFields.add(textForm);
                // adding the duration to times for getting the value later
                times[newKey] = segmentDurationPicker;
                // adding the break duration to get it later
                breaksDurations.add(breakDurationPicker);
                // addind duration and picker objects to diaplay
                Widget widget = Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  padding: EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      CustomContainer(
                        image: null,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        color: Theme.of(context).colorScheme.tertiary,
                        child: Column(
                          children: [
                            Text(translate("timeBetweenSegments")),
                            //SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: breakDurationPicker.pickerWidget(context),
                            ),
                            //textForm,
                            SizedBox(height: 10),
                            Text(translate("segmentTime")),
                            Container(
                              //margin: EdgeInsets.symmetric(vertical: 10),
                              padding: EdgeInsets.all(10),
                              child:
                                  segmentDurationPicker.pickerWidget(context),
                            ),
                            Text(translate("segmentName")),
                            SizedBox(
                              height: 10,
                            ),
                            textForm,
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    // title removal
                                    titles.remove(controller);
                                    textFormFields.remove(textForm);
                                    // segment data removal
                                    times.remove(newKey);
                                    // break removal
                                    breaksDurations.remove(breakDurationPicker);
                                    // duration removal
                                    timePickers.remove(newKey);
                                  });
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                );
                timePickers[newKey] = widget;
                //timePickers.add();
              });
            },
            child: Icon(
              Icons.add,
              size: 40,
            )));
  }

  Widget saveNewProduct(BuildContext context) {
    return CustomContainer(
      onTap: () async => await onTapSave(),
      padding: EdgeInsets.symmetric(vertical: 10),
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
      needImage: false,
      alignment: Alignment.center,
      raduis: 999,
      color: Theme.of(context).colorScheme.secondary,
      child: Text(
        translate("save"),
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Future<void> onTapSave() async {
    Map<String, Map<String, dynamic>> treatmentTimes = {};
    bool allValid = true;
    if (!title.contentValid) {
      allValid = false;
    }
    if (nameController.text == '') {
      title.check!("");
      allValid = false;
    }

    textFormFields.asMap().forEach((index, textForm) {
      if (!textForm.contentValid) {
        allValid = false;
      }
      if (titles[index].text == '') {
        textForm.check!("");
        allValid = false;
      }
    });
    if (WorkerData.worker.treatments.containsKey(nameController.text)) {
      CustomToast(
              context: context, msg: translate("thereIsAlreadyTreatmentName"))
          .init();
      return;
    }

    if (!allValid) {
      return;
    }
    int index = 0;
    bool timeHasNoZero = true;
    times.forEach((key, value) {
      int itemBreak = 0;
      String title = "";
      if (index < breaksDurations.length) {
        itemBreak = mapToDuration(breaksDurations[index].data).inMinutes;
      }
      if (index - 1 >= 0 && index - 1 < titles.length) {
        title = titles[index - 1].text;
      }
      final minutes = mapToDuration(value.data).inMinutes;
      if (minutes == 0) {
        timeHasNoZero = false;
      }
      Map<String, dynamic> time = {
        'duration': minutes,
        'break': itemBreak,
        'title': title
      };
      treatmentTimes[index.toString()] = time;
      index++;
    });

    if (!priceField.contentValid) {
      if (priceField.price.amount == 0) {
        priceField.check!("");
      }
      return;
    }

    if (!timeHasNoZero) {
      CustomToast(
              context: context, msg: translate("durationMustBeGratherThenZero"))
          .init();
      return;
    }
    if (widget.scrollController.hasClients)
      widget.scrollController.animateTo(0,
          duration: Duration(milliseconds: 200), curve: Curves.bounceIn);

    await Loading(
            context: context,
            navigator: Navigator.of(context),
            msg: translate("treatmentSuccessfullyCreated"),
            future: context.read<WorkerProvider>().addOrUpdateTreatment({
              "price": priceField.price.toJson(),
              "times": treatmentTimes,
              "showTime": ShowTime.showTime,
              "showPrice": ShowPrice.showPrice
            }, nameController.text, context))
        .dialog();
  }
}
