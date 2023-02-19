import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/pages/manually_booking_page/widgets/get_break_details.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_statics.dart/worker_data.dart';

class BadDurationWidget extends StatelessWidget {
  final double height = gHeight * 0.1;
  final DateTime start, end;

  BadDurationWidget({super.key, required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    final duration = end.difference(start);
    final heightDiffrence = duration.inMinutes * .50;
    String strStart = DateFormat('HH:mm').format(start);
    String strEnd = DateFormat('HH:mm').format(end);
    return GestureDetector(
      onTap: () async => makeBreak(context, strStart, duration),
      child: CustomContainer(
          alignment: Alignment.center,
          width: gWidth,
          margin: EdgeInsets.symmetric(vertical: 3, horizontal: 2),
          padding: EdgeInsets.symmetric(
            vertical: heightDiffrence,
          ),
          raduis: 16,
          needImage: false,
          color: Colors.red.withOpacity(0.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 20),
              Column(
                children: [
                  Text(translate("deadTime")),
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text("$strStart - $strEnd"))
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.add),
              )
            ],
          )),
    );
  }

  Future<void> makeBreak(
      BuildContext context, String strStart, Duration duration) async {
    await GetBreakDetails().addBreakFields(context,
        needDuration: false,
        start: strStart,
        day: DateFormat("dd-MM-yyyy").format(WorkerData.focusedDay),
        duration: duration);
  }
}
