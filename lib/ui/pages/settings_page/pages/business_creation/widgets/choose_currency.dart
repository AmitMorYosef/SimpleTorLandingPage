import 'package:flutter/material.dart';

import '../../../../../../app_const/app_sizes.dart';
import '../../../../../../models/currency_model.dart';
import '../../../../../../utlis/string_utlis.dart';
import '../make_new_buisness.dart';

class ChooseCurrency extends StatefulWidget {
  ChooseCurrency({super.key});

  @override
  State<ChooseCurrency> createState() => _ChooseCurrencyState();
}

class _ChooseCurrencyState extends State<ChooseCurrency> {
  @override
  void initState() {
    MakeNewBuisness.currencyPicker!.onChanged = setCurrency;

    super.initState();
  }

  void setCurrency(CurrencyModel currency) {
    setState(() {
      MakeNewBuisness.currencyPicker!.currency = currency;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(MakeNewBuisness.currencyPicker!.currency!.symbol,
              style: TextStyle(fontSize: 140)),
          Text(translate("chooseCurrency"),
              style: Theme.of(context).textTheme.headlineMedium),
          Container(
            alignment: Alignment.center,
            height: gHeight * 0.14,
            child: Text(
              translate("currencyExplain"),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          MakeNewBuisness.currencyPicker!
        ],
      ),
    );
  }
}
