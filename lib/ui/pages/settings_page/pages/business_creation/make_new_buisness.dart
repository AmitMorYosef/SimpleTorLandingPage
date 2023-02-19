// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:management_system_app/app_statics.dart/user_data.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/business_creation/widgets/continue_button.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/business_creation/widgets/detail_page.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../../app_const/app_default_values.dart';
import '../../../../../app_const/app_sizes.dart';
import '../../../../../app_const/business_types.dart';
import '../../../../../app_const/resources.dart';
import '../../../../../app_statics.dart/settings_data.dart';
import '../../../../../app_statics.dart/theme_data.dart';
import '../../../../../providers/manager_provider.dart';
import '../../../../../providers/settings_provider.dart';
import '../../../../../providers/theme_provider.dart';
import '../../../../../services/errors_service/app_errors.dart';
import '../../../../../services/errors_service/messages.dart';
import '../../../../../utlis/general_utlis.dart';
import '../../../../../utlis/validations_utlis.dart';
import '../../../../general_widgets/custom_widgets/bottom_bar.dart';
import '../../../../general_widgets/custom_widgets/custom_text_form_field.dart';
import '../../../../general_widgets/loading_widgets/loading_dialog.dart';
import '../../../../general_widgets/pickers/choose_theme.dart';
import '../../../../general_widgets/pickers/currency_picker.dart';
import '../../../../general_widgets/pickers/pick_circle_image.dart';

class MakeNewBuisness extends StatefulWidget {
  static CurrencyPicker? currencyPicker = CurrencyPicker(
    ratio: 1.3,
    insideContainer: true,
    currency: SettingsData.appCollection != ""
        ? SettingsData.settings.currency
        : defaultCurrency,
  );

  static BusinessesTypes businessType = BusinessesTypes.other;

  static int currentIndex = 0;

  MakeNewBuisness({super.key});

  @override
  State<MakeNewBuisness> createState() => _MakeNewBuisnessState();
}

class _MakeNewBuisnessState extends State<MakeNewBuisness> {
  PageController controller = PageController();

  @override
  void dispose() {
    ChooseTheme.currentTheme = null; // emty selected theme for text time
    super.dispose();
  }

  @override
  void initState() {
    MakeNewBuisness.currentIndex = 0;
    PickCircleImage.imageForBusiness = null;
    MakeNewBuisness.businessType = BusinessesTypes.other;
    super.initState();
  }

  Map<String, TextEditingController?> details = {
    "businessName": TextEditingController(),
    "businessType": null,
    "theme": null,
    "icon": null,
    "currency": null,
    "businessAdress": TextEditingController(),
    "instagram": TextEditingController(),
    //"purchase": null,
  };

  late Map<String, CustomTextFormField> formFields;

  List<Widget> detailsWidgets = [];

  @override
  Widget build(BuildContext context) {
    formFields = {
      "businessName": CustomTextFormField(
          context: context,
          hintText: 'Simple Tor',
          isValid: shopNameValidation,
          typeInput: TextInputType.text,
          contentController: details["businessName"]!),
      "businessAdress": CustomTextFormField(
          context: context,
          hintText: translate("adressSample"),
          isValid: adressValidation,
          typeInput: TextInputType.text,
          contentController: details["businessAdress"]!),
      "instagram": CustomTextFormField(
          context: context,
          hintText: 'simple_tor',
          isValid: instagramValidation,
          typeInput: TextInputType.text,
          contentController: details["instagram"]!),
    };
    if (detailsWidgets.length < details.length) {
      details.keys
          .toList()
          .asMap()
          .forEach((index, key) => detailsWidgets.add(DetailPage(
                index: index,
                mapKey: key,
                controller: controller,
                formFields: formFields,
                details: details,
              )));
    }

    return WillPopScope(
      onWillPop: () async {
        await UiManager.updateUi(
            context: context,
            perform: context
                .read<ThemeProvider>()
                .changeTheme(context, AppThemeData.currentKeyTheme!));
        return true;
      },
      child: GestureDetector(
        onTap: () {
          overLaysHandling();
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          extendBody: true,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            elevation: 0,
            title: Text(translate("buisnessCreation")),
          ),
          body: Column(
            children: [
              Expanded(
                child: PageView(
                  reverse: true,
                  physics: NeverScrollableScrollPhysics(),
                  controller: controller,
                  children: detailsWidgets,
                  onPageChanged: ((value) {
                    MakeNewBuisness.currentIndex = value;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  }),
                ),
              ),
              BottomBar(
                  pageController: controller,
                  screenCount: detailsWidgets.length,
                  onDotClicked: onDotClicked),
              continueButton(
                  details.keys.elementAt(MakeNewBuisness.currentIndex),
                  context,
                  controller),
              SizedBox(
                height: gHeight * 0.09,
              )
            ],
          ),
        ),
      ),
    );
  }

  void onDotClicked({required int screenIndex}) {
    if (screenIndex < MakeNewBuisness.currentIndex) {
      final jump = MakeNewBuisness.currentIndex - screenIndex;
      animateToPage(screenIndex, max(jump * 150, 250));
      MakeNewBuisness.currentIndex = screenIndex;
    }
  }

  void animateToPage(int screenIndex, int miliseconds) {
    controller.animateToPage(screenIndex,
        duration: Duration(milliseconds: miliseconds), curve: Curves.linear);
  }

  Widget continueButton(
      String key, BuildContext context, PageController controller) {
    TextEditingController? textController = details[key];
    CustomTextFormField? textFormField = formFields[key];

    return ContinueButton(
        width: gWidth * 0.9,
        controller: controller,
        pagesLength: details.length,
        onTap: () async {
          if (textController != null) {
            textController.text = textController.text.trim();
            if (!textFormField!.contentValid) {
              if (key == "businessName" && details[key]!.text == "")
                textFormField
                    .check!(""); // empty name validation anter clicking
              return;
            }
          }
          if (MakeNewBuisness.currentIndex == details.length - 1) {
            await Loading(
                    context: context,
                    navigator: Navigator.of(context),
                    future: createBuisness(context),
                    animation: successAnimation,
                    msg: translate("businessCreated"),
                    timeOutDuration: Duration(seconds: 10))
                .dialog();
            Navigator.pop(context);
          } else {
            animateToPage(MakeNewBuisness.currentIndex + 1, 250);
          }
        });
  }

  Future<bool> createBuisness(BuildContext context) async {
    details.forEach((key, value) {
      if (value != null) details[key] == value.text.trim();
    });
    final buisnessId = await context.read<ManagerProvider>().createBuisness(
        context: context,
        revenueCatId: UserData.user.revenueCatId,
        productId: "",
        businessType: MakeNewBuisness.businessType,
        businessName: details["businessName"]!.text,
        adress: details["businessAdress"]!.text,
        instagram: details["instagram"]!.text,
        theme: ChooseTheme.currentTheme ?? AppThemeData.currentKeyTheme!,
        currency: MakeNewBuisness.currencyPicker!.currency!);

    bool resp = true;
    if (buisnessId != '') {
      overLaysHandling();
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
      resp = resp &&
          await context
              .read<SettingsProvider>()
              .loadBuisness(context, buisnessId);
      if (PickCircleImage.imageForBusiness != null) {
        await SettingsData.updateShopIcon(PickCircleImage.imageForBusiness);
        PickCircleImage.imageForBusiness = null;
      }
    } else {
      AppErrors.error = Errors.notFoundItem;
      return false;
    }
    return resp;
  }
}
