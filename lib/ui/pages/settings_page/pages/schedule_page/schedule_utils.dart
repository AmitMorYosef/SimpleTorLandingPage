import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/ui/general_widgets/pickers/multi_picker.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/schedule_page/widgets/use_colors_switch.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/schedule_page/widgets/weekends_string.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/schedule_page/widgets/work_on_holiday_switch.dart';

import '../../../../../app_const/worker_scedule.dart';
import '../../../../../app_statics.dart/worker_data.dart';
import '../../../../../utlis/string_utlis.dart';
import '../../../../general_widgets/custom_widgets/custom_toast.dart';
import '../../settings_utlis.dart';
import 'widgets/holidays_string.dart';
import 'widgets/string_to_allow_bookings.dart';
import 'widgets/vacations_page/vacations.dart';
import 'widgets/work_time.dart';

late BuildContext scheduleContext;

List<Map<String, dynamic>> work = [
  {
    "icon": Icon(Icons.schedule),
    "name": "shifts",
    "onClick": () {
      Map<String, List<String>> map = {};
      WorkerData.worker.workTime.keys.forEach((key) {
        map[key] = [...WorkerData.worker.workTime[key]!];
      });

      Navigator.push(scheduleContext,
          MaterialPageRoute(builder: (_) => WorkTime(initialWorkTime: map)));
    }
  },
  {
    "icon": Icon(Icons.timelapse),
    "name": "turnsOpenTill",
    "trailing": StringDaysToAllowBooking(),
    "onClick": () => allwBokkingsTillPickTime(settingsContext)
  },
  {
    "icon": Icon(Icons.schedule),
    "name": "vacationScedule",
    "onClick": () {
      Navigator.push(
          scheduleContext, MaterialPageRoute(builder: (_) => Vacations()));
    }
  },
];

List<Map<String, dynamic>> design = [
  {
    "icon": Icon(Icons.switch_right),
    "name": "useColors",
    "onClick": () => {},
    "suffix": UseColorSwitch()
  },
];

List<Map<String, dynamic>> events = [
  {
    "icon": Icon(Icons.holiday_village),
    "name": "holidays",
    "subtitle": HolidaysString(),
    "onClick": () async {
      // const Map<String, Religion> convertor = {
      //   "jewishHolidays": Religion.jewish,
      //   "christianHolidays": Religion.christian
      // };
      const Map<Religion, String> convertor = {
        Religion.jewish: "jewishHolidays",
        Religion.christian: "christianHolidays"
      };

      final multiPicker = MultiplePicker(
          items: convertor,
          choosenItems: WorkerData.worker.religions,
          title: translate("holidays"),
          infoText: translate("holidaysExplian"));

      await multiPicker.showPicker(scheduleContext);

      Function deepEq = const DeepCollectionEquality().equals;
      if (deepEq(WorkerData.worker.religions, multiPicker.choosenItems)) {
        CustomToast(context: scheduleContext, msg: translate("sameData"))
            .init();
        return;
      }
      if (multiPicker.choosenItems == WorkerData.worker.religions) {}
      await Loading(
              context: scheduleContext,
              navigator: Navigator.of(scheduleContext),
              future: WorkerData.setReligions(
                  multiPicker.choosenItems, scheduleContext),
              msg: translate("holidaysUpdatedSuccessfully"))
          .dialog();
    },
  },
  {
    "icon": Icon(Icons.switch_right),
    "name": "workOnHoliday",
    "onClick": () => {},
    "suffix": CloseScheduleOnHolidaysSwitch()
  },
  {
    "icon": Icon(Icons.weekend),
    "name": "weekend",
    "subtitle": WeekendString(),
    "onClick": () async {
      const Map<int, String> convertor = {
        DateTime.sunday: 'sunday',
        DateTime.monday: 'monday',
        DateTime.tuesday: 'tuesday',
        DateTime.wednesday: 'wednesday',
        DateTime.thursday: 'thursday',
        DateTime.friday: 'friday',
        DateTime.saturday: 'saturday',
      };
      final multiPicker = MultiplePicker(
          items: convertor,
          choosenItems: WorkerData.worker.weekendDays,
          title: translate("weekend"),
          infoText: translate("weekendExplain"));

      await multiPicker.showPicker(scheduleContext);

      if (multiPicker.choosenItems == WorkerData.worker.weekendDays) {
        CustomToast(context: scheduleContext, msg: translate("sameData"))
            .init();
        return;
      }

      WorkerData.setWeekend(multiPicker.choosenItems, scheduleContext);
    },
  },
];
