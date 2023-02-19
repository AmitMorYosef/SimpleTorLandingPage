import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:management_system_app/app_statics.dart/subscription_data.dart';
import 'package:management_system_app/models/preview_model.dart';
import 'package:management_system_app/ui/general_widgets/pickers/currency_picker.dart';
import 'package:management_system_app/ui/general_widgets/pickers/pick_phone_number.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/business_types.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../utlis/image_utlis.dart';
import '../../../../utlis/validations_utlis.dart';
import '../../../general_widgets/buttons/info_button.dart';
import '../../../general_widgets/custom_widgets/custom_text_form_field.dart';
import '../../../general_widgets/custom_widgets/custom_toast.dart';
import '../../../general_widgets/custom_widgets/sliding_bottom_sheet.dart';
import '../../../general_widgets/custom_widgets/subscriptions_details.dart';
import '../../../general_widgets/pickers/pick_circle_image.dart';
import '../../../general_widgets/pickers/search_bottom_sheet_picker.dart';

// ignore: must_be_immutable
class AppDetails extends StatefulWidget {
  AppDetails({super.key});

  @override
  State<AppDetails> createState() => _AppDetailsState();
}

class _AppDetailsState extends State<AppDetails> {
  late SettingsProvider settingsProvider;

  late Map<String, String> details;

  late Map<String, TextEditingController> controllers;

  late Map<String, CustomTextFormField> formFields;

  BusinessesTypes businessType = SettingsData.settings.businesseType;

  CurrencyPicker currencyPicker = CurrencyPicker(
    ratio: 1.5,
    currency: SettingsData.settings.currency,
  );
  Map<String, BusinessesTypes> businessTypeInterpter = {};

  late SearchBotttomSheetPicker businessTypePicker;

  String buisnessName = translate('businessName');
  String phone = translate('phoneNumber');
  String instagram = translate('instagram');
  String address = translate('businessAdress');

  @override
  void initState() {
    super.initState();
    /*Business type initializition */
    businessTypeInterpter = loadBusinessesTypesIntepeter();
    final businessesList = businessTypeInterpter.keys.toList();
    businessesList.sort();
    businessTypePicker = SearchBotttomSheetPicker(
        choosenItem:
            translate(businessTypeToStr[SettingsData.settings.businesseType]!),
        items: businessesList,
        title: translate("chooseBusinessType"));

    businessTypePicker.onChanged = setType;
    businessTypePicker.itemBuilder = singleBusinessTypeItem;

    details = {
      buisnessName: SettingsData.settings.shopName,
      instagram: SettingsData.settings.instagramAccount,
      address: SettingsData.settings.adress
    };
    controllers = {
      buisnessName: TextEditingController(text: details[buisnessName]),
      instagram: TextEditingController(text: details[instagram]),
      address: TextEditingController(text: details[address])
    };
    formFields = {
      buisnessName: CustomTextFormField(
        context: context,
        contentController: controllers[buisnessName]!,
        isValid: shopNameValidation,
        typeInput: TextInputType.text,
      ),
      instagram: CustomTextFormField(
        context: context,
        contentController: controllers[instagram]!,
        isValid: instagramValidation,
        typeInput: TextInputType.text,
      ),
      address: CustomTextFormField(
        context: context,
        contentController: controllers[address]!,
        isValid: adressValidation,
        typeInput: TextInputType.text,
      )
    };
  }

  void setType(String? type) {
    setState(() {
      if (type != null) {
        businessType = businessTypeInterpter[type]!;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controllers.forEach((key, value) {
      value.text = value.text.trim();
    });
    saveData();
  }

  @override
  Widget build(BuildContext context) {
    settingsProvider = context.watch<SettingsProvider>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            actions: [
              subscriptionButton(),
              infoButton(
                  context: context, text: translate('hereYouEditDetails')),
            ],
            elevation: 0,
            title: Text(translate('buisnessDetails')),
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: gWidthOriginal,
                    child: Row(
                      children: [
                        SizedBox(
                            width: gHeight * 0.16, child: chooseIcon(context)),
                        Expanded(
                            child: Column(
                          children: [
                            detailWidget(context, details.keys.elementAt(0)),
                            currencyPicker,
                          ],
                        )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: gWidth * 0.95,
                    child: Column(
                      children: [
                        businessTypeIndicator(),
                        businessTypePicker,
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  detailWidget(context, details.keys.elementAt(1)),
                  detailWidget(context, details.keys.elementAt(2)),
                  phoneField(),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    translate("createdAt") +
                        ": " +
                        DateFormat('dd-MM-yyyy')
                            .format(SettingsData.settings.createdAt),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontSize: 17),
                  )
                ],
              ),
            ),
          )),
    );
  }

  Widget businessTypeIndicator() {
    return SettingsData.appCollection != ""
        ? Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  translate(businessTypeToStr[businessType]!),
                  style: TextStyle(fontSize: gDiagnol * 0.02),
                ),
                SizedBox(width: 10),
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn),
                  child: Image.asset(
                    businessTypesToIcon[businessType]!,
                    width: gDiagnol * 0.05,
                    height: gDiagnol * 0.05,
                  ),
                ),
              ],
            ),
          )
        : SizedBox();
  }

  Widget subscriptionButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, top: 4),
      child: BouncingWidget(
          onPressed: () async {
            if (SubscriptionData.purchaseDetails == null) {
              if (SettingsData.settings.productId != "" ||
                  SettingsData.settings.workersProductsId != "" ||
                  SettingsData.settings.pendingProductId != "" ||
                  SettingsData.settings.pendingWorkersProductsId != "") {
                SubscriptionData.setPurchaseDescriptions();
              }
            }
            await SlidingBottomSheet(
                    context: context,
                    sheet: BusinessSubscriptionsDetails(),
                    size: 1)
                .showSheet();
          },
          child: Icon(Icons.list_alt, size: 30)),
    );
  }

  Widget phoneField() {
    String currentPhone = SettingsData.settings.shopPhone;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(phone + ':'),
        PickPhoneNumber(
          initialValue: currentPhone == '' ? null : currentPhone.split('-')[1],
          initDialCode: currentPhone.split('-')[0],
        ),
      ],
    );
  }

  Widget detailWidget(BuildContext context, String key) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          translate('businessName') != key ? Text(key + ":") : SizedBox(),
          formFields[key]!
        ],
      ),
    );
  }

  Widget chooseIcon(BuildContext context) {
    return PickCircleImage(
      delete: confirmDelete,
      upload: uploadImage,
      radius: gHeight * 0.11,
      currentImage: SettingsData.settings.shopIconUrl == ""
          ? null
          : showCircleCachedImage(SettingsData.settings.shopIconUrl,
              gHeight * 0.11, SettingsData.businessIcon!),
    );
  }

  Widget singleBusinessTypeItem(
      BuildContext context, String item, bool isSelected) {
    final businessType = businessTypeInterpter[item];
    return Opacity(
      opacity: isSelected ? 0.5 : 1,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 10,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(item),
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn),
                child: Image.asset(
                  businessTypesToIcon[businessType]!,
                  width: 30,
                  height: 30,
                ),
              ),
            ]),
            Divider()
          ],
        ),
      ),
    );
  }

  Future<bool> saveData() async {
    if (PickPhoneNumber.somethingChanged) {
      // only if user changed something
      if (PickPhoneNumber.validPhone) {
        // valid phone - update (same phone provider ignore)
        await settingsProvider.updateShopPhone(PickPhoneNumber.completePhone);
      } else if (PickPhoneNumber.currentPhone!.number == '') {
        // invalid - if empty -> delete phone
        await settingsProvider.updateShopPhone('');
      }
    }

    if (currencyPicker.currency != SettingsData.settings.currency) {
      await settingsProvider.updateCurrency(currencyPicker.currency!);
    }

    if (businessType != SettingsData.settings.businesseType) {
      await settingsProvider.updateBusinessType(businessType);
    }

    if (details[instagram] != controllers[instagram]!.text.trim() &&
        formFields[instagram]!.contentValid)
      await settingsProvider
          .updateInstagramAccount(controllers[instagram]!.text.trim());

    if (details[address] != controllers[address]!.text.trim() &&
        formFields[address]!.contentValid)
      await settingsProvider.updateAddress(controllers[address]!.text.trim());

    if (details[buisnessName] != controllers[buisnessName]!.text.trim() &&
        formFields[buisnessName]!.contentValid &&
        !isDuplicate(controllers[buisnessName]!.text.trim())) {
      await settingsProvider
          .updateShopName(controllers[buisnessName]!.text.trim());
    }
    return true;
  }

  bool isDuplicate(String shopName) {
    final buisnesses = SettingsData.buisnessesPreview.buisnesses;

    final preview = buisnesses.values.singleWhere(
        (value) => value.name == shopName,
        orElse: () => Preview());

    if (preview.name == shopName.trim()) {
      CustomToast(
              context: context,
              msg: translate('buisnessNameTaken'),
              gravity: ToastGravity.BOTTOM)
          .init();
      return true;
    }
    return false;
  }
}
