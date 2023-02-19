import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';

import '../../../app_const/app_default_values.dart';
import '../../../app_const/app_sizes.dart';
import '../../../app_statics.dart/settings_data.dart';
import '../../../models/currency_model.dart';

class CurrencyPicker extends StatefulWidget {
  CurrencyModel? currency;
  double ratio;
  bool insideContainer;
  Function(CurrencyModel currency)? onChanged;
  CurrencyPicker(
      {super.key,
      this.currency,
      this.onChanged,
      this.ratio = 1,
      this.insideContainer = false});

  @override
  State<CurrencyPicker> createState() => _CurrencyPickerState();
}

class _CurrencyPickerState extends State<CurrencyPicker> {
  @override
  void initState() {
    widget.currency = widget.currency ?? defaultCurrency;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.insideContainer
        ? FittedBox(
            child: CustomContainer(
                padding: EdgeInsets.all(8),
                color: Theme.of(context).colorScheme.secondary,
                onTap: () => showCurrencyPickerSheet(),
                child: currencyDetails()),
          )
        : BouncingWidget(
            child: currencyDetails(),
            onPressed: () => showCurrencyPickerSheet());
  }

  Widget currencyDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.currency!.symbol,
            style: widget.insideContainer
                ? Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontSize: 15 * widget.ratio)
                : Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 15 * widget.ratio)),
        SizedBox(width: 3),
        Text(widget.currency!.code,
            style: widget.insideContainer
                ? Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontSize: 15 * widget.ratio)
                : Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 15 * widget.ratio)),
        Icon(Icons.keyboard_arrow_up,
            size: 15 * widget.ratio,
            color: widget.insideContainer
                ? Theme.of(context).colorScheme.onSecondary
                : Theme.of(context).colorScheme.onBackground)
      ],
    );
  }

  void showCurrencyPickerSheet() {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      favorite: SettingsData.appCollection != ""
          ? [SettingsData.settings.currency.code]
          : [],
      showCurrencyName: true,
      showCurrencyCode: true,
      theme: CurrencyPickerThemeData(
          bottomSheetHeight: gHeight * 0.7,
          backgroundColor: Theme.of(context).colorScheme.background),
      onSelect: (Currency currency) {
        setState(() {
          widget.currency = CurrencyModel.fromCurrency(currency: currency);
          if (widget.onChanged != null) {
            widget.onChanged!(widget.currency!);
          }
        });
      },
    );
  }
}
