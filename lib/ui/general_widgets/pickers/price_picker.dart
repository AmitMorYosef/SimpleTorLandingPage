import 'package:flutter/material.dart';
import 'package:management_system_app/ui/general_widgets/pickers/currency_picker.dart';

import '../../../app_statics.dart/settings_data.dart';
import '../../../models/currency_model.dart';
import '../../../models/price_model.dart';
import '../../../utlis/validations_utlis.dart';

class PricePicker extends StatefulWidget {
  TextEditingController priceController = TextEditingController();
  final CurrencyModel? initialCurrency;
  final String initialAmount;
  Function? check;
  Price price = Price(amount: "0", currency: null);
  bool contentValid = true;
  CurrencyPicker? currencyPicker;
  PricePicker({super.key, this.initialCurrency, this.initialAmount = ""});

  @override
  State<PricePicker> createState() => _PricePickerState();
}

class _PricePickerState extends State<PricePicker> {
  String validationText = "";

  void onChanged(String text) {
    widget.price.amount = double.tryParse(widget.priceController.text) ?? 00.00;
    validationText = priceValidation(text.trim());
    if (validationText == '') {
      valid();
    } else {
      notvValid();
    }
  }

  void valid() {
    setState(() {
      widget.contentValid = true;
    });
  }

  void notvValid() {
    setState(() {
      widget.contentValid = false;
    });
  }

  @override
  void initState() {
    widget.check = onChanged;
    widget.price.amount = double.tryParse(widget.initialAmount) ?? 00.00;
    widget.priceController.text = widget.initialAmount;
    widget.price.currency =
        widget.initialCurrency ?? SettingsData.settings.currency;
    widget.currencyPicker = CurrencyPicker(
        currency: widget.initialCurrency ?? SettingsData.settings.currency,
        onChanged: setCurrency);

    super.initState();
  }

  void setCurrency(currency) {
    widget.price.currency = currency;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 200,
          decoration: BoxDecoration(
              border: Border.all(
                width: 2.0,
                color: validationText != ''
                    ? Colors.red
                    : Theme.of(context).colorScheme.onBackground,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [amountField(), widget.currencyPicker!],
          ),
        ),
        Text(validationText)
      ],
    );
  }

  Widget amountField() {
    return Expanded(
      child: TextFormField(
          keyboardAppearance: Theme.of(context).brightness,
          cursorColor: Theme.of(context).colorScheme.secondary,
          controller: widget.priceController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => onChanged(value),
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.price.currency == null
                  ? "00.00"
                  : "00.00" + widget.price.currency!.symbol,
              hintStyle: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.5)))),
    );
  }
}
