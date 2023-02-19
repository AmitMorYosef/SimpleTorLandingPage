import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:management_system_app/providers/worker_provider.dart';
import 'package:management_system_app/ui/general_widgets/buttons/info_button.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:management_system_app/utlis/times_utlis.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/application_general.dart';
import '../../../../app_statics.dart/worker_data.dart';

class StatisticsPage extends StatefulWidget {
  StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late WorkerProvider workerProvider;

  int bookingsCount = 0;
  double futureIncome = 1, income = 0;
  Map<String, int> treatmentsData = {};
  Map<String, int> clientsData = {};
  Map<String, double> workData = {
    translate("futureBookings"): 0,
    translate("workHours"): 0,
    translate("vacationsDays"): 0,
    translate("hourWage"): 0,
  };
  String currentClick = translate("clients");
  final String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    WorkerData.loadMonthlyBookingsData();
    DateTime currentMonth = setToStartOfMonth(DateTime.now());
    String dateAndYear = DateFormat('MM-yyyy').format(currentMonth);
    //workerProvider = context.read<WorkerProvider>();

    return Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
            bottom: false,
            child: Scaffold(
                appBar: AppBar(
                  //backgroundColor: Theme.of(context).colorScheme.surface,
                  elevation: 2,
                  title: Center(
                    child: Text(
                      dateAndYear,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                  actions: [
                    infoButton(
                        context: context, text: translate("StatisticsInfo"))
                  ],
                  leading: backBotton(),
                ),
                backgroundColor: Theme.of(context).colorScheme.background,
                body: Center(
                  child: FutureBuilder(
                    future: WorkerData.loadMonthlyBookingsData(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return loadingData();
                      }
                      initialWorkerData();
                      return statisticsPage();
                    },
                  ),
                ))));
  }

  Widget loadingData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleLoadingAnimation(timeout: Duration(seconds: 10)),
            SizedBox(
              height: 10,
            ),
            Text(
              translate("RetrievingData"),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
            )
          ],
        ),
        SizedBox(
          height: 80,
        )
      ],
    );
  }

  Widget statisticsPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: gWidth,
          padding: EdgeInsets.only(bottom: 15),
          margin: EdgeInsets.only(bottom: 5),
          height: gHeight * 0.53,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(24),
                bottomLeft: Radius.circular(24)),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              //backBotton(),
              Container(
                //padding: EdgeInsets.only(top: 40),
                height: gHeight * .353,
                width: gHeight * .353,
                child: moneyIndicator(),
              ),
              SizedBox(
                width: gWidth * 0.88,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    tabCliker(translate("clients")),
                    tabCliker(translate("treatments")),
                    tabCliker(translate("work"))
                  ],
                ),
              )
            ],
          ),
        ),
        categoryWidget(),
        itemsList()
      ],
    );
  }

  Widget backBotton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.only(top: 10, right: 10),
        height: 40,
        alignment: Alignment.centerRight,
        width: gWidth,
        child: Icon(
          Icons.chevron_left,
          size: 40,
        ),
      ),
    );
  }

  Widget categoryWidget() {
    return Container(
      alignment: Alignment.center,
      width: gWidth * 0.88,
      height: gHeight * 0.064,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: SizedBox(
        width: gWidth * 0.83,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomContainer(
                padding: EdgeInsets.symmetric(horizontal: 10),
                raduis: 16,
                width: gWidth * 0.31,
                height: gHeight * 0.048,
                child: Center(child: Text(translate("name")))),
            CustomContainer(
                padding: EdgeInsets.symmetric(horizontal: 10),
                raduis: 16,
                width: gWidth * 0.31,
                height: gHeight * 0.048,
                child: Center(
                    child: Text(
                  this.currentClick == translate("work")
                      ? translate("amount")
                      : translate("bookingsAmount"),
                  textAlign: TextAlign.center,
                ))),
          ],
        ),
      ),
    );
  }

  Widget itemsList() {
    var dataToshow = {};
    if (currentClick == translate("clients"))
      dataToshow = this.clientsData;
    else if (currentClick == translate("treatments"))
      dataToshow = this.treatmentsData;
    else if (currentClick == translate("work")) dataToshow = this.workData;
    if (dataToshow.length == 0) {
      return notEnoughData();
    }

    return Expanded(
      child: SizedBox(
        width: gWidth * 0.88,
        child: ListView.builder(
            itemCount: dataToshow.length,
            itemBuilder: ((context, index) {
              return dataItem(dataToshow.keys.elementAt(index),
                  dataToshow.values.elementAt(index));
            })),
      ),
    );
  }

  Widget notEnoughData() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(bottom: 50),
        alignment: Alignment.center,
        width: gWidth * .8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_graph,
              size: 50,
              color: Theme.of(context).textTheme.titleLarge!.color,
            ),
            Text(
              translate("NoStatisticsData"),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            )
          ],
        ),
      ),
    );
  }

  Widget dataItem(String text, dynamic count) {
    Icon icon = Icon(Icons.thirteen_mp);
    if (currentClick == translate("clients"))
      icon = Icon(Icons.person_rounded);
    else if (currentClick == translate("treatments"))
      icon = Icon(Icons.list_alt);
    else if (currentClick == translate("work"))
      icon = Icon(Icons.auto_graph_sharp);

    if ("${count.toStringAsFixed(1)}" == "${double.parse("$count")}") {
      count = count.toStringAsFixed(0);
    } else {
      count = count.toStringAsFixed(2);
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      alignment: Alignment.center,
      width: gWidth * 0.88,
      height: gHeight * 0.09,
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.tertiary, // surface.withOpacity(0.2),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: SizedBox(
        width: gWidth * 0.8,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                icon,
                SizedBox(
                  width: 10,
                ),
                Text(text),
              ],
            ),
            Text("$count")
          ],
        ),
      ),
    );
  }

  Widget tabCliker(String tag) {
    return CustomContainer(
        color: currentClick == tag
            ? Theme.of(context).colorScheme.secondary
            : null,
        onTap: () {
          setState(() {
            this.currentClick = tag;
          });
        },
        raduis: 16,
        width: gWidth * 0.28,
        height: gHeight * 0.083,
        child: Center(
            child: Text(
          tag,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 17,
              color: currentClick == tag ? Colors.white : Colors.grey),
        )));
  }

  Widget moneyIndicator() {
    return SfRadialGauge(axes: <RadialAxis>[
      RadialAxis(
        annotations: <GaugeAnnotation>[
          GaugeAnnotation(
              positionFactor: 0.1,
              angle: 90,
              widget: SizedBox(
                height: gHeight * .25,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(),
                    Column(
                      children: [
                        Text(
                          '${income.toStringAsFixed(0)}₪',
                          style: TextStyle(fontSize: 27),
                        ),
                        Text(translate("yourRevenues")),
                      ],
                    ),
                    Text(
                      "$currentDate",
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
              ))
        ],
        pointers: <GaugePointer>[
          RangePointer(
            color: Theme.of(context).colorScheme.secondary,
            value: income,
            cornerStyle: CornerStyle.bothCurve,
            width: 0.15,
            sizeUnit: GaugeSizeUnit.factor,
          )
        ],
        minimum: 0,
        maximum: futureIncome,
        showLabels: false,
        showTicks: false,
        axisLineStyle: AxisLineStyle(
          thickness: 0.15,
          gradient: SweepGradient(colors: <Color>[
            Color(0xFF00a9b5).withOpacity(0.3),
            Color(0xFFa4edeb).withOpacity(0.3)
          ], stops: <double>[
            0.25,
            0.75
          ]),
          cornerStyle: CornerStyle.bothCurve,
          color: Color(0xff4E4E61).withOpacity(0.2),
          thicknessUnit: GaugeSizeUnit.factor,
        ),
      )
    ]);
  }

  void initialWorkerData() {
    bookingsCount = 0;
    futureIncome = 1;
    income = 0;
    treatmentsData = {};
    clientsData = {};
    workData = {
      translate("futureBookings"): 0,
      translate("workHours"): 0,
      translate("vacationsDays"): 0,
      translate("hourWage"): 0,
    };
    WorkerData.worker.vacations.keys.forEach((element) {
      DateTime elementDate = DateFormat('dd-MM-yyyy').parse(element);
      if (elementDate.month == DateTime.now().month &&
          elementDate.year == DateTime.now().year) {
        workData[translate("vacationsDays")] =
            workData[translate("vacationsDays")]! + 1;
      }
    });
    bookingsCount = WorkerData.monthlyBookingsData.length;
    WorkerData.monthlyBookingsData.forEach((key, value) {
      value.forEach((key, booking) {
        if (booking.bookingDate.month == DateTime.now().month &&
            booking.bookingDate.year == DateTime.now().year) {
          if (clientsData.containsKey(booking.customerName)) {
            clientsData[booking.customerName] =
                clientsData[booking.customerName]! + 1;
          } else
            clientsData[booking.customerName] = 1;
          if (this.treatmentsData.containsKey(booking.treatment.name)) {
            this.treatmentsData[booking.treatment.name] =
                this.treatmentsData[booking.treatment.name]! + 1;
          } else
            this.treatmentsData[booking.treatment.name] = 1;
          int treatTime = booking.treatment.totalMinutes;
          workData[translate("workHours")] =
              workData[translate("workHours")]! + (treatTime / 60);
          double price = booking.treatment.price!.amount;
          if (price == 0) {
            try {
              price = booking.treatment.price!.amount;
            } catch (e) {
              logger.e("Error while getting the booking price --> $e");
            }
          }

          if (!booking.bookingDate.isAfter(DateTime.now())) {
            income += price;
          } else {
            workData[translate("futureBookings")] =
                workData[translate("futureBookings")]! + 1;
          }
          futureIncome += price;
        }
      });
    });
    if (workData[translate("workHours")] != 0) {
      workData[translate("hourWage")] =
          futureIncome / workData[translate("workHours")]!;
    }
  }
}
