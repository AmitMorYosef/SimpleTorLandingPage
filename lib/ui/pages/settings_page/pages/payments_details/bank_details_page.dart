import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:management_system_app/app_const/rapyd.dart';
import 'package:management_system_app/providers/payments_provider.dart';
import 'package:management_system_app/ui/general_widgets/buttons/info_button.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/general_widgets/pickers/country_picker.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../../app_const/app_sizes.dart';
import '../../../../../app_const/resources.dart';
import '../../../../../app_statics.dart/user_data.dart';
import '../../../../../utlis/payment_validation.dart';
import '../../../../general_widgets/custom_widgets/custom_text_form_field.dart';
import '../../../../general_widgets/loading_widgets/loading_dialog.dart';
import '../../../../general_widgets/pickers/pick_phone_number.dart';

class BankDetaildPage extends StatelessWidget {
  Map<String, Widget> formFields = {};
  Map<String, CustomTextFormField> textFormFields = {};
  late Map<String, List<dynamic>> requiredFields;
  late List<Widget> widgetFields = [];
  BankDetaildPage({super.key});
  Widget supportedCountries() {
    return SizedBox(
      height: gHeight * .95,
      child: ListView.builder(
          itemCount: rapydSupportedCountries.keys.length,
          itemBuilder: (context, index) {
            return SizedBox(
              height: gHeight * .3,
              width: gWidth * .9,
              child:
                  supportedArea(rapydSupportedCountries.keys.toList()[index]),
            );
          }),
    );
  }

  Widget supportedArea(String area) {
    return ListView.builder(
        itemCount: rapydSupportedCountries[area]!.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Align(alignment: Alignment.center, child: Text(area));
          } else {
            return Align(
                alignment: Alignment.centerLeft,
                child:
                    Text(rapydSupportedCountries[area]!.elementAt(index - 1)));
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    initState(context);
    // RapydClient q = RapydClient();
    //q.getRequiredFields();
    return Scaffold(
        appBar: AppBar(
          actions: [
            BouncingWidget(
              child: Icon(
                Icons.contact_support,
                size: 25,
              ),
              onPressed: () {
                genralDialog(
                    context: context,
                    title: "מדינות נתמכות",
                    content: supportedCountries());
              },
            ),
            infoButton(context: context, text: translate("incomeInfo")),
          ],
          elevation: 0,
          title: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(right: 25),
              child: Text(
                  translate("personalInformation") //translate("incomesTitle")
                  )),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Center(
              child: Container(
                  width: gWidth * .95,
                  padding: EdgeInsets.only(left: 5, right: 5),
                  alignment: Alignment.center,
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      CustomContainer(
                        raduis: 40,
                        image: null,
                        color: Color(0xFF4E4E61).withOpacity(.2),
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              translate("AboutYou"),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(fontSize: 20),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            formFields['first_name']!,
                            formFields['last_name']!,
                            SizedBox(
                              height: 5,
                            ),
                            PickPhoneNumber(
                              initialValue:
                                  UserData.user.phoneNumber.split("-")[1],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CustomContainer(
                        raduis: 40,
                        image: null,
                        color: Color(0xFF4E4E61).withOpacity(.2),
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              translate("address"),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(fontSize: 20),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CountryPicker(),
                            SizedBox(
                              height: 5,
                            ),
                            formFields['city']!,
                            Row(
                              children: [
                                Expanded(
                                  child: formFields['state']!,
                                ),
                                infoButton(context: context, text: "text")
                              ],
                            ),
                            formFields['address']!,
                            formFields['postcode']!,
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CustomContainer(
                        raduis: 40,
                        image: null,
                        color: Color(0xFF4E4E61).withOpacity(.2),
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              translate("bankDetails"),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(fontSize: 20),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            formFields['account_number']!,
                            Row(
                              children: [
                                Expanded(child: formFields['aba']!),
                                infoButton(context: context, text: "text")
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      CustomContainer(
                        raduis: 20,
                        onTap: () async {
                          await saveDetails(context);
                        },
                        color: Theme.of(context).colorScheme.secondary,
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: gWidth * .1),
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                        child: Text(
                          translate("Submit"),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      )
                    ],
                  ))),
        ));
  }

  void initState(BuildContext context) {
    initControllers();
    requiredFields.forEach((key, value) {
      CustomTextFormField formField = CustomTextFormField(
        context: context,
        contentController: value[0],
        isValid: value[1],
        hintText: value[2],
        typeInput: value[3],
      );
      Widget widget = Container(
        //width: gWidth * .9,
        padding: EdgeInsets.only(top: 5),
        child: formField,
      );
      formFields[key] = widget;
      textFormFields[key] = formField;
      //widgetFields.add(widget);
    });
  }

  Future<void> saveDetails(BuildContext context) async {
    await Loading(
            displayErrorDuration: Duration(milliseconds: 2000),
            context: context,
            navigator: Navigator.of(context),
            future: context.read<PaymentsProvider>().payoutMoeny(),
            animation: successAnimation,
            msg: translate('UpdatedVacations'))
        .dialog();
    return;
    bool allValid = true;
    textFormFields.forEach((key, value) {
      print(key);
      String textToCeck = value.text ?? '';
      if (value.check != null) {
        value.check!(textToCeck);
        allValid = allValid && value.contentValid;
      }
    });
    // first validation the data
    formFields.forEach((key, value) {});
    requiredFields.forEach((key, value) {
      print((value[0] as TextEditingController).text);
    });
    CountryPicker.validateContect!();
    if (!allValid) return;
    await Loading(
            displayErrorDuration: Duration(milliseconds: 2000),
            context: context,
            navigator: Navigator.of(context),
            future: Future.delayed(Duration(seconds: 1)).then((value) => false),
            animation: successAnimation,
            msg: translate('UpdatedVacations'))
        .dialog();
    // poping the screen to the mian payments screen
    Navigator.pop(context);
  }

  void initControllers() {
    List<String> names = UserData.user.name.split(' ');
    requiredFields = {
      "first_name": [
        TextEditingController()..text = names.length > 0 ? names[0] : '',
        stringValidation,
        "shilo",
        TextInputType.text
      ],
      "last_name": [
        TextEditingController()..text = names.length > 1 ? names[1] : '',
        stringValidation,
        "saadon",
        TextInputType.text
      ],
      "address": [
        TextEditingController(),
        stringValidation,
        "bela veksner",
        TextInputType.text
      ],
      "postcode": [
        TextEditingController(),
        numbersValidation,
        '117534',
        TextInputType.number
      ],
      "city": [
        TextEditingController(),
        stringValidation,
        'Ashkelon',
        TextInputType.text
      ],
      "state": [
        TextEditingController(),
        stringValidation,
        'state in country (if have one)',
        TextInputType.text
      ],
      "country": [
        TextEditingController(),
        stringValidation,
        'israel',
        TextInputType.text
      ],
      "phonenumber": [
        TextEditingController(),
        numbersValidation,
        '${UserData.user.phoneNumber}',
        TextInputType.number
      ],
      // "email": [
      //   TextEditingController(),
      //   (String str) => '',
      //   "simplecodesa@gmail.com",
      //   TextInputType.text
      // ],
      // "date_of_birth": [
      //   TextEditingController(),
      //   (String str) => '',
      //   '25/05/22',
      //   TextInputType.text
      // ],
      "account_number": [
        TextEditingController(),
        numbersValidation,
        "account number 345-45-567",
        TextInputType.number
      ],
      // "bank_name": [
      //   TextEditingController(),
      //   (String str) => '',
      //   "bank leumi",
      //   TextInputType.text
      // ],
      // "bic_swift": [
      //   TextEditingController(),
      //   (String str) => '',
      //   "swift",
      //   TextInputType.text
      // ],
      // "ach_code": [
      //   TextEditingController(),
      //   (String str) => '',
      //   'ach code',
      //   TextInputType.number
      // ],
      "aba": [
        TextEditingController(),
        numbersValidation,
        "aba (Only for us)",
        TextInputType.number
      ],
    };
  }
}
