import 'package:flutter/material.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

import '../../../../../../app_const/app_sizes.dart';
import '../../../../../general_widgets/custom_widgets/custom_container.dart';

class ProductsTransacionHistorySheet extends StatelessWidget {
  const ProductsTransacionHistorySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: gHeight * .7,
      child: Column(
        children: [
          Align(
              alignment: Alignment.topCenter,
              child: Text(
                translate("productsProfit"),
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(fontSize: 20),
              )),
          SizedBox(
            height: 20,
          ),
          Expanded(
              child: ListView(
            shrinkWrap: true,
            children: [
              purchedProductIted(context, "ILS", "300.46"),
              purchedProductIted(context, "USD", "450.23"),
              purchedProductIted(context, "EUR", "220.5"),
              purchedProductIted(context, "LRS", "107.4"),
            ],
          )),
          SizedBox(
            height: 5,
          ),
          transferMomeyButton()
        ],
      ),
    );
  }

  Widget purchedProductIted(
      BuildContext context, String currency, String income) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CustomContainer(
        image: null,
        height: 70,
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.only(left: 20, top: 4, bottom: 4, right: 4),
        boxBorder:
            Border.all(width: 0, color: Color(0xFF4E4E61).withOpacity(.2)),
        color: Color(0xFF4E4E61).withOpacity(.2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$income $currency",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            transferMomeyButton()
          ],
        ),
      ),
    );
  }

  Widget transferMomeyButton() {
    return CustomContainer(
      onTap: () => print("object"),
      image: null,
      height: 70,
      raduis: 16,
      alignment: Alignment.center,
      //margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      boxBorder: Border.all(width: 0, color: Color(0xFF4E4E61).withOpacity(.2)),
      color: Color(0xFF4E4E61).withOpacity(.2),
      child: Text(translate("TransferToBank")),
    );
  }
}
