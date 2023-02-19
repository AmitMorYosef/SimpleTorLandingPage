import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:management_system_app/app_statics.dart/screens_data.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/treatments_page/treatments.dart';
import 'package:management_system_app/ui/pages/worker_schedule_page/widgets/calendar_table.dart';
import 'package:management_system_app/ui/pages/worker_schedule_page/widgets/customers_waiting_list.dart';
import 'package:management_system_app/ui/pages/worker_schedule_page/widgets/schedule_list.dart';
import 'package:management_system_app/ui/pages/worker_schedule_page/widgets/shortcut_item.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:management_system_app/utlis/times_utlis.dart';

import '../../../app_const/app_sizes.dart';
import '../../../app_const/gender.dart';
import '../../../app_const/resources.dart';
import '../../../app_statics.dart/settings_data.dart';
import '../../../app_statics.dart/user_data.dart';
import '../../../app_statics.dart/worker_data.dart';
import '../../../models/price_model.dart';
import '../../../providers/worker_provider.dart';
import '../../general_widgets/custom_widgets/drop_down_menu.dart';
import '../../general_widgets/custom_widgets/sliding_bottom_sheet.dart';
import '../../general_widgets/dialogs/make_sure_dialog.dart';
import '../../general_widgets/loading_widgets/loading_dialog.dart';
import '../settings_page/dialogs/profile.dart';
import '../settings_page/pages/schedule_page/widgets/work_time.dart';
import '../settings_page/settings_utlis.dart';

class SchedulePage extends StatefulWidget {
  SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool closeTopContainer = false;
  bool tapped = false;
  late WorkerProvider workerProvider;
  late String dateKey;
  late int bookingLength;
  late String defaultImage;

  ScrollController controller = ScrollController();

  String workerName = '', imageProfile = '';

  @override
  void initState() {
    super.initState();
    WorkerData.startListener(date: WorkerData.focusedDay);
    controller.addListener(() {
      ScreensData.scheduleScrollControllerOffset = controller.offset;
    });
  }

  @override
  void dispose() {
    WorkerData.cancelListening();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScheduleList scduleObj = ScheduleList(ancestorContext: context);
    scduleObj.build(context);

    dateKey = DateFormat('dd-MM-yyyy').format(WorkerData.focusedDay);
    workerName = UserData.user.name;
    imageProfile = WorkerData.worker.profileImg;
    defaultImage = UserData.user.gender == Gender.female
        ? defaultWomanImage
        : defaultManImage;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients)
        controller.jumpTo(ScreensData.scheduleScrollControllerOffset);
    });

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        controller: controller,
        slivers: [
          SliverAppBar(
            toolbarHeight: gHeight * 0.08,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.all(8.0),
                title: SizedBox(
                    width: gWidth * 0.7,
                    height: gHeight * 0.08,
                    child: subTitle()),
                stretchModes: [StretchMode.blurBackground],
                collapseMode: CollapseMode.pin,
                centerTitle: true,
                background: titles()),
            floating: true,
            pinned: true,
            expandedHeight: gHeight * 0.17,
          ),
          SliverToBoxAdapter(
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: gWidth * .09),
                height: 45,
                child: scrollOptions()),
          ),
          SliverToBoxAdapter(
            child: CalendarTable(),
          ),
          SliverToBoxAdapter(
              child: Container(
            alignment: Alignment.center,
            width: gWidth * .8,
            height: 20,
            child: vacationIndicator(),
          )),
          !SettingsData.activeBusiness || SettingsData.isPassedLimit()
              ? SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: (gWidthOriginal - gWidth) / 2),
                    alignment: Alignment.center,
                    child: Text(translate('unavailableBuisness')),
                  ),
                )
              : scduleObj.scheduleList()
        ],
      ),
    );
  }

  Widget scrollOptions() {
    final stringDate = DateFormat('dd-MM-yyyy').format(WorkerData.focusedDay);
    return SingleChildScrollView(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ShortCutItem(
            showItem: setToMidNight(WorkerData.focusedDay)
                    .isBefore(setToMidNight(DateTime.now())) &&
                WorkerData.worker.bookingObjects.containsKey(stringDate) &&
                WorkerData.worker.bookingObjects[stringDate]!.isNotEmpty,
            clickable: SettingsData.activeBusiness,
            icon: Icon(Icons.delete),
            name: translate("delete"),
            onTap: () async => await deleteBookings(WorkerData.focusedDay)),
        ShortCutItem(
            showItem: !WorkerData.focusedDay
                    .isBefore(setToMidNight(DateTime.now())) &&
                setToMidNight(DateTime.now())
                    .add(Duration(days: WorkerData.worker.daysToAllowBookings))
                    .isAfter(WorkerData.focusedDay),
            clickable: SettingsData.activeBusiness,
            icon: Icon(FontAwesomeIcons.tableList),
            name: translate("waitingCustomers"),
            onTap: () async {
              await SlidingBottomSheet(
                      context: context,
                      sheet: CustomersWaitingList(
                        date: WorkerData.focusedDay,
                      ),
                      size: 0.7)
                  .showSheet();
            }),
        ShortCutItem(
            icon: Icon(Icons.schedule),
            name: translate("shifts"),
            clickable: SettingsData.activeBusiness,
            onTap: () {
              Map<String, List<String>> map = {};
              WorkerData.worker.workTime.keys.forEach((key) {
                map[key] = [...WorkerData.worker.workTime[key]!];
              });

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => WorkTime(initialWorkTime: map)));
            }),
        ShortCutItem(
            icon: Icon(Icons.list_alt),
            name: translate("treatments"),
            clickable: SettingsData.activeBusiness,
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => Treatments()))),
        ShortCutItem(
            icon: Icon(Icons.timelapse),
            name: translate("times"),
            clickable: SettingsData.activeBusiness,
            onTap: () => allwBokkingsTillPickTime(context)),
        ShortCutItem(
            icon: Icon(WorkerData.worker.showSceduleColors
                ? Icons.wb_sunny
                : Icons.wb_sunny_outlined),
            name: translate("colors"),
            clickable: SettingsData.activeBusiness,
            onTap: () => WorkerData.updateShowSceduleColors(
                !WorkerData.worker.showSceduleColors, context)),
        ShortCutItem(
            icon: Icon(Icons.today),
            name: translate("today"),
            clickable: SettingsData.activeBusiness,
            onTap: () => UiManager.updateUi(
                context: context,
                perform:
                    Future(() => WorkerData.setFocusedDate(DateTime.now())))),
      ]),
    );
  }

  Future<void> deleteBookings(DateTime date) async {
    bool? resp = await makeSureDialog(context, translate("deleteAllBookings"));
    if (resp == true) {
      await Loading(
              context: context,
              navigator: Navigator.of(context),
              animation: deleteAnimation,
              future: WorkerData.deleteAllBookingObjectsOfTheDay(date),
              msg: translate("ordersDeleted"))
          .dialog();
    }
  }

  Widget subTitle() {
    final worker = WorkerData.worker;
    Map<String, String> pricesData = {};
    worker.generalMoneyAmount.forEach((currencyCode, pricing) {
      pricesData[currencyCode] =
          "${worker.passedMoneyAmount[currencyCode].toString()}/${pricing.toString()}";
    });

    if (pricesData.isEmpty) {
      final emptyPrice =
          Price(amount: "0", currency: SettingsData.settings.currency);
      pricesData[SettingsData.settings.currency.code] =
          "${emptyPrice}/${emptyPrice}";
    }
    final holidaysToday = getHolidayName(worker, WorkerData.focusedDay);

    return SingleChildScrollView(
      child: Container(
        //color: Colors.red,
        child: Column(
          children: [
            Text(
              dateKey,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
            Text(
              "${worker.passedBookingsCount}/${worker.generalBookingsCount} ${translate("orders")}",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DropDownMenu(
                values: pricesData,
              ),
            ),
            holidaysToday != []
                ? Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: SizedBox(
                      width: gWidth,
                      height: gHeight * 0.1,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: holidaysToday.length,
                        itemBuilder: (context, index) {
                          return Center(
                            child: Text(holidaysToday[index],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget vacationIndicator() {
    if (WorkerData.worker.vacations[dateKey] != null) {
      if (WorkerData.worker.vacations[dateKey]!.length > 0) {
        return Text(translate('partlyFreeDay'));
      }
      //return Text(translate('freeDay'));
      return SizedBox();
    }
    return SizedBox();
  }

  Widget titles() {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Profile(
            showEdit: false,
            raduis: gHeight * 0.067,
          ),
        ),
      ),
    );
  }
}
