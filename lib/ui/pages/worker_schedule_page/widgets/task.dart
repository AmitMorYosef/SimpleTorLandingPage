import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:management_system_app/models/treatment_model.dart';
import 'package:management_system_app/providers/device_provider.dart';
import 'package:management_system_app/providers/worker_provider.dart';
import 'package:management_system_app/services/in_app_services.dart/app_launcher.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_toast.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/booking.dart';
import '../../../../app_const/gender.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../app_statics.dart/worker_data.dart';
import '../../../../models/booking_model.dart';
import '../../../../providers/booking_provider.dart';
import '../../../../providers/manager_provider.dart';
import '../../../../providers/user_provider.dart';
import '../../../../utlis/general_utlis.dart';
import '../../../../utlis/image_utlis.dart';
import '../../../../utlis/string_utlis.dart';
import '../../../general_widgets/buttons/note_button.dart';
import '../../../general_widgets/custom_widgets/sliding_bottom_sheet.dart';
import '../../../general_widgets/dialogs/confirm_delete_dialog.dart';
import '../../booking_page/booking.dart';

class Task extends StatefulWidget {
  final BuildContext ancestorContext;
  final Booking booking;
  final String sectionTitle;
  final Color? color;
  final String timeIndex;
  final DateTime startSection;
  final DateTime endSection;
  final bool isPassedTask;
  Task(
      {super.key,
      required this.booking,
      required this.ancestorContext,
      required this.startSection,
      required this.endSection,
      required this.sectionTitle,
      required this.timeIndex,
      required this.color,
      this.isPassedTask = false});

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;
  Animation? colorAnimation;
  bool tapped = false;
  double initHeight = gHeight * 0.1,
      expandedHeight = gHeight * 0.23,
      heightDiff = 0;
  String time = '', endTime = '', type = '', name = '', price = '';
  late BookingProvider bookingProvider;
  late WorkerProvider workerProvider;
  late Widget statusWidget;
  late Widget statusIcon;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController!);
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bookingProvider = context.read<BookingProvider>();
    workerProvider = context.read<WorkerProvider>();
    type = widget.booking.treatment.name + widget.sectionTitle;
    time = DateFormat('HH:mm').format(widget.startSection);
    endTime = DateFormat('HH:mm').format(widget.endSection);
    name = widget.booking.customerName;
    price = widget.booking.treatment.priceToString();
    Treatment? treatment =
        WorkerData.worker.treatments[widget.booking.treatment.name];

    if (type == ''
        //treatment == null
        ) {
      type = translate('notAvailableTreatment');
    }

    heightDiff = expandedHeight - initHeight;

    switch (widget.booking.status) {
      case BookingStatuses.approved:
        statusWidget =
            Text(translate('approved'), style: TextStyle(color: Colors.white));
        statusIcon = Icon(
          Icons.check,
          color: Colors.white,
          size: 15,
        );
        break;
      case BookingStatuses.waiting:
        statusWidget =
            Text(translate('waiting'), style: TextStyle(color: Colors.white));
        statusIcon = Icon(
          FontAwesomeIcons.clock,
          color: Colors.white,
          size: 15,
        );
        break;
    }
    //if booking is after now then dont show the status
    if (widget.booking.bookingDate.isBefore(DateTime.now())) {
      statusIcon = SizedBox();
      statusWidget = SizedBox();
    }

    return GestureDetector(
      onTap: () => updateScreen(),
      child: customTask(),
    );
  }

  void updateScreen() {
    tapped ? _animationController!.reverse() : _animationController!.forward();
    setState(() {
      tapped = !tapped;
    });
  }

  Widget customTask() {
    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2, bottom: 5.0),
      child: AnimatedBuilder(
          animation: _animationController!,
          builder: (BuildContext _, __) {
            return Container(
              height: MediaQuery.of(context).textScaleFactor *
                  (initHeight + (heightDiff * _animation!.value)),
              decoration: BoxDecoration(
                  border: widget.booking.status == BookingStatuses.waiting &&
                          widget.booking.bookingDate.isAfter(DateTime.now())
                      ? Border.all(color: Colors.orange, width: 2)
                      : GradientBoxBorder(
                          gradient: LinearGradient(colors: [
                            Color(0xffFFFFFF).withOpacity(0.15),
                            Color(0x000000).withOpacity(0.1)
                          ]),
                          width: 2,
                        ),
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    right: 8,
                    child: nameAndPrice(),
                  ),
                  Center(child: typeName()),
                  Positioned(
                    top: 20,
                    left: 8,
                    child: widget.timeIndex == "0" &&
                            tapped &&
                            !widget.isPassedTask
                        ? toolbar()
                        : SizedBox(),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: tapped ? phoneNumber() : SizedBox(),
                  ),
                  Positioned(
                    bottom: 5,
                    left: 8,
                    child: expndadText('$time - $endTime', 15, 7,
                        textDirection: TextDirection.ltr),
                  ),
                  widget.booking.status == BookingStatuses.waiting &&
                          widget.booking.bookingDate.isAfter(DateTime.now())
                      ? SizedBox()
                      : Positioned(
                          top: 6, right: 1, child: indicatorColorLine()),
                ],
              ),
            );
          }),
    );
  }

  Widget toolbar() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              deleteButton(),
              SizedBox(width: 10),
              editButton(),
              SizedBox(width: 10),
              NoteButton(
                booking: widget.booking,
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              whatsappButton(widget.booking.customerPhone),
              SizedBox(width: 10),
              blockButton(widget.booking.customerPhone),
            ],
          )
        ],
      ),
    );
  }

  Widget blockButton(String phone) {
    return UserData.getPermission() > 1
        ? BouncingWidget(
            child: Opacity(
                opacity: phone.split("-")[1] == "" ? 0.5 : 1,
                child: Icon(Icons.block)),
            onPressed: () async {
              if (phone.split("-")[1] == "") {
                CustomToast(context: context, msg: translate("noPhoneNumber"))
                    .init();
                return;
              }
              bool? resp = await blockDialog(context, phone);
              if (resp == true) {
                await Loading(
                        context: context,
                        navigator: Navigator.of(context),
                        future: ManagerProvider.blockUser(
                            userId: phone,
                            name: widget.booking.customerName,
                            gender: genderToStr[widget.booking.userGender]),
                        msg: translate("blockSuccessfully"))
                    .dialog();
              }
            })
        : SizedBox();
  }

  Future<bool?> blockDialog(BuildContext context, String name) async {
    return await genralDialog(
      context: context,
      title: translate("block"),
      content: Text(
        translate("toBlock") + " " + translate("et") + " $name?",
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(translate("no")),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text(translate("yes")),
        ),
      ],
    );
  }

  Widget indicatorColorLine() {
    return WorkerData.worker.showSceduleColors
        ? Container(
            height: MediaQuery.of(context).textScaleFactor *
                    (initHeight + (heightDiff * _animation!.value)) -
                15,
            width: 3,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16)),
                color: widget.color != null
                    ? widget.color!
                    : Theme.of(context).colorScheme.onSurface),
          )
        : SizedBox();
  }

  Widget phoneNumber() {
    return CustomContainer(
      padding: EdgeInsets.all(9),
      color: Theme.of(context).colorScheme.tertiary,
      geometryRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(17)),
      onTap: () {
        if (widget.booking.customerPhone.split("-")[1] == "") return;
        AppLauncher().makePhoneCall(widget.booking.customerPhone);
      },
      needImage: false,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              widget.booking.customerPhone.split("-")[1] == ""
                  ? translate("noPhoneNumber")
                  : widget.booking.customerPhone,
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Icon(Icons.call),
          ],
        ),
      ),
    );
  }

  Widget nameAndPrice() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              showCircleCachedImage(
                  '',
                  25,
                  widget.booking.userGender == Gender.female
                      ? defaultWomanImage
                      : defaultManImage),
              SizedBox(width: 2),
              Container(
                width: gWidth * 0.3,
                alignment: Alignment.centerRight,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: expndadText(name, 14, 4)),
              ),
            ],
          ),
          Container(
            width: gWidth * 0.3,
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: expndadText(price, 14, 4),
            ),
          )
        ],
      ),
    );
  }

  Widget typeName() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 7,
          ),
          expndadText(type, 14, 7),
          SizedBox(
            height: 10,
          ),
          tapped ? onHoldIndicator(widget.booking) : SizedBox(),
        ],
      ),
    );
  }

  Widget editButton() {
    return BouncingWidget(
        onPressed: () async {
          if (!await isNetworkConnected()) {
            notNetworkConnectedToast(context);
            return;
          }
          BookingProvider.copyFromObject(widget.booking, context);
          BookingProvider.setSheetOpen(false);
          SettingsData.startListening(widget.booking.workerId);
          await SlidingBottomSheet(
                  context: widget.ancestorContext,
                  sheet: BookingSheet(
                    workerUpdate: true,
                    ancestorContext: widget.ancestorContext,
                    workerSheet: true, // the worker is edit
                    isUpdateSheet: true,
                    oldBooking: widget.booking,
                  ),
                  size: 0.9)
              .showSheet();
          SettingsData.cancelWorkerListening();
          SettingsData.startListening(WorkerData.worker.phone);
        },
        child: Icon(Icons.edit));
  }

  Widget deleteButton() {
    return BouncingWidget(
        onPressed: () async {
          dynamic resp = await DeleteDialog(
                  myBooking: widget.booking, context: widget.ancestorContext)
              .confirmBody();
          if (resp == 'OK') {
            await Loading(
                    navigator: Navigator.of(widget.ancestorContext),
                    timeOutDuration: Duration(seconds: 4),
                    context: widget.ancestorContext,
                    animation: deleteAnimation,
                    future: context.read<UserProvider>().deleteBooking(
                        widget.booking,
                        context.read<DeviceProvider>().minutesBeforeNotify),
                    msg: translate('successfullydeletedBooking'))
                .dialog();
          }
        },
        child: Icon(Icons.delete));
  }

  Widget onHoldIndicator(Booking booking) {
    return widget.booking.bookingDate.isBefore(DateTime.now())
        ? SizedBox()
        : GestureDetector(
            onTap: () async {
              if (booking.status != BookingStatuses.approved &&
                  await chooseDialog() == true) {
                await Loading(
                        context: widget.ancestorContext,
                        navigator: Navigator.of(widget.ancestorContext),
                        future: workerProvider.cahngeStatusForBooking(
                            booking,
                            widget.ancestorContext,
                            BookingStatuses.approved,
                            UserData.user.bookings),
                        animation: successAnimation,
                        msg: translate('confirmedBooking') + ".")
                    .dialog();
              }
            },
            child: booking.status == BookingStatuses.waiting
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomContainer(
                          color: Colors.orange.withOpacity(0.8),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                statusWidget,
                                SizedBox(
                                  width: 5,
                                ),
                                statusIcon
                              ],
                            ),
                          )),
                      SizedBox(
                        height: 2,
                      ),
                      booking.status != BookingStatuses.approved
                          ? Text(translate('pressForChange'))
                          : SizedBox(),
                    ],
                  )
                : SizedBox(),
          );
  }

  Future<bool?> chooseDialog() async {
    return await genralDialog(
      context: widget.ancestorContext,
      title: translate('approveQuestion'),
      content: Center(
          child: Text(
        translate('approveBookingQuestion'),
        textAlign: TextAlign.center,
      )),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(widget.ancestorContext, null);
          },
          child: Text(translate('cancel')),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(widget.ancestorContext, true);
          },
          child: Text(translate('approve')),
        ),
      ],
    );
  }

  Widget whatsappButton(String phone) {
    return BouncingWidget(
      onPressed: () {
        if (phone.split("-")[1] == "") {
          CustomToast(context: context, msg: translate("noPhoneNumber")).init();
          return;
        }
        AppLauncher().launchWhatsapp(phone);
      },
      child: Opacity(
        opacity: phone.split("-")[1] == "" ? 0.5 : 1,
        child: Icon(
          FontAwesomeIcons.whatsapp,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
    );
  }

  Widget expndadText(String txt, int initSize, int diffSize,
      {TextDirection? textDirection}) {
    return SingleChildScrollView(
      child: Text(
        txt,
        textDirection: textDirection,
        style: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(fontSize: initSize + (_animation!.value * diffSize)),
        textAlign: TextAlign.center,
      ),
    );
  }
}
