import 'package:flutter/material.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/payments_details/widgets/bank_transfer_details_sheet.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/payments_details/widgets/details_card.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/payments_details/widgets/products_transaction_history_sheet.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

import '../../../../../app_const/app_sizes.dart';
import '../../../../../app_const/resources.dart';
import '../../../../../app_statics.dart/worker_data.dart';
import '../../../../../utlis/image_utlis.dart';
import '../../../../general_widgets/buttons/info_button.dart';
import '../../../../general_widgets/custom_widgets/custom_container.dart';
import '../../../../general_widgets/custom_widgets/sliding_bottom_sheet.dart';
import 'bank_details_page.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            infoButton(context: context, text: translate("incomeInfo")),
          ],
          elevation: 0,
          title: Center(child: Text(translate("incomesTitle"))),
        ),
        body: workOnItWidget(context));
  }

  Widget page(BuildContext context) {
    return Center(
      child: Container(
        width: gWidth * .95,
        padding: EdgeInsets.only(left: 5, right: 5, top: 0),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => BankDetaildPage()));
                  },
                  child: SizedBox(
                    width: 80,
                    child: Column(
                      children: [
                        showCircleCachedImage(
                            WorkerData.worker.profileImg, 80, defaultManImage),
                        Text(
                          translate("UpdateDetails"),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      translate("HelloComma"),
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    // SizedBox(
                    //   height: 5,
                    // ),
                    Text(
                      "שילה סעדון",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            DetailsCard(),
            SizedBox(
              height: 5,
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  getPayiedfromItem(context, Colors.red, Icon(Icons.home),
                      translate('products')),
                  getPayiedfromItem(context, Colors.blue, Icon(Icons.home),
                      translate('orders')),
                  getPayiedfromItem(context, Colors.green, Icon(Icons.home),
                      translate('general')),
                ],
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Text(
              translate("transfersHistory"),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              //height: 200,
              child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: ((context, index) {
                    return transactionHistoeyWidget(context,
                        translate("bankTransfer"), "בוצע ב - 25.02.22");
                  })),
              //color: Colors.red,
            )
          ],
        ),
      ),
    );
  }

  Widget transactionHistoeyWidget(
      BuildContext context, String title, String details) {
    return GestureDetector(
      onTap: () async {
        await SlidingBottomSheet(
                context: context, sheet: bankTransferDetaisSheet(), size: 0.32)
            .showSheet();
      },
      child: CustomContainer(
        image: null,
        height: 70,
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        boxBorder:
            Border.all(width: 0, color: Color(0xFF4E4E61).withOpacity(.2)),
        color: Color(0xFF4E4E61).withOpacity(.2),
        child: Row(
          children: [
            Icon(
              Icons.food_bank_outlined,
              size: 50,
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontSize: 20),
                ),
                Text(
                  details,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget getPayiedfromItem(
      BuildContext context, Color color, Icon icon, String title) {
    return GestureDetector(
      onTap: () async {
        await SlidingBottomSheet(
                context: context,
                sheet: ProductsTransacionHistorySheet(),
                size: 0.7)
            .showSheet();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width: 60,
              height: 60,
              child: icon,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.all(Radius.circular(15)),
              )),
          Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          )
        ],
      ),
    );
  }

  Widget workOnItWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: gHeight * .1),
      color: Theme.of(context).colorScheme.background,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment_outlined,
            color: Colors.grey,
            size: gWidth * .3,
          ),
          SizedBox(
            width: gWidth * .9,
            child: Text(
              translate("incomeSoonInfo"),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
