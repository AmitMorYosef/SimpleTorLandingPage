import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:management_system_app/models/waiting_list_customer.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/utlis/image_utlis.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/gender.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_const/worker_scedule.dart';
import '../../../../app_statics.dart/worker_data.dart';
import '../../../../services/in_app_services.dart/app_launcher.dart';
import '../../../../utlis/times_utlis.dart';
import '../../../general_widgets/custom_widgets/custom_container.dart';

class CustomersWaitingList extends StatefulWidget {
  final DateTime date;
  const CustomersWaitingList({super.key, required this.date});

  @override
  State<CustomersWaitingList> createState() {
    // day already passed
    if (date.isBefore(setToMidNight(DateTime.now()))) {
      return _enableToOpenWaitingListState();
    }
    int maxNexDays = WorkerData.worker.daysToAllowBookings;
    // day is not open for customers to order
    if (date.isAfter(
        setToMidNight(DateTime.now()).add(Duration(days: maxNexDays)))) {
      return _enableToOpenWaitingListState();
    }
    return _CustomersWaitingListState();
  }
}

class _CustomersWaitingListState extends State<CustomersWaitingList> {
  DateTime currentDate = DateTime(0);
  final DateTime todayMidnigth = setToMidNight(DateTime.now());

  @override
  void dispose() {
    super.dispose();
    WorkerData.stopWaitingListListener();
  }

  @override
  Widget build(BuildContext context) {
    if (currentDate.year == DateTime(0).year) {
      currentDate = widget.date;
    }
    String dateAndYear = DateFormat('dd/MM/yy').format(currentDate);
    return Container(
      color: Theme.of(context).colorScheme.surface,
      height: gHeight * .7,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [title(context, dateAndYear), waitingList(context)],
      ),
    );
  }

  Widget title(BuildContext context, String dateAndYear) {
    return Container(
      height: gHeight * .12,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10, left: 12, right: 12),
      child: Column(
        children: [
          Text(translate("waitingList"),
              style: Theme.of(context).textTheme.titleLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => previusDay(),
                child: Icon(Icons.chevron_left,
                    size: 40,
                    color: possibleToGoPrevius
                        ? null
                        : Theme.of(context).colorScheme.tertiary),
              ),
              Column(
                children: [
                  Text(
                    dateAndYear,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  Text(
                    translate(weekDays[currentDate.weekday]),
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => nextDay(),
                child: Icon(
                  Icons.chevron_right,
                  size: 40,
                  color: possibleToGoNext
                      ? null
                      : Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool get possibleToGoNext {
    int maxNexDays = WorkerData.worker.daysToAllowBookings;
    return !this
        .currentDate
        .add(Duration(days: 1))
        .isAfter(todayMidnigth.add(Duration(days: maxNexDays)));
  }

  bool get possibleToGoPrevius {
    return !this
        .currentDate
        .subtract(Duration(days: 1))
        .isBefore(todayMidnigth);
  }

  void nextDay() {
    if (!possibleToGoNext) {
      return;
    }
    this.currentDate = currentDate.add(Duration(days: 1));
    updateScreen();
  }

  void previusDay() {
    // no waiting list in the past
    if (!possibleToGoPrevius) {
      return;
    }
    this.currentDate = currentDate.subtract(Duration(days: 1));
    updateScreen();
  }

  void updateScreen() {
    setState(() {});
  }

  List<WaitingListCustomer> generateCustomersList(dynamic customersJson) {
    List<WaitingListCustomer> customers = [];
    customersJson.forEach((phone, dataObj) {
      customers.add(WaitingListCustomer.fromJson(dataObj, phone: phone));
    });

    return customers;
  }

  Widget waitingList(BuildContext context) {
    return Expanded(
      child: Container(
        width: gWidth * .95,
        child: StreamBuilder(
          stream: WorkerData.listenToWaitingList(
              DateFormat('dd-MM-yy').format(currentDate)),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data == null ||
                  snapshot.data!.snapshot.value == null) {
                return emptyWaitingList(context);
              }
              Object? customers = snapshot.data!.snapshot.value;
              if (customers == null) {
                return emptyWaitingList(context);
              }

              List<WaitingListCustomer> customersList =
                  generateCustomersList(customers);

              return listOfCustomers(customersList);
            } else if (snapshot.hasError) {
              return emptyWaitingList(context);
            } else {
              return CircleLoadingAnimation(timeout: Duration(seconds: 10));
            }
          }),
        ),
      ),
    );
  }

  Widget listOfCustomers(List<WaitingListCustomer> customersList) {
    return ListView.builder(
        itemCount: customersList.length,
        padding: EdgeInsets.all(0),
        itemBuilder: ((context, index) {
          return waitingUserWidget(context, customersList[index]);
        }));
  }

  Widget emptyWaitingList(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: gHeight * .1, left: 40, right: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.no_accounts,
            color: Theme.of(context).textTheme.titleLarge!.color,
            size: 40,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            translate("waitingListExplain"),
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget waitingUserWidget(BuildContext context, WaitingListCustomer customer) {
    return CustomContainer(
      width: double.infinity,
      image: null,
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      boxBorder: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.onBackground.withOpacity(.2)),
      color: Theme.of(context).colorScheme.tertiary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: showCircleCachedImage(
                    '',
                    gDiagnol * 0.05,
                    customer.gender == Gender.female
                        ? defaultWomanImage
                        : defaultManImage),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                customer.name,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle),
                  child: GestureDetector(
                    onTap: () {
                      AppLauncher().launchWhatsapp(customer.phonenumber);
                    },
                    child: Icon(
                      FontAwesomeIcons.whatsapp,
                      size: gDiagnol * 0.03,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  )),
              SizedBox(
                width: 5,
              ),
              Container(
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle),
                  child: GestureDetector(
                    onTap: () {
                      AppLauncher().makePhoneCall(customer.phonenumber);
                    },
                    child: Icon(
                      Icons.call,
                      size: gDiagnol * 0.03,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  )),
            ],
          )
        ],
      ),
    );
  }
}

class _enableToOpenWaitingListState extends State<CustomersWaitingList> {
  @override
  Widget build(BuildContext context) {
    String dateAndYear = DateFormat('dd/MM/yy').format(widget.date);
    return Container(
      color: Theme.of(context).colorScheme.background,
      height: gHeight * .7,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [title(dateAndYear), emptyWaitingList(context)],
      ),
    );
  }

  Widget title(String dateAndYear) {
    return Container(
      height: gHeight * .12,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10, left: 12, right: 12),
      child: Column(
        children: [
          Text(translate("waitingList"),
              style: Theme.of(context).textTheme.titleLarge),
          Column(
            children: [
              Text(
                dateAndYear,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              Text(
                translate(weekDays[widget.date.weekday]),
                textDirection: TextDirection.ltr,
                style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget emptyWaitingList(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: gHeight * .1, left: 40, right: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.no_accounts,
            color: Theme.of(context).textTheme.titleLarge!.color,
            size: 40,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            translate("waitingListExplain"),
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
