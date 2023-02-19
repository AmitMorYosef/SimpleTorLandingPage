import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simple_tor_web/app_statics.dart/screens_data.dart';
import 'package:simple_tor_web/models/booking_model.dart';
import 'package:simple_tor_web/providers/device_provider.dart';
import 'package:simple_tor_web/providers/settings_provider.dart';
import 'package:simple_tor_web/providers/user_provider.dart';
import 'package:simple_tor_web/ui/general_widgets/dialogs/confirm_save_dialog.dart';
import 'package:simple_tor_web/ui/general_widgets/dialogs/confirm_update_dialog.dart';
import 'package:simple_tor_web/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:simple_tor_web/ui/pages/booking_page/widgets/time_widget.dart';
import 'package:simple_tor_web/ui/pages/booking_page/widgets/waiting_list_button.dart';
import 'package:simple_tor_web/ui/ui_manager.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';
import 'package:simple_tor_web/utlis/times_utlis.dart';
import 'package:uuid/uuid.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/platform.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../models/notification_topic.dart';
import '../../../../models/worker_model.dart';
import '../../../../providers/booking_provider.dart';
import '../../../general_widgets/buttons/launch_appstore.dart';
import '../../../helpers/fonts_helper.dart';

// ignore: must_be_immutable
class TimePicker extends StatelessWidget {
  bool isUpdateSheet;
  bool workerAction;
  Booking? oldBooking;
  late BookingProvider bookingProvider;
  late UserProvider userProvider;
  WorkerModel? worker;
  late int timeIndex;
  double timeCardWidth = 100;
  late String bookingDate;
  Iterator<DateTime> hours = <DateTime>[].iterator;
  Iterable<DateTime>? iterable;
  ScrollController controller = ScrollController();
  late SettingsProvider settingsProvider;
  NavigatorState navigator;
  BuildContext context;

  BuildContext ancestorContext;
  bool workerSheet;
  TimePicker(
      {this.isUpdateSheet = false,
      this.workerAction = false,
      this.oldBooking = null,
      this.workerSheet = false,
      required this.navigator,
      required this.context,
      required this.ancestorContext,
      required this.worker});

  @override
  Widget build(BuildContext context) {
    userProvider = context.watch<UserProvider>();
    context.watch<DeviceProvider>();
    settingsProvider = context.read<SettingsProvider>();
    timeIndex = BookingProvider.timeIndex;
    if (this.worker == null) return SizedBox();
    bookingDate =
        DateFormat('dd-MM-yyyy').format(BookingProvider.booking.bookingDate);

    // check free day
    iterable = relevantHoures(
        worker, Booking.fromBooking(BookingProvider.booking),
        isUpdate: isUpdateSheet,
        oldBooking: oldBooking,
        workerSheet: workerSheet);
    hours = (iterable == null || iterable!.isEmpty)
        ? <DateTime>[].iterator
        : iterable!.iterator;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (iterable == null || iterable!.isEmpty)
              ? Text(translate('noAvailableHours'),
                  style: FontsHelper().businessStyle(
                    currentStyle: Theme.of(context).textTheme.headlineSmall,
                  ))
              : Text(translate('pichTime'),
                  style: FontsHelper().businessStyle(
                    currentStyle: Theme.of(context).textTheme.headlineSmall,
                  )),
          (iterable == null || iterable!.isEmpty)
              ? addToWaitingList()
              : pickerTimeList()
        ],
      ),
    );
  }

  Widget addToWaitingList() {
    String buisnessId = SettingsData.appCollection;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: 10,
        ),
        context.read<DeviceProvider>().isAllowedNotification
            ? WaitingListButton(
                worker: worker!,
                date: BookingProvider.booking.bookingDate,
                topic: NotificationTopic(
                    businessName: SettingsData.settings.shopName,
                    imageUrl: SettingsData.settings.shopIconUrl,
                    businessId: buisnessId,
                    workerId: worker!.phone,
                    date: bookingDate,
                    workerName: worker!.name),
              )
            : isWeb
                ? LaunchAppButton(
                    text: translate("waitingListDontWorkOnWeb"),
                  )
                : Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Text(
                          translate('allwedNotificatonForWaitingList'),
                          style: FontsHelper().businessStyle(),
                        ),
                        //NotificationSwitch()
                      ],
                    ),
                  ),
      ],
    );
  }

  Widget pickerTimeList() {
    List<Widget> eventsList = [];

    return SizedBox(
      height: gHeight * .11,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 300,
          key: Key(Uuid().v1()), // to make the list start for start every time
          itemBuilder: ((context, index) {
            bool hasVal = hours.moveNext();
            if (hasVal) {
              /* save copy of thes time object - > 
               if not there are time missing inside on tap */
              DateTime generatedTime = DateTime(
                  1970, 1, 1, hours.current.hour, hours.current.minute);
              /* need to save the element for swip up 
              (the generator val disappeard after get current)*/
              eventsList.add(GestureDetector(
                  onTap: () => onTap(index, generatedTime),
                  child: TimeWidget(
                      time: generatedTime, indexInTimesList: index)));
            }
            if (index >= eventsList.length) {
              return SizedBox();
            }
            return eventsList[index];
          })),
    );
  }

  void onTap(int index, DateTime widgetTime) async {
    bool loadingResp = true;
    DateTime prevDate = BookingProvider.booking.bookingDate;
    if (index == BookingProvider.timeIndex) {
      // remove the selection
      await UiManager.updateUi(
          context: context,
          perform: Future((() => BookingProvider.setTimeIndex(-1))));
    } else {
      await UiManager.updateUi(
          context: context,
          perform: Future(
            () {
              BookingProvider.setTimeIndex(index);
              BookingProvider.setDate(DateTime(prevDate.year, prevDate.month,
                  prevDate.day, widgetTime.hour, widgetTime.minute));
            },
          ));
      dynamic resp = this.isUpdateSheet
          ? await UpdateDialog(
                  navigator: navigator,
                  context: ancestorContext,
                  oldBooking: oldBooking!,
                  needHoldOn: needToHoldOn(BookingProvider.booking, worker!) &&
                      !workerAction)
              .confirmBody()
          : await SaveDialog(
                  navigator: navigator,
                  context: ancestorContext,
                  needHoldOn: needToHoldOn(BookingProvider.booking, worker!) &&
                      !workerAction)
              .confirmBody();
      if (resp == "OK_UPDATE") {
        SettingsData.cancelWorkerListening();
        loadingResp = loadingResp &&
            await loadRequest(
                translate('bookingUpdated'),
                userProvider.updateBooking(
                    context,
                    BookingProvider.booking,
                    this.oldBooking!,
                    BookingProvider.getWorker!,
                    context.read<DeviceProvider>().isAllowedNotification,
                    context.read<DeviceProvider>().minutesBeforeNotify,
                    workerAction: workerAction));
      } else if (resp is String && resp.contains("OK")) {
        SettingsData.cancelWorkerListening();
        loadingResp = loadingResp &&
            await loadRequest(
                translate('bookingCopleted'),
                userProvider.addBooking(
                    context,
                    BookingProvider.booking,
                    BookingProvider.getWorker!,
                    context.read<DeviceProvider>().isAllowedNotification,
                    context.read<DeviceProvider>().minutesBeforeNotify,
                    workerAction: workerAction,
                    addTocalendar: resp.contains("true")));
      } else if (resp == 'CANCLE' || resp == null) {
        if (resp == null) {
          // remove the selection
          UiManager.updateUi(
              context: context,
              perform: Future((() => BookingProvider.setTimeIndex(-1))));
        }
        loadingResp = false;
      }
    }
    if (loadingResp) {
      Navigator.pop(context);
      BookingProvider.setup();
      // we want only that the page go to my booking only for clients
      if (UserData.getPermission() == 0) {
        ScreensData.controller.jumpToPage(ScreensData.screensCount - 1);
      }
    }
  }

  Future<bool> loadRequest(String msg, Future<bool> future) async {
    // userProvider = context.read<UserProvider>();
    return await Loading(
                //playSound: true,
                navigator: navigator,
                context: context,
                animation: successAnimation,
                msg: msg,
                future: future)
            .dialog() ==
        true;
  }

  bool needToHoldOn(Booking booking, WorkerModel worker) {
    final duration =
        DateTime.now().add(Duration(minutes: worker.onHoldMinutes));

    return duration.isAfter(booking.bookingDate);
  }
}
