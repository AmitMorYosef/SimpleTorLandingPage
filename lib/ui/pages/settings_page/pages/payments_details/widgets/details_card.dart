import 'package:flutter/material.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/payments_details/widgets/different_currecies_sheet.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

import '../../../../../../app_const/app_sizes.dart';
import '../../../../../general_widgets/custom_widgets/sliding_bottom_sheet.dart';

class DetailsCard extends StatelessWidget {
  const DetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      boxBorder: Border.all(width: 0, color: Color(0xFF4E4E61).withOpacity(.2)),
      color: Color(0xFF4E4E61).withOpacity(.2),
      onTap: () async {
        await SlidingBottomSheet(
                context: context, sheet: DifferentCurrenciesSheet(), size: 0.7)
            .showSheet();
      },
      width: gWidth,
      height: gHeight * .27,
      raduis: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate("CurrentMoney"),
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w100,
                color: Colors.grey[400]),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "350.70 USD",
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Spacer(),
          Text(
            "העברה אחרונה - 25.02.22",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w100,
                color: Colors.grey[400]),
          )
        ],
      ),
    );
  }
}
