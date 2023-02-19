import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/business_creation/widgets/choose_type.dart';

import '../../../../../../app_const/app_sizes.dart';
import '../../../../../../utlis/string_utlis.dart';
import '../../../../../general_widgets/custom_widgets/custom_text_form_field.dart';
import 'choose_currency.dart';
import 'choose_icon.dart';
import 'choose_theme.dart';

class DetailPage extends StatelessWidget {
  final String mapKey;
  final int index;
  final PageController controller;
  final Map<String, TextEditingController?> details;
  final Map<String, CustomTextFormField> formFields;

  DetailPage(
      {super.key,
      required this.index,
      required this.mapKey,
      required this.controller,
      required this.details,
      required this.formFields});

  Map<String, FaIcon> detailsIcons = {
    "businessName": FaIcon(FontAwesomeIcons.searchengin, size: 150),
    "businessAdress": FaIcon(FontAwesomeIcons.mapLocationDot, size: 150),
    "instagram": FaIcon(FontAwesomeIcons.instagram, size: 150),
  };

  Map<String, String> detailsText = {
    "businessName": translate("forBusinessCreation9"),
    "businessAdress": translate("forBusinessCreation10"),
    "instagram": translate("forBusinessCreation11"),
  };

  @override
  Widget build(BuildContext context) {
    switch (mapKey) {
      case "theme":
        return ChooseThemePage();
      case "icon":
        return ChooseIcon();
      case "currency":
        return ChooseCurrency();
      case "businessType":
        return ChooseType();
      default:
        return enterFormField(context, mapKey);
    }
  }

  Widget enterFormField(BuildContext context, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              detailsIcons[detail]!,
              SizedBox(
                height: 10,
              ),
              Text(translate(detail),
                  style: Theme.of(context).textTheme.headlineMedium),
              Container(
                alignment: Alignment.center,
                height: gHeight * 0.16,
                child: SingleChildScrollView(
                  child: Text(
                    detailsText[detail]!,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.7)),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              formFields[detail]!,
            ],
          ),
        ),
      ),
    );
  }
}
