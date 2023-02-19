import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:lottie/lottie.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../../../../app_const/app_sizes.dart';
import '../../../../../../../app_const/resources.dart';
import '../../../../../../../app_statics.dart/worker_data.dart';
import '../../../../../../../providers/worker_provider.dart';
import '../../../../../../../services/in_app_services.dart/language.dart';
import '../../../../../../../utlis/times_utlis.dart';
import '../../../../../../general_widgets/buttons/info_button.dart';
import '../../../../../../general_widgets/custom_widgets/custom_toast.dart';
import '../../../../../../general_widgets/dialogs/general_delete_dialog.dart';
import '../../../../../../general_widgets/loading_widgets/loading_dialog.dart';

TimeOfDay? startTime, endTime;

// ignore: must_be_immutable
class Vacations extends StatefulWidget {
  Vacations({super.key});

  @override
  State<Vacations> createState() => _VacationsState();
}

class _VacationsState extends State<Vacations> {
  late WorkerProvider workerProvider;

  Map<DateTime, DateTime> timeSegments = {}; // {1-1-1999: 3-1-1999} start:end
  List<DateTime> rangesToDelete = [];
  late Set<String> days = {};

  @override
  void initState() {
    super.initState();
    initialSerments();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initialSerments() {
    timeSegments = {};
    List<DateTime> vacationDays =
        (convertStringToDateTime(WorkerData.worker.vacations.keys.toList()));
    vacationDays.sort();
    DateTime? start;
    for (int i = 0; i < vacationDays.length - 1; i++) {
      if (start == null) {
        start = vacationDays[i];
      }
      if (vacationDays[i].add(Duration(days: 1)) == vacationDays[i + 1]) {
        // inside sequence
        continue;
      } else {
        // end of sequence
        timeSegments[start] = vacationDays[i];
        start = null;
      }
    }
    if (start == null) {
      if (vacationDays.length == 0) {
        return;
      }
      // the last is not in the sequence
      timeSegments[vacationDays.last] = vacationDays.last;
    } else {
      // the last is in the sequence
      timeSegments[start] = vacationDays.last;
    }
  }

  Text textRangeToDisplay(DateTime start) {
    if (timeSegments[start] == start) {
      return Text(
        DateFormat('dd-MM-yyyy').format(start),
        textDirection: TextDirection.ltr,
        style:
            Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 18),
      );
    }
    return Text(
      '${DateFormat('dd-MM-yyyy').format(start)} - ${DateFormat('dd-MM-yyyy').format(timeSegments[start]!)}',
      textDirection: TextDirection.ltr,
      style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    workerProvider = context.watch<WorkerProvider>();
    return WillPopScope(
      onWillPop: () async {
        Map<String, List<String>> vacations = {};
        timeSegments.forEach((start, end) {
          DateTime copy = start;
          while (!copy.isAfter(end)) {
            vacations[DateFormat('dd-MM-yyyy').format(copy)] = [];
            copy = copy.add(Duration(days: 1));
          }
        });
        Function deepEq = const DeepCollectionEquality().equals;
        if (deepEq(vacations, WorkerData.worker.vacations)) {
          CustomToast(
                  context: context,
                  toastLength: const Duration(milliseconds: 800),
                  msg: translate('sameData'))
              .init();
          return true;
        }
        await Loading(
                displayErrorDuration: Duration(milliseconds: 2000),
                context: context,
                navigator: Navigator.of(context),
                future:
                    WorkerData.saveVacations(vacations: vacations, days: days),
                animation: successAnimation,
                msg: translate('UpdatedVacations'))
            .dialog();
        return true;
      },
      child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            actions: [
              infoButton(
                  context: context, text: translate("hereYouCanAddVacations"))
            ],
            elevation: 0,
            title: Center(child: Text(translate("vacationsDiary"))),
          ),
          body: GestureDetector(
            onTap: () {
              setState(() {
                rangesToDelete = [];
              });
            },
            child: Center(
              child: Column(
                children: [
                  deleteAllButton(),
                  timeSegments.length == 0
                      ? Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: gWidth * .95,
                                child: Text(
                                  translate("EmptyVacationsText"),
                                  style: Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Lottie.asset(vacationAnimation,
                                  height: gHeight * 0.43),
                            ],
                          ),
                        )
                      : Expanded(
                          child: SizedBox(
                            width: gWidth * .95,
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: timeSegments.length,
                                itemBuilder: ((context, index) {
                                  return dayItem(context,
                                      timeSegments.keys.elementAt(index));
                                })),
                          ),
                        ),
                  addVacationButton()
                ],
              ),
            ),
          )),
    );
  }

  Widget deleteAllButton() {
    return Container(
      alignment: ApplicationLocalizations.of(context)!.isRTL()
          ? Alignment.centerRight
          : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: 40,
      child: Visibility(
        visible: rangesToDelete.length > 0,
        child: TextButton(
            onPressed: () {
              makeSureDeleteDialog(context, [...rangesToDelete]);
            },
            child: Text(translate("deleteAll"))),
      ),
    );
  }

  Widget addVacationButton() {
    return SizedBox(
      child: Column(
        children: [
          IconButton(
            onPressed: () {
              showDateRangePicker(
                context: context,
                initialDateRange:
                    DateTimeRange(start: DateTime.now(), end: DateTime.now()),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 365)),
              ).then((range) async {
                if (range != null) {
                  if (!possibleToAdd(range)) {
                    CustomToast(
                            context: context,
                            msg: translate("enableToAddVacationRange"))
                        .init();
                    return;
                  }
                  addRange(range);
                }
              });
            },
            icon: Icon(Icons.add),
            iconSize: 50,
          ),
          Text(
            translate("addVacation"),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(
            height: 15,
          )
        ],
      ),
    );
  }

  Widget dayItem(BuildContext context, DateTime day) {
    return CustomContainer(
      image: null,
      onTap: () {
        /*Need to be empty for the gestor dedctor that is on the whole 
          body to not activate when press on item*/
      },
      width: gWidth * .95,
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomCheckBox(
                isSelected: () => isSelected(day),
                onChanged: (toAdd) => addOrRemoveRageToDelete(day, toAdd),
              ),
              Container(
                alignment: Alignment.center,
                width: gWidth * .7,
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25)),
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                child: textRangeToDisplay(day),
              ),
            ],
          ),
          toolBar(day)
        ],
      ),
    );
  }

  Widget toolBar(DateTime day) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () {
              DateTime startDay = day;
              // vacation already started
              if (DateTime.now().isAfter(day)) {
                startDay = setToMidNight(DateTime.now());
              }
              showDateRangePicker(
                context: context,
                initialDateRange:
                    DateTimeRange(start: startDay, end: timeSegments[day]!),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 365)),
              ).then((range) async {
                if (range != null) {
                  if (!possibleToAdd(range)) {
                    CustomToast(
                            context: context,
                            msg: translate("enableToAddVacationRange"))
                        .init();
                    return;
                  }
                  deleteRange(day);
                  addRange(range);
                }
              });
            },
            icon: Icon(
              Icons.edit,
              color: Colors.orange,
            )),
        IconButton(
            onPressed: () => makeSureDeleteDialog(context, [day]),
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            )),
      ],
    );
  }

  Future<dynamic> makeSureDeleteDialog(
      BuildContext context, List<DateTime> days) {
    Widget content = Text(
      translate("confirmDeleteVacations"),
      textAlign: TextAlign.center,
    );
    if (days.length == 1) {
      String strDate = DateFormat('dd-MM-yyyy').format(days[0]);
      String endDate = DateFormat('dd-MM-yyyy').format(timeSegments[days[0]]!);
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(translate("deleteRange"), textAlign: TextAlign.center),
          Text("$strDate - $endDate",
              textDirection: TextDirection.ltr, textAlign: TextAlign.center),
          Text("?", textAlign: TextAlign.center)
        ],
      );
    }
    return genralDeleteDialog(
      context: context,
      title: translate("deleting"),
      content: content,
      onCancel: () => Navigator.pop(context, 'Cancel'),
      onDelete: () {
        days.forEach(
          (day) {
            deleteRange(day);
          },
        );
        Navigator.pop(context);
        updateScreen();
      },
    );
  }

  void deleteRange(DateTime start) {
    DateTime copy = start;
    while (!copy.isAfter(timeSegments[start]!)) {
      String strDate = DateFormat('dd-MM-yyyy').format(start);
      days.add(strDate);
      copy = copy.add(Duration(days: 1));
    }
    timeSegments.remove(start);
    rangesToDelete.remove(start);
  }

  bool possibleToAdd(DateTimeRange range) {
    bool possibleToAdd = true;
    timeSegments.forEach((start, end) {
      if (durationStrikings(start, end, range.start, range.end) == 'STRIKE') {
        possibleToAdd = false;
        return;
      }
    });
    return possibleToAdd;
  }

  void addRange(DateTimeRange range) {
    timeSegments[range.start] = range.end;
    updateScreen();
  }

  void updateScreen() {
    setState(() {});
  }

  bool isSelected(DateTime day) {
    return rangesToDelete.contains(day);
  }

  void addOrRemoveRageToDelete(DateTime day, bool? add) {
    if (add == null) {
      return;
    } else if (add == true) {
      rangesToDelete.add(day);
    } else {
      rangesToDelete.remove(day);
    }
    if (rangesToDelete.length <= 1) {
      // from 0 to 1 or from 1 to zero
      updateScreen();
    }
  }
}

class CustomCheckBox extends StatefulWidget {
  final bool Function() isSelected;
  final void Function(bool?) onChanged;
  const CustomCheckBox(
      {super.key, required this.isSelected, required this.onChanged});

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Checkbox(
        activeColor: Theme.of(context).colorScheme.secondary,
        value: widget.isSelected(),
        onChanged: (val) {
          widget.onChanged(val);
          updateScreen();
        });
  }

  void updateScreen() {
    setState(() {});
  }
}
