import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';

import '../../../app_const/app_sizes.dart';
import '../../../app_const/times.dart';
import '../../../services/in_app_services.dart/language.dart';

class DurationPicker {
  Map<TimeUnit, int> data = {
    TimeUnit.day: 0,
    TimeUnit.hour: 0,
    TimeUnit.minute: 0,
    TimeUnit.seconds: 0
  };
  Map<TimeUnit, int> initData;
  Map<TimeUnit, int> limitData;
  bool onlyShowDays;
  Color? backgroundColor;
  double? height;
  Widget title;
  int jump;
  DurationPicker(
      {this.onlyShowDays = false,
      this.jump = 1,
      this.title = const SizedBox(),
      this.initData = const {
        TimeUnit.day: 0,
        TimeUnit.hour: 0,
        TimeUnit.minute: 0,
        TimeUnit.seconds: 0
      },
      this.limitData = const {
        TimeUnit.day: 365,
        TimeUnit.hour: 24,
        TimeUnit.minute: 60,
        TimeUnit.seconds: 60
      },
      this.backgroundColor,
      this.height});

  Future<void> showPickerModal(BuildContext context) async {
    this.data = initData;
    await Picker(
        title: title,
        cancelText: translate("cancel"),
        confirmText: translate("save"),
        confirmTextStyle: TextStyle(fontWeight: FontWeight.bold),
        cancelTextStyle: TextStyle(fontWeight: FontWeight.bold),
        adapter: onlyShowDays
            ? NumberPickerAdapter(data: [
                NumberPickerColumn(
                    suffix: Text(
                      " " + translate("days"),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    begin: 0,
                    end: limitData[TimeUnit.day]!,
                    initValue: initData[TimeUnit.day]),
              ])
            : NumberPickerAdapter(data: [
                NumberPickerColumn(
                    suffix: Text(
                      " " + translate("days"),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    begin: 0,
                    end: limitData[TimeUnit.day]!,
                    initValue: initData[TimeUnit.day]),
                NumberPickerColumn(
                    suffix: Text(
                      " " + translate("hours"),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    begin: 0,
                    end: limitData[TimeUnit.hour]!,
                    initValue: initData[TimeUnit.hour]),
                NumberPickerColumn(
                    suffix: Text(
                      " " + translate("minutes"),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    begin: 0,
                    end: limitData[TimeUnit.minute]!,
                    initValue: initData[TimeUnit.minute]),
              ]),
        selectedTextStyle:
            TextStyle(color: Theme.of(context).colorScheme.secondary),
        height: gHeight * 0.3,
        headerColor: Theme.of(context).colorScheme.background,
        backgroundColor: Theme.of(context).colorScheme.background,
        hideHeader: false,
        onConfirm: (Picker picker, List value) {
          while (value.length < 3) value.add(0);
          this.data = {
            TimeUnit.day: value[0],
            TimeUnit.hour: value[1],
            TimeUnit.minute: value[2],
          };
        }).showModal(context);
  }

  Widget pickerWidget(BuildContext context) {
    this.data = initData;
    return Picker(
        confirmTextStyle: TextStyle(fontWeight: FontWeight.bold),
        cancelTextStyle: TextStyle(fontWeight: FontWeight.bold),
        adapter: NumberPickerAdapter(
            data: ApplicationLocalizations.of(context)!.isRTL()
                ? [
                    NumberPickerColumn(
                        suffix: Text(
                          " " + translate("minutes"),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        jump: jump,
                        end: limitData[TimeUnit.minute]!,
                        initValue: initData[TimeUnit.minute]),
                    NumberPickerColumn(
                        suffix: Text(
                          " " + translate("hours"),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        begin: 0,
                        end: limitData[TimeUnit.hour]!,
                        initValue: initData[TimeUnit.hour]),
                  ]
                : [
                    NumberPickerColumn(
                        suffix: Text(
                          " " + translate("hours"),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        begin: 0,
                        end: limitData[TimeUnit.hour]!,
                        initValue: initData[TimeUnit.hour]),
                    NumberPickerColumn(
                        suffix: Text(
                          " " + translate("minutes"),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        jump: jump,
                        end: limitData[TimeUnit.minute]!,
                        initValue: initData[TimeUnit.minute])
                  ]),
        //textStyle: TextStyle(color: Colors.white),
        selectedTextStyle:
            TextStyle(color: Theme.of(context).colorScheme.secondary),
        backgroundColor:
            this.backgroundColor ?? Theme.of(context).colorScheme.background,
        hideHeader: true,
        magnification: 1.0,
        diameterRatio: 1.1,
        squeeze: 1.45,
        height: this.height ?? 150,
        onSelect: (Picker __, int _, List value) {
          this.data = ApplicationLocalizations.of(context)!.isRTL()
              ? {
                  TimeUnit.hour: value[1],
                  TimeUnit.minute: (value[0] ?? 0) * jump,
                }
              : {
                  TimeUnit.hour: value[0],
                  TimeUnit.minute: (value[1] ?? 0) * jump,
                };
        }).makePicker();
  }

  Widget pickerWidgetSeconds(BuildContext context, int begin) {
    this.data = initData;
    return Picker(
        confirmTextStyle: TextStyle(fontWeight: FontWeight.bold),
        cancelTextStyle: TextStyle(fontWeight: FontWeight.bold),
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(
              suffix: Text(
                " " + translate("seconds"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              begin: begin,
              end: limitData[TimeUnit.seconds]!,
              initValue: initData[TimeUnit.seconds]),
        ]),
        selectedTextStyle:
            TextStyle(color: Theme.of(context).colorScheme.secondary),
        backgroundColor: Theme.of(context).colorScheme.background,
        hideHeader: true,
        onSelect: (Picker __, int _, List value) {
          this.data = {
            TimeUnit.seconds: (value[0] ?? 0) + begin,
          };
        }).makePicker();
  }
}

Duration mapToDuration(Map<TimeUnit, int> map) {
  return Duration(
    days: map[TimeUnit.day] ?? 0,
    hours: map[TimeUnit.hour] ?? 0,
    minutes: map[TimeUnit.minute] ?? 0,
  );
}

Map<TimeUnit, int> durationToMap(Duration duration) {
  return {
    TimeUnit.day: duration.inDays,
    TimeUnit.hour: duration.inHours - (duration.inDays * 24),
    TimeUnit.minute: duration.inMinutes - (duration.inHours * 60),
  };
}
