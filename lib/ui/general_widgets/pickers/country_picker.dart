import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

import '../../../app_const/app_sizes.dart';
import '../../../app_const/application_general.dart';

class CountryPicker extends StatefulWidget {
  static Country? country;
  final Country? initialCountry;
  CountryPicker({super.key, this.initialCountry});
  static Function()? validateContect;

  @override
  State<CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> {
  bool contentValid = true;
  @override
  void initState() {
    CountryPicker.country = widget.initialCountry;
    CountryPicker.validateContect = validate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() => showCountryPicker(
            countryListTheme: CountryListThemeData(
                inputDecoration: InputDecoration(
                  border: OutlineInputBorder(
                      // borderSide: BorderSide(
                      //     color: Colors.white,
                      //     width: 2.0,
                      //     strokeAlign: StrokeAlign.outside),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                ),
                borderRadius: BorderRadius.all(Radius.circular(20)),
                bottomSheetHeight: gHeight * .7,
                backgroundColor: Theme.of(context).colorScheme.background),
            context: context,
            onSelect: (Country country) {
              CountryPicker.country = country;
              validate();
            },
          )),
      child: Container(
        alignment: Alignment.center,
        height: 50,
        child: CountryPicker.country == null
            ? Text("pick country")
            : Text(CountryPicker.country!.displayNameNoCountryCode),
        decoration: BoxDecoration(
            border: Border.all(
                width: 2, color: contentValid ? Colors.white : Colors.red),
            borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
    );
  }

  void validate() {
    if (CountryPicker.country == null) {
      contentValid = false;
    } else {
      contentValid = true;
    }
    updateScreen();
  }

  void updateScreen() {
    setState(() {});
  }
}
