import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

import '../../../app_statics.dart/user_data.dart';

class PickPhoneNumber extends StatefulWidget {
  static bool validPhone = false;
  static PhoneNumber? currentPhone;
  static String completePhone = '';
  static bool somethingChanged = false;
  static Country currentCountry = Country(
    name: "Israel",
    flag: "🇮🇱",
    code: "IL",
    dialCode: "972",
    minLength: 9,
    maxLength: 9,
  );
  final TextEditingController? controller;
  final bool showFlag;
  final String? hintText;
  final String? initDialCode;
  final String? initialValue;
  final String Function()? validate;
  PickPhoneNumber(
      {super.key,
      this.controller,
      this.showFlag = true,
      this.validate,
      this.hintText,
      this.initDialCode,
      this.initialValue});

  @override
  State<PickPhoneNumber> createState() => _PickPhoneNumberState();
}

class _PickPhoneNumberState extends State<PickPhoneNumber> {
  String errorMessage = '';
  @override
  void initState() {
    PickPhoneNumber.somethingChanged = false;
    String userDialCode = UserData.user.phoneNumber.split('-')[0];
    if (widget.initDialCode != null && widget.initDialCode != '') {
      userDialCode = widget.initDialCode!.replaceAll('+', '');
    }
    // set the initial country
    PickPhoneNumber.currentCountry =
        countries.firstWhere((country) => country.dialCode == userDialCode,
            orElse: () => Country(
                  name: "Israel",
                  flag: "🇮🇱",
                  code: "IL",
                  dialCode: "972",
                  minLength: 9,
                  maxLength: 9,
                ));
    // set the initial phone number
    PickPhoneNumber.currentPhone = PhoneNumber(
        countryISOCode: PickPhoneNumber.currentCountry.code,
        countryCode: '+' + PickPhoneNumber.currentCountry.dialCode,
        number: widget.initialValue ?? '');
    // set the initial complete number
    PickPhoneNumber.completePhone = PickPhoneNumber.currentPhone!.countryCode +
        '-' +
        PickPhoneNumber.currentPhone!.number;
    // check the phone validation
    PickPhoneNumber.validPhone = isValidPhone();
    // print(PickPhoneNumber.currentCountry.name);
    // print(PickPhoneNumber.currentCountry.code);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 2.0,
                    color: (PickPhoneNumber.validPhone ||
                            PickPhoneNumber.currentPhone == null ||
                            PickPhoneNumber.currentPhone!.number == '')
                        ? Theme.of(context).colorScheme.onBackground
                        : Colors.red),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: IntlPhoneField(
              disableLengthCheck: true,
              showCountryFlag: widget.showFlag,
              initialValue: widget.initialValue,
              //invalidNumberMessage: "",
              //validator: ,
              pickerDialogStyle: PickerDialogStyle(),
              decoration: InputDecoration(
                hintText: widget.hintText ?? translate('typeHere'),
                border: InputBorder.none,
              ),
              initialCountryCode: PickPhoneNumber.currentCountry.code,
              onCountryChanged: (country) {
                // update the current complete number
                PickPhoneNumber.completePhone = PickPhoneNumber.completePhone
                    .replaceFirst('+' + PickPhoneNumber.currentCountry.dialCode,
                        '+' + country.dialCode);

                PickPhoneNumber.currentCountry = country;
                PickPhoneNumber.somethingChanged = true;
                updateScreen();
              },
              onChanged: (phone) {
                PickPhoneNumber.somethingChanged = true;
                PickPhoneNumber.currentPhone = phone;
                // update the current coplete number
                PickPhoneNumber.completePhone = phone.completeNumber
                    .replaceFirst(phone.countryCode, "${phone.countryCode}-");
                if (phone.number.length ==
                    PickPhoneNumber.currentCountry.maxLength + 1) {
                  PickPhoneNumber.completePhone =
                      phone.countryCode + '-' + phone.number.substring(1);
                }
                updateScreen();
                logger
                    .d("Complete number --> ${PickPhoneNumber.completePhone}");
              },
            ),
          ),
        ),
        displayError()
      ],
    );
  }

  Widget displayError() {
    return (PickPhoneNumber.validPhone ||
            PickPhoneNumber.currentPhone == null ||
            PickPhoneNumber.currentPhone!.number == '')
        ? SizedBox()
        : Text(
            errorMessage,
            style: TextStyle(color: Colors.red),
          );
  }

  void updateScreen({PhoneNumber? phone}) {
    setState(() {
      PickPhoneNumber.validPhone = isValidPhone(phone: phone);
    });
    // notify the controllers listiners
    if (widget.controller != null) widget.controller!.notifyListeners();
  }

  bool isValidPhone({PhoneNumber? phone}) {
    phone = phone ?? PickPhoneNumber.currentPhone;
    if (phone == null) {
      return false;
    }
    if (phone.number == '') {
      return false;
    }
    // phone length should be more then mininum length
    if (phone.number.length < PickPhoneNumber.currentCountry.minLength) {
      errorMessage = translate("shortPhone");

      return false;
    }
    // phone length should be smaller then maximum length + 1 (in case 0 start)
    if (phone.number.length > PickPhoneNumber.currentCountry.maxLength + 1) {
      errorMessage = translate("longPhone");
      return false;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(phone.number)) {
      errorMessage = translate("illegalNumber");
      return false;
    }
    if (widget.validate != null) {
      String validateMsg = widget.validate!();
      if (validateMsg != '') {
        errorMessage = validateMsg;
        return false;
      }
    }
    return true;
  }
}
