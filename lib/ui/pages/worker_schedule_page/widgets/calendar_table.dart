import 'package:flutter/material.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../app_statics.dart/worker_data.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../providers/worker_provider.dart';
import '../../../../services/in_app_services.dart/language.dart';
import '../../../../utlis/times_utlis.dart';

class CalendarTable extends StatefulWidget {
  @override
  CalendarTableState createState() => CalendarTableState();
}

class CalendarTableState extends State<CalendarTable> {
  late SettingsProvider settingsProvider;
  late WorkerProvider workerProvider;
  final kToday = DateTime.now();
  late DateTime kFirstDay; //=kToday.subtract(daysAhead);
  late DateTime kLastDay; //= kToday.add(daysAhead);
  CalendarFormat calendarFormat = CalendarFormat.week;
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    workerProvider = context.read<WorkerProvider>();
    settingsProvider = context.read<SettingsProvider>();
    //WorkerData.setupFocusedDay(); // make shure scedual not on passed day
    _focusedDay = WorkerData.focusedDay;
    kFirstDay = kToday;
    kLastDay =
        kFirstDay.add(Duration(days: WorkerData.worker.daysToAllowBookings));

    return TableCalendar(
      currentDay: _focusedDay,
      daysOfWeekHeight: 30,
      holidayPredicate: (date) => isHoliday(WorkerData.worker, date),
      weekendDays: WorkerData.worker.weekendDays,
      locale: ApplicationLocalizations.of(context)!.appLocale.toString(),
      calendarStyle: CalendarStyle(
        defaultTextStyle: Theme.of(context).textTheme.bodyMedium!,
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        holidayDecoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.onBackground),
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        holidayTextStyle: Theme.of(context).textTheme.bodyMedium!,
        todayTextStyle: Theme.of(context).textTheme.bodyMedium!,
        todayDecoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.secondary),
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
      ),
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
      startingDayOfWeek: StartingDayOfWeek.sunday,
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.secondary),
            borderRadius: const BorderRadius.all(Radius.circular(12.0))),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: Theme.of(context).colorScheme.secondary,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.secondary,
        ),
        formatButtonTextStyle: Theme.of(context).textTheme.bodyMedium!,
        titleTextStyle: Theme.of(context).textTheme.bodyMedium!,
      ),
      firstDay: DateTime(2023, 1, 1),
      lastDay: DateTime.now().add(Duration(days: 1200)),
      focusedDay: _focusedDay,
      calendarFormat: calendarFormat,
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          // Call `setState()` when updating the selected day
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          UiManager.updateUi(
              context: context,
              perform: Future(() => WorkerData.setFocusedDate(selectedDay)));
        }
      },
      availableCalendarFormats: {
        CalendarFormat.week: translate('week'),
        CalendarFormat.month: translate('month')
      },
      onFormatChanged: (format) {
        if (calendarFormat != format) {
          // Call `setState()` when updating calendar format

          setState(() {
            calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        // No need to call `setState()` here
        _focusedDay = focusedDay;
      },
      // Enable week numbers (disabled by default).
      daysOfWeekVisible: true,
    );
  }
}
