import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

import '../../../app_const/app_sizes.dart';
import '../../../services/in_app_services.dart/language.dart';

class TimeOfDayPicker {
  DateTime? currentTime;

  bool onlyShowDays;
  Color? backgroundColor;
  double? height;
  Widget title;
  int jump;
  TimeOfDayPicker(
      {this.onlyShowDays = false,
      this.jump = 1,
      this.title = const SizedBox(),
      this.backgroundColor,
      this.height});

  Future<void> show24HoursPickerModal(
      BuildContext context, DateTime? initTime) async {
    if (initTime == null) {
      initTime = DateTime.now();
    }
    currentTime = null;
    await Picker(
        title: title,
        cancelText: translate("cancel"),
        confirmText: translate("save"),
        delimiter: [
          PickerDelimiter(
              child: Container(
                  color: Theme.of(context).colorScheme.background,
                  alignment: Alignment.center,
                  child: Text(
                    ":",
                    style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.secondary),
                  )))
        ],
        confirmTextStyle: TextStyle(fontWeight: FontWeight.bold),
        cancelTextStyle: TextStyle(fontWeight: FontWeight.bold),
        adapter: NumberPickerAdapter(
            data: ApplicationLocalizations.of(context)!.isRTL()
                ? [
                    NumberPickerColumn(
                        jump: jump,
                        begin: 0,
                        end: 55,
                        initValue: initTime.minute),
                    NumberPickerColumn(
                        begin: 0, end: 23, initValue: initTime.hour),
                  ]
                : [
                    NumberPickerColumn(
                        begin: 0, end: 23, initValue: initTime.hour),
                    NumberPickerColumn(
                        jump: jump,
                        begin: 0,
                        end: 55,
                        initValue: initTime.minute),
                  ]),
        selectedTextStyle:
            TextStyle(color: Theme.of(context).colorScheme.secondary),
        height: gHeight * 0.3,
        headerColor: Theme.of(context).colorScheme.background,
        backgroundColor: Theme.of(context).colorScheme.background,
        hideHeader: false,
        onConfirm: (Picker picker, List value) {
          currentTime = ApplicationLocalizations.of(context)!.isRTL()
              ? DateTime(0, 0, 0, value[1], value[0] * 5)
              : DateTime(0, 0, 0, value[0], value[1] * 5);
        }).showModal(context);
  }
}
