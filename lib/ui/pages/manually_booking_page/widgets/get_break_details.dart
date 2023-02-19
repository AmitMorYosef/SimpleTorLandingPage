import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_toast.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/ui/general_widgets/pickers/color_picker.dart';
import 'package:management_system_app/ui/general_widgets/pickers/duration_picker.dart';
import 'package:management_system_app/ui/pages/worker_schedule_page/widgets/schedule_list.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/times_utlis.dart';
import 'package:management_system_app/utlis/validations_utlis.dart';
import 'package:provider/provider.dart';

import '/../utlis/string_utlis.dart';
import '../../../../app_const/application_general.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_const/times.dart';
import '../../../../app_statics.dart/worker_data.dart';
import '../../../../models/break_model.dart';
import '../../../../providers/booking_provider.dart';
import '../../../../utlis/general_utlis.dart';
import '../../../general_widgets/custom_widgets/custom_text_form_field.dart';

// ignore: must_be_immutable
class GetBreakDetails {
  TextEditingController nameController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  CustomTextFormField? nameField, noteField;
  late BookingProvider bookingProvider;
  late DurationPicker durationPicker = DurationPicker();
  late Duration limitDuration;

  Future<void> addBreakFields(BuildContext ancestorContext,
      {bool needDuration = true,
      String? day,
      String? start,
      Duration? duration}) async {
    bookingProvider = ancestorContext.read<BookingProvider>();
    limitDuration = findLimitDuration();
    durationPicker = DurationPicker(
        jump: 5,
        limitData: {TimeUnit.hour: limitDuration.inHours, TimeUnit.minute: 60});
    nameField = CustomTextFormField(
        context: ancestorContext,
        contentController: nameController,
        isValid: breakNameValidation,
        typeInput: TextInputType.text,
        hintText: translate('breakType') + " (" + translate("optional") + ")");

    noteField = CustomTextFormField(
        context: ancestorContext,
        contentController: noteController,
        typeInput: TextInputType.text,
        isValid: noteValidation,
        hintText: translate('note') + " (" + translate("optional") + ")");

    bool? resp = await getCustomerDetailsDialog(ancestorContext,
        needDuration: needDuration);

    if (resp == true) {
      final breakModel = BreakModel(
          title: nameController.text,
          note: noteController.text,
          day: day ??
              DateFormat('dd-MM-yyyy').format(DateTime.parse(
                  BookingProvider.booking.bookingDate.toIso8601String())),
          start: start ??
              DateFormat('HH:mm').format(DateTime.parse(
                  BookingProvider.booking.bookingDate.toIso8601String())),
          color: ColorPicker.selectedColor,
          duration: duration ?? mapToDuration(durationPicker.data));
      await Loading(
              animation: successAnimation,
              context: ancestorContext,
              future: WorkerData.addBreak(breakModel),
              msg: translate("breakAddedSuccessfully"),
              navigator: Navigator.of(ancestorContext))
          .dialog();
      if (needDuration) {
        Navigator.pop(ancestorContext);
      }
    } else {
      UiManager.updateUi(
          context: ancestorContext,
          perform: Future(() => BookingProvider.setBreak(false)));
    }
    overLaysHandling();
  }

  Future<bool?> getCustomerDetailsDialog(BuildContext context,
      {bool needDuration = true}) async {
    return await genralDialog(
      context: context,
      title: translate('breakDetails'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 10,
          ),
          nameField!,
          SizedBox(
            height: 20,
          ),
          noteField!,
          SizedBox(
            height: needDuration ? 20 : 0,
          ),
          needDuration
              ? Text(
                  translate("pickDuration"),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                )
              : SizedBox(),
          needDuration ? durationPicker.pickerWidget(context) : SizedBox(),
          SizedBox(
            height: 20,
          ),
          Text(
            translate("colorOfBreak"),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 5,
          ),
          ColorPicker()
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text(translate('cancel')),
        ),
        TextButton(
          onPressed: () {
            if (!noteField!.contentValid) {
              return;
            }
            if (mapToDuration(durationPicker.data).inMinutes == 0 &&
                needDuration) {
              CustomToast(
                      context: context,
                      msg: translate("durationMustBeGratherThenZero"))
                  .init();
              return;
            }
            if (limitDuration.compareTo(mapToDuration(durationPicker.data)) <
                    0 &&
                needDuration) {
              CustomToast(context: context, msg: translate("eventsStriking"))
                  .init();
              return;
            }
            Navigator.pop(context, true);
          },
          child: Text(translate('save')),
        ),
      ],
    );
  }

  Duration findLimitDuration() {
    /*find the longest duration that worker can make a break 
      - check the events time for overlaping events*/
    try {
      ScheduleList.eventsTimes.add(ScheduleList.endOfWorkTimes);

      final start = setTo1970(BookingProvider.booking.bookingDate);

      ScheduleList.eventsTimes.sort();

      DateTime? closestTime;

      /*get the closest event to the time that the worker want to make a break*/
      for (final event in ScheduleList.eventsTimes) {
        if (event.isAfter(start)) {
          closestTime = event;
          break;
        }
      }

      final hours = closestTime!.hour - start.hour;
      final minutes = closestTime.minute - start.minute;

      /*make the limit duration that worker can make a break */
      return Duration(hours: hours, minutes: minutes);
    } catch (e) {
      logger.e("Error while compute duration for break --> $e");
      return Duration();
    }
  }
}
