// ignore_for_file: unnecessary_brace_in_string_interps
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:management_system_app/models/treatment_model.dart';
import 'package:management_system_app/models/worker_model.dart';
import 'package:management_system_app/providers/booking_provider.dart';
import 'package:management_system_app/providers/user_provider.dart';
import 'package:management_system_app/services/errors_service/app_errors.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/booking.dart';
import '../../../../app_const/gender.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_const/worker_scedule.dart';
import '../../../../app_statics.dart/screens_data.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../models/booking_model.dart';
import '../../../../providers/device_provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../services/errors_service/messages.dart';
import '../../../../utlis/general_utlis.dart';
import '../../../../utlis/image_utlis.dart';
import '../../../../utlis/string_utlis.dart';
import '../../../general_widgets/custom_widgets/custom_container.dart';
import '../../../general_widgets/custom_widgets/sliding_bottom_sheet.dart';
import '../../../general_widgets/dialogs/confirm_delete_dialog.dart';
import '../../booking_page/booking.dart';

// ignore: must_be_immutable
class BookingCard extends StatelessWidget {
  late UserProvider userProvider;
  late BookingProvider bookingProvider;
  late String defaultImage;
  late WorkerModel? worker;
  late Treatment? treatment;
  BuildContext ancestorContext;
  Booking booking;
  bool showPrice = false, showTime = false;
  String date = '',
      dayOfWeek = '',
      time = '',
      treatmentName = '',
      treatmentDuration = '',
      userName = '',
      workerName = '',
      price = '',
      imageProfile = '',
      buisnessName = translate('deletedBuisness');

  BookingCard(
      {super.key, required this.booking, required this.ancestorContext});

  @override
  Widget build(BuildContext context) {
    bookingProvider = context.watch<BookingProvider>();

    defaultImage = booking.workerGender == Gender.female
        ? defaultWomanImage
        : defaultManImage;

    date = DateFormat('dd-MM-yyyy').format(booking.bookingDate);
    time = DateFormat('HH:mm').format(booking.bookingDate);
    dayOfWeek = translate(weekDays[booking.bookingDate.weekday]);

    treatmentName = booking.treatment.name;
    treatmentDuration =
        durationToString(Duration(minutes: booking.treatment.totalMinutes));
    price = booking.treatment.priceToString();

    userName = UserData.user.name;

    if (SettingsData.workers[booking.workerId] != null &&
        booking.buisnessId == SettingsData.appCollection) {
      worker = SettingsData.workers[booking.workerId]!;
      workerName = worker!.name;
      imageProfile = worker!.profileImg;
      treatment = worker!.treatments[booking.treatment.name];
      if (treatment != null) {
        showPrice = treatment!.showPrice;
        showTime = treatment!.showTime;
      } else {
        treatmentName = booking.treatment.name;
        showTime = false;
        showPrice = false;
      }
    } else {
      if (SettingsData.workers.isEmpty ||
          (SettingsData.appCollection != booking.buisnessId))
        workerName = booking.workerName;
      else {
        workerName = translate('notAvailableWorker');
        treatmentName = '';
        treatmentDuration = '';
        price = '';
      }
    }

    buisnessName = booking.businessName;

    if (DateFormat('dd-MM-yyyy').format(booking.bookingDate) ==
        DateFormat('dd-MM-yyyy')
            .format(DateTime.now().add(Duration(days: 1)))) {
      dayOfWeek = translate('tomorrow');
    }
    if (DateFormat('dd-MM-yyyy').format(booking.bookingDate) ==
        DateFormat('dd-MM-yyyy').format(DateTime.now())) {
      dayOfWeek = translate('today');
    }

    Widget? statusWidget;
    switch (booking.status) {
      case BookingStatuses.approved:
        statusWidget = SizedBox();
        break;
      case BookingStatuses.waiting:
        statusWidget = Text(
          translate('waitingForApproval'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        );
        break;
    }
    return Opacity(
      opacity:
          booking.status == BookingStatuses.waiting || treatmentDuration == ''
              ? 0.7
              : 1,
      child: CustomContainer(
        alignment: Alignment.center,
        width: gWidth * 0.8,
        height: 290,
        image: null,
        borderWidth: 2.5,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                booking.status == BookingStatuses.approved
                    ? SizedBox()
                    : Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Lottie.asset(attentionAnimation,
                                width: 40, height: 40, repeat: false),
                          ),
                          SizedBox(width: gWidth * 0.6, child: statusWidget),
                        ],
                      ),
                SizedBox(
                  width: gWidth * 0.6,
                  child: Center(
                    child: Text(buisnessName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontSize: 25)),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: gWidth * .5,
                        child: workerName == translate('notAvailableWorker')
                            ? title(workerName, 20)
                            : title(
                                translate('bookingTo') + ' ' + workerName, 20)),
                    SizedBox(
                      width: 20,
                    ),
                    showCircleCachedImage(imageProfile, 50, defaultImage)
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                Column(
                  children: [
                    title(
                        translate('on') + " - " + date + ' (' + dayOfWeek + ')',
                        14),
                    title(translate('at') + " " + time, 17)
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SettingsData.appCollection == booking.buisnessId
                        ? actionsRow(context)
                        : loadBuisnessButton(context),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: SizedBox(
                        width: gWidth * 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 90, child: title(treatmentName, 20)),
                            price != '' && showPrice
                                ? title(price, 17)
                                : SizedBox(),
                            treatmentDuration != '' && showTime
                                ? title(treatmentDuration, 14)
                                : SizedBox()
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget actionsRow(BuildContext context) {
    return booking.bookingDate
            .add(Duration(minutes: booking.treatment.totalMinutes + 2))
            .isAfter(DateTime.now())
        ? Row(
            children: [
              SizedBox(width: 10),
              deleteButton(context),
              SizedBox(width: 20),
              editButton(context)
            ],
          )
        : SizedBox();
  }

  Widget editButton(BuildContext context) {
    return BouncingWidget(
        onPressed: () async {
          if (!await isNetworkConnected()) {
            notNetworkConnectedToast(context);
            return;
          }
          bool respCopy = BookingProvider.copyFromObject(booking, context);
          if (!respCopy) {
            await deleteNotAvaliableBooking(context);
            return;
          }
          BookingProvider.setSheetOpen(false);
          UserData.userListinerAllowUpdate = false;

          if (SettingsData.workers[booking.workerId] == null) {
            await Loading(
                    navigator: Navigator.of(ancestorContext),
                    context: ancestorContext,
                    timeOutDuration: Duration(seconds: 4),
                    animation: deleteAnimation,
                    future: context
                        .read<UserProvider>()
                        .deleteBookingOnlyFromUserDoc(
                          ancestorContext,
                          booking,
                          context.read<DeviceProvider>().minutesBeforeNotify,
                        ),
                    msg: translate('deletedBookingNotExistWorker'))
                .dialog();
          } else {
            SettingsData.startListening(booking.workerId);
            await SlidingBottomSheet(
                    context: ancestorContext,
                    sheet: BookingSheet(
                      ancestorContext: ancestorContext,
                      isUpdateSheet: true,
                      oldBooking: booking,
                    ),
                    size: 0.8)
                .showSheet();
          }
          SettingsData.cancelWorkerListening();
          UserData.userListinerAllowUpdate = true;
        },
        child: const Icon(
          Icons.edit,
        ));
  }

  Widget deleteButton(BuildContext context) {
    return BouncingWidget(
        onPressed: () async {
          if (!await isNetworkConnected()) {
            notNetworkConnectedToast(context);
            return;
          }
          dynamic resp =
              await DeleteDialog(myBooking: booking, context: ancestorContext)
                  .confirmBody();
          if (resp == 'OK') {
            bool respCopy = BookingProvider.copyFromObject(booking, context);
            if (!respCopy) {
              await deleteNotAvaliableBooking(context);
              BookingProvider.setup();
              return;
            }
            UserData.userListinerAllowUpdate = false;
            //UserData.cancelListening();
            if (SettingsData.workers[booking.workerId] == null) {
              await Loading(
                      navigator: Navigator.of(ancestorContext),
                      context: ancestorContext,
                      timeOutDuration: Duration(seconds: 4),
                      animation: deleteAnimation,
                      future: userProvider.deleteBookingOnlyFromUserDoc(
                        ancestorContext,
                        booking,
                        context.read<DeviceProvider>().minutesBeforeNotify,
                      ),
                      msg: translate('successfullydeletedBooking'))
                  .dialog();
            } else {
              await Loading(
                      navigator: Navigator.of(ancestorContext),
                      context: ancestorContext,
                      timeOutDuration: Duration(seconds: 4),
                      animation: deleteAnimation,
                      future: userProvider.deleteBooking(
                        booking,
                        context.read<DeviceProvider>().minutesBeforeNotify,
                      ),
                      msg: translate('successfullydeletedBooking'))
                  .dialog();
            }

            BookingProvider.setup();
            //UserData.startLisening();
            UserData.userListinerAllowUpdate = true;
          }
        },
        child: const Icon(
          Icons.delete,
        ));
  }

  Future<void> deleteNotAvaliableBooking(
    BuildContext context,
  ) async {
    await Loading(
            navigator: Navigator.of(context),
            context: context,
            timeOutDuration: Duration(seconds: 4),
            animation: deleteAnimation,
            future: userProvider.deleteBookingOnlyFromUserDoc(
              context,
              booking,
              context.read<DeviceProvider>().minutesBeforeNotify,
            ),
            msg: translate('notExistTreatment'))
        .dialog();
  }

  Widget loadBuisnessButton(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () async {
            if (SettingsData.appCollection != booking.buisnessId) {
              UserData.userListinerAllowUpdate = false;
              await SettingsData.emptyBusinessData();
              await Loading(
                      context: context,
                      navigator: Navigator.of(context),
                      future: context
                          .read<SettingsProvider>()
                          .loadBuisness(context, booking.buisnessId),
                      msg: translate('successfullyLoadedBuisness'),
                      animation: successAnimation)
                  .dialog()
                  .then((value) async {
                if (value == true) {
                  ScreensData.screenIndex = UserData.getPermission() > 0
                      ? workerScreensCount - 1
                      : userScreensCount - 1;
                }

                if (value == false && AppErrors.error == Errors.notFoundItem) {
                  await UiManager.updateUi(
                      context: ancestorContext,
                      perform: userProvider.deleteBookingOnlyFromUserDoc(
                        ancestorContext,
                        booking,
                        context.read<DeviceProvider>().minutesBeforeNotify,
                      ));
                }
              });
              UserData.userListinerAllowUpdate = true;
            }
          },
          child: CustomContainer(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Text(translate('loadBuisness')),
          ),
        ));
  }

  Widget title(String txt, double size) {
    return AutoSizeText(
      txt,
      textAlign: TextAlign.center,
      style: Theme.of(ancestorContext)
          .textTheme
          .bodyMedium!
          .copyWith(fontSize: size),
    );
  }
}
