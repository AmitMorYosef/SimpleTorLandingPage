import 'package:flutter/material.dart';

import '../../../app_const/app_sizes.dart';
import '../../general_widgets/custom_widgets/custom_container.dart';

class UpdateCard extends StatelessWidget {
  const UpdateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        boxBorder:
            Border.all(width: 0, color: Color(0xFF4E4E61).withOpacity(.2)),
        color: Color(0xFF4E4E61).withOpacity(.2),
        // onTap:
        // () async {
        //   await SlidingBottomSheet(
        //           context: context, sheet: DifferentCurrenciesSheet(), size: 0.7)
        //       .showSheet();
        // },
        width: gWidth * .9,
        height: gHeight * .27,
        image: null,
        raduis: 30,
        child: Column(
          children: [
            Icon(
              Icons.update,
              size: 70,
              color: Theme.of(context).textTheme.titleLarge!.color,
            ),
            ElevatedButton(onPressed: (() {}), child: Text("עדכן"))
          ],
        ));
  }
}
