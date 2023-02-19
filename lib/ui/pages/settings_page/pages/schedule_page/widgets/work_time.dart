import 'dart:io';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/app_statics.dart/user_data.dart';
import 'package:management_system_app/providers/user_provider.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_toast.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:management_system_app/utlis/times_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../../../app_const/app_sizes.dart';
import '../../../../../../app_const/platform.dart';
import '../../../../../../app_statics.dart/settings_data.dart';
import '../../../../../../app_statics.dart/worker_data.dart';
import '../../../../../../models/notification_topic.dart';
import '../../../../../../providers/worker_provider.dart';
import '../../../../../../utlis/validations_utlis.dart';
import '../../../../../general_widgets/buttons/info_button.dart';
import '../../../../../general_widgets/pickers/time_of_day_picker.dart';

DateTime? startTime, endTime;
List<String> daysToQuickAdd = [];
final daysOfWeek = [
  'sunday',
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday'
];

// ignore: must_be_immutable
class WorkTime extends StatefulWidget {
  Map<String, List<String>> initialWorkTime;

  WorkTime({super.key, required this.initialWorkTime});

  @override
  State<WorkTime> createState() => _WorkTimeState();
}

class _WorkTimeState extends State<WorkTime> {
  late WorkerProvider workerProvider;

  late UserProvider userProvider;

  late Set<String> days = {};

  @override
  void dispose() {
    super.dispose();
    Function deepEq = const DeepCollectionEquality().equals;
    if (!deepEq(WorkerData.worker.workTime, widget.initialWorkTime)) {
      notifyRelevantDays();
      WorkerData.saveWorkTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    workerProvider = context.watch<WorkerProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        title: Text(translate("shifts")),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: IconButton(
                onPressed: () {
                  startTime = null;
                  endTime = null;
                  showQuickAddDialog(context);
                },
                icon: Icon(Icons.add_box)),
          ),
          infoButton(context: context, text: translate("hereYouAddWorkTime"))
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              dayItem(context, "sunday"),
              dayItem(context, "monday"),
              dayItem(context, "tuesday"),
              dayItem(context, "wednesday"),
              dayItem(context, "thursday"),
              dayItem(context, "friday"),
              dayItem(context, "saturday"),
            ],
          ),
        ),
      ),
    );
  }

  Widget dayItem(BuildContext context, String day) {
    return CustomContainer(
      width: gWidth * .95,
      height: gHeight * 0.1,
      image: null,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(translate(day)),
              SizedBox(width: 5),
              BouncingWidget(
                child: Container(
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        shape: BoxShape.circle),
                    child: Icon(
                      Icons.add,
                      size: 15,
                      color: Theme.of(context).colorScheme.secondary,
                    )),
                onPressed: () {
                  endTime = null;
                  startTime = null;
                  showTimesDialog(context, day);
                },
              ),
            ],
          ),
          WorkerData.worker.workTime[day]!.length == 0
              ? Text(
                  translate("noShiftsForToday"),
                  style: TextStyle(color: Colors.grey),
                )
              : Expanded(
                  child: Center(
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        //primary: true,
                        shrinkWrap: true,
                        itemCount: (WorkerData.worker.workTime[day]!.length / 2)
                            .round(),
                        itemBuilder: ((context, index) {
                          DateTime startWork = DateFormat("HH:mm").parse(
                              WorkerData.worker.workTime[day]![index * 2]);
                          DateTime endWork = DateFormat("HH:mm").parse(
                              WorkerData.worker.workTime[day]![index * 2 + 1]);

                          return singleTimeItem(
                              startWork, endWork, day, context);
                        })),
                  ),
                ),
        ],
      ),
    );
  }

  Widget singleTimeItem(
      DateTime start, DateTime end, String day, BuildContext ctx) {
    return CustomContainer(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      height: gHeight * 0.05,
      padding: EdgeInsets.symmetric(horizontal: 10),
      image: null,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                translate("start") + ": " + dateToString(start),
                textAlign: TextAlign.center,
              ),
              Text(
                translate("end") + ": " + dateToString(end),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(width: 5),
          BouncingWidget(
            child: Container(
                padding: EdgeInsets.all(5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    shape: BoxShape.circle),
                child: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.secondary,
                )),
            onPressed: () {
              UiManager.updateUi(
                  context: ctx,
                  perform: Future(() => workerProvider.removeTimeFromDay(
                      DateFormat('HH:mm').format(start),
                      DateFormat('HH:mm').format(end),
                      day)));
            },
          )
        ],
      ),
    );
  }

  void showTimesDialog(BuildContext context, String day) {
    genralDialog(
      context: context,
      title: translate("addTime"),
      content: AddTimeContent(),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: Text(translate("cancel")),
        ),
        TextButton(
          onPressed: () {
            if (endTime != null && startTime != null) {
              if (timeValidation(DateFormat('HH:mm').format(startTime!)) !=
                      '' ||
                  timeValidation(DateFormat('HH:mm').format(endTime!)) != '') {
                CustomToast(
                  context: context,
                  msg: translate("timeNeedToEndWth0or5"), // message
                  // length
                  gravity: ToastGravity.BOTTOM, // location
                ).init();
              }
              if (isTimeStrike(WorkerData.worker.workTime[day] ?? [],
                  startTime!, endTime!)) {
                CustomToast(
                  context: context,
                  msg: translate("timesStrike"), // message
                  // length
                  gravity: ToastGravity.BOTTOM, // location
                ).init();
              } else {
                this.days.add(day);
                UiManager.updateUi(
                    context: context,
                    perform: Future(() => workerProvider.addTimeToDay(
                        DateFormat('HH:mm').format(startTime!),
                        DateFormat('HH:mm').format(endTime!),
                        day)));

                Navigator.pop(context);
              }
            } else {
              CustomToast(
                context: context,
                msg: endTime == null && startTime == null
                    ? translate("twoFieldsNotfilled")
                    : translate("oneOfTheFieldNotFilled"), // message
                // length
                gravity: ToastGravity.BOTTOM, // location
              ).init();
            }
          },
          child: Text(translate("save")),
        ),
      ],
    );
  }

  bool isTimeStrike(List<String> todayTimes, DateTime start, DateTime end) {
    bool strike = false;
    List<DateTime> currentTimes = convertStringToTime(todayTimes);
    start = setTo1970(start);
    end = setTo1970(end);
    for (var i = 0; i < currentTimes.length; i += 2) {
      if (durationStrikings(currentTimes[i], currentTimes[i + 1], start, end) ==
          'STRIKE') {
        strike = true;
        break;
      }
    }
    return strike;
  }

  Future<bool> showSaveDialog(BuildContext context) async {
    await genralDialog(
      context: context,
      title: translate("save"),
      content: Container(
        alignment: Alignment.center,
        height: gHeight * .1,
        child: Text(translate("doYouWantToSave")),
      ),
      actions: [
        TextButton(
          onPressed: () {
            workerProvider.setWorkTime(widget.initialWorkTime);
            days = {};
            Navigator.pop(context, true);
          },
          child: Text(translate("dontSave")),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(translate("save")),
        ),
      ],
    );
    return true;
  }

  void showQuickAddDialog(BuildContext context) {
    genralDialog(
      animationType: DialogTransitionType.scale,
      context: context,
      title: translate("quickAdd"),
      content: quickAddContent(context),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'Cancel');
          },
          child: Text(translate("cancel")),
        ),
        TextButton(
          onPressed: () {
            if (endTime != null && startTime != null) {
              if (timeValidation(DateFormat('HH:mm').format(endTime!)) != '' ||
                  timeValidation(DateFormat('HH:mm').format(startTime!)) !=
                      '') {
                CustomToast(
                  context: context,
                  msg: translate("timeNeedToEndWth0or5"), // message
                  // length
                  gravity: ToastGravity.BOTTOM, // location
                ).init();
              } else {
                bool hasError = false;
                daysToQuickAdd.forEach((day) {
                  if (isTimeStrike(
                      WorkerData.worker.workTime[day]!, startTime!, endTime!)) {
                    hasError = true;
                    return;
                  }
                  days.add(day);
                  UiManager.updateUi(
                      context: context,
                      perform: Future(() => workerProvider.addTimeToDay(
                          DateFormat('HH:mm').format(startTime!),
                          DateFormat('HH:mm').format(endTime!),
                          day)));
                });
                if (hasError) {
                  CustomToast(
                    context: context,
                    msg: translate("addShftsQuiqError"), // message
                    toastLength: Duration(seconds: 3),
                    gravity: ToastGravity.BOTTOM, // location
                  ).init();
                }
                Navigator.pop(context, 'Ok');
                daysToQuickAdd = [];
              }
            } else {
              CustomToast(
                context: context,
                msg: endTime == null && startTime == null
                    ? translate("twoFieldsNotfilled")
                    : translate("oneOfTheFieldNotFilled"), // message
                // length
                gravity: ToastGravity.BOTTOM, // location
              ).init();
            }
          },
          child: Text(translate("save")),
        ),
      ],
    );
  }

  Widget quickAddContent(BuildContext context) {
    return SizedBox(
        child: SingleChildScrollView(
      child: Column(
        children: [
          AddTimeContent(),
          SizedBox(
            height: gHeight * 0.02,
          ),
          Text(
            translate("pickDays"),
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 12),
          ),
          ListOfdays()
        ],
      ),
    ));
  }

  void notifyRelevantDays() {
    DateTime time = DateTime.now();
    DateTime nexWeek = time.add(Duration(days: 7));
    while (time.isBefore(nexWeek)) {
      String weekDay = DateFormat('EEEE').format(time).toLowerCase();
      if (days.contains(weekDay)) {
        // notify new bookings
        String bookingDate = DateFormat('dd-MM-yyyy').format(time);
        logger.d("Notify new bookings in --> $bookingDate");
        UserData.notifyCanceledBooking(NotificationTopic(
                businessId: SettingsData.appCollection,
                workerId: WorkerData.worker.phone,
                date: bookingDate,
                workerName: WorkerData.worker.name)
            .toTopicStr());
      }
      time = time.add(Duration(days: 1));
    }
  }
}

class AddTimeContent extends StatefulWidget {
  const AddTimeContent({super.key});

  @override
  State<AddTimeContent> createState() => _AddTimeContentState();
}

class _AddTimeContentState extends State<AddTimeContent> {
  final timePicker = TimeOfDayPicker(jump: 5);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(translate("start") + ": "),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
                onTap: () async {
                  await timePicker
                      .show24HoursPickerModal(context, startTime)
                      .whenComplete(() => setState(() {
                            if (timePicker.currentTime != null) {
                              startTime = timePicker.currentTime;
                            }
                          }));

                  if (endTime != null &&
                      endTime!.millisecondsSinceEpoch <=
                          startTime!.millisecondsSinceEpoch) {
                    CustomToast(
                            context: context,
                            msg: translate("endTimeBeforeStart"))
                        .init();
                    endTime = null;
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2,
                        color: Theme.of(context).colorScheme.onBackground),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, size: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(startTime != null
                            ? dateToString(startTime!)
                            : translate("enterTime")),
                      ),
                    ],
                  ),
                )),
            Divider(),
            Text(translate("end") + ": "),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
                onTap: () async {
                  await timePicker
                      .show24HoursPickerModal(context, endTime)
                      .whenComplete(() => setState(() {
                            if (timePicker.currentTime != null) {
                              endTime = timePicker.currentTime;
                            }
                          }));

                  if (endTime == null) return;

                  if (startTime == null) {
                    CustomToast(
                            context: context,
                            msg: translate("startTimeNotBeenSelected"))
                        .init();
                    endTime = null;
                    return;
                  }

                  if (endTime!.millisecondsSinceEpoch <=
                      startTime!.millisecondsSinceEpoch) {
                    CustomToast(
                            context: context,
                            msg: translate("endTimeBeforeStart"))
                        .init();
                    endTime = null;
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2,
                        color: Theme.of(context).colorScheme.onBackground),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, size: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(endTime != null
                            ? dateToString(endTime!)
                            : translate("enterTime")),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class ListOfdays extends StatefulWidget {
  const ListOfdays({super.key});

  @override
  State<ListOfdays> createState() => _ListOfdaysState();
}

class _ListOfdaysState extends State<ListOfdays> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: listOfDays(),
    );
  }

  List<Widget> listOfDays() {
    List<Widget> dayObjects = [];
    daysOfWeek.forEach((day) {
      dayObjects.add(ListTile(
        title: Text(translate(day)),
        leading: Checkbox(
            value: daysToQuickAdd.contains(day),
            onChanged: (value) {
              if (value == true) {
                daysToQuickAdd.add(day);
                setState(() {});
              } else {
                daysToQuickAdd.remove(day);
                setState(() {});
              }
            }),
      ));
    });
    return dayObjects;
  }
}

double timeOfDaytoDouble(TimeOfDay myTime) =>
    myTime.hour + myTime.minute / 60.0;

String dateToString(DateTime myTime) {
  if (isWeb) return DateFormat('HH:mm').format(myTime);
  final countryCode = Platform.localeName.split("_")[1];

  if (countryCode == "US")
    return DateFormat('hh:mm a').format(myTime);
  else {
    return DateFormat('HH:mm').format(myTime);
  }
}
