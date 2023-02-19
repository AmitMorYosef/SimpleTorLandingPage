import 'package:flutter/material.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

import '../../../../../../app_const/app_sizes.dart';

class bankTransferDetaisSheet extends StatelessWidget {
  const bankTransferDetaisSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      height: gHeight * 0.32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
              alignment: Alignment.topCenter,
              child: Text(
                translate("transferDetails"),
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(fontSize: 20),
              )),
          SizedBox(
            height: 20,
          ),
          Text(
            "העברה בנקאית בנק לאומי",
            style:
                Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "מספר חשבון 132455264",
            style:
                Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "סכום 350 ILS",
            style:
                Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "בוצע בתאריך 25.02.22",
            style:
                Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20),
          ),
          Spacer(),
          Align(
              alignment: Alignment.topCenter,
              child: Text(
                translate("SuccessfullyCompleted"),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontSize: 20, color: Colors.green),
              )),

          // Expanded(
          //     child: ListView(
          //   shrinkWrap: true,
          //   children: [],
          // )),
          // SizedBox(
          //   height: 5,
          // ),
        ],
      ),
    );
  }
}
