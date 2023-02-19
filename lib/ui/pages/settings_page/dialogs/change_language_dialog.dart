import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:management_system_app/providers/language_provider.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_statics.dart/language_data.dart';

Future<dynamic> changeLanguageDialog(BuildContext context) async {
  LanguageProvider languageProvider = context.read<LanguageProvider>();

  dynamic resp = await genralDialog(
      animationType: DialogTransitionType.slideFromTopFade,
      context: context,
      backgroundOpacity: 1,
      title: translate('pickLnaguage'),
      content: Container(
          height: min((gHeight * .15) * languageProvider.amountOfLanguages,
              gHeight * 0.6),
          width: gWidth * .7,
          alignment: Alignment.center,
          child: SingleChildScrollView(
              child: laguageOptions(context, languageProvider))));

  return resp;
}

Widget laguageOptions(BuildContext context, LanguageProvider languageProvider) {
  List<Widget> languageItems = [];
  languageProvider.supportedLanguages.forEach((code, lang) =>
      languageItems.add(languageItem(lang, code, context, languageProvider)));
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: languageItems,
  );
}

Widget languageItem(String laguage, String code, BuildContext context,
    LanguageProvider languageProvider) {
  String? currentLang = context
      .read<LanguageProvider>()
      .supportedLanguages[LanguageData.currentLaguageCode];
  bool tapped = (currentLang == laguage) ||
      (LanguageData.currentLaguageCode == '' && laguage == 'עברית');
  return GestureDetector(
      onTap: (() => Navigator.pop(context, code)),
      child: Opacity(
        opacity: tapped ? 1 : 0.5,
        child: CustomContainer(
          color: Theme.of(context).colorScheme.secondary,
          margin: EdgeInsets.all(15),
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Text(
            laguage,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ));
}
