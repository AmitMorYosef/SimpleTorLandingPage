import 'package:flutter/material.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_divider.dart';
import 'package:management_system_app/ui/helpers/fonts_helper.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/business_fonts_management/widgets/block_fonts.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/business_fonts_management/widgets/font_text.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/business_fonts_management/widgets/phone_fonts_example.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/business_fonts_management/widgets/use_default_switch.dart';

import '../../../../../app_const/app_sizes.dart';
import '../../../../../app_const/fonts.dart';
import '../../../../../app_statics.dart/settings_data.dart';
import '../../../../../utlis/string_utlis.dart';
import '../../../../general_widgets/buttons/info_button.dart';

class BusinessFontsManager extends StatefulWidget {
  const BusinessFontsManager({super.key});
  static String? savedFont = '';
  static bool? useDefault = true;
  static void Function()? lastSelectedFontChangeState = () {};
  static void Function()? currentFontChangeState = () {};
  static void Function()? setPhoneState = () {};
  static void Function(bool)? setBlockFontsState = (_) {};

  @override
  State<BusinessFontsManager> createState() => _BusinessFontsManagerState();
}

class _BusinessFontsManagerState extends State<BusinessFontsManager> {
  String displayFont = '';
  String currentBusinessFont = '';
  Languages langFilter = Languages.all;
  List<DropdownMenuItem<Languages>> laguagesOptions = [];
  @override
  void initState() {
    super.initState();
    BusinessFontsManager.savedFont = '';
    BusinessFontsManager.lastSelectedFontChangeState = () {};
    BusinessFontsManager.setPhoneState = () {};
    BusinessFontsManager.setBlockFontsState = (_) {};
    BusinessFontsManager.useDefault = SettingsData.settings.fontName == '';
    this.currentBusinessFont = SettingsData.settings.fontName;
    this.displayFont = SettingsData.settings.fontName;
    if (this.displayFont == '') {
      // no custom font
      displayFont = translate("Default");
    }

    displayLang.forEach((key, value) {
      laguagesOptions.add(DropdownMenuItem<Languages>(
        value: key,
        child: Center(
          child: Text(
            value == 'All' ? translate('All') : value,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          ),
        ),
      ));
    });
  }

  @override
  void dispose() {
    saveData();
    // free up resurces
    BusinessFontsManager.savedFont = null;
    BusinessFontsManager.lastSelectedFontChangeState = null;
    BusinessFontsManager.setBlockFontsState = null;
    BusinessFontsManager.useDefault = null;
    BusinessFontsManager.setPhoneState = null;
    super.dispose();
  }

  void saveData() {
    if (SettingsData.settings.fontName == this.currentBusinessFont) {
      return;
    }
    SettingsData.updateBusinessFont(fontName: SettingsData.settings.fontName);
  }

  @override
  Widget build(BuildContext context) {
    PhoneFontsExample phone = PhoneFontsExample();
    BlockFonts blockFonts = BlockFonts();
    FontText fontText = FontText(
      fontName: displayFont,
      isDefaultText: true,
    );
    return Scaffold(
        appBar: AppBar(
          actions: [
            infoButton(context: context, text: translate("FontManagementInfo"))
          ],
          elevation: 0,
          title: Center(child: Text(translate("FontManagementTitle"))),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Align(alignment: Alignment.topCenter, child: phone),
              settingsContainer(fontText),
              Container(
                width: gWidth * .95,
                child: CustomDivider(
                  txt: Text(translate("PickFont")),
                ),
              ),
              Expanded(
                  child: Stack(
                fit: StackFit.expand,
                children: [fontOptionsList(context), blockFonts],
              ))
            ],
          ),
        ));
  }

  Widget settingsContainer(FontText fontText) {
    return CustomContainer(
      padding: EdgeInsets.symmetric(horizontal: gWidth * .03),
      margin: EdgeInsets.symmetric(vertical: 5),
      image: null,
      color: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.only(top: 5),
              width: gWidth * .9,
              child: currentFont(fontText)),
          Container(
              padding: EdgeInsets.only(top: 5),
              width: gWidth * .9,
              child: useDefault()),
          Container(
              padding: EdgeInsets.only(top: 5),
              width: gWidth * .9,
              child: languagesFilter()),
        ],
      ),
    );
  }

  Widget currentFont(FontText fontText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          translate("CurrentFont"),
        ),
        fontText
      ],
    );
  }

  Widget useDefault() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(translate("UseDefaultFont")),
        UseSDefaultSwitch(),
      ],
    );
  }

  Widget languagesFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(translate("FilterByLang")),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 30,
                child: DropdownButton<Languages>(
                    alignment: AlignmentDirectional.centerEnd,
                    value: langFilter,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 15,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    //menuMaxHeight: 200,
                    underline: SizedBox(),
                    onChanged: (Languages? value) {
                      if (value == null) return;
                      if (value == langFilter) return;
                      langFilter = value;
                      setState(() {});
                    },
                    items: laguagesOptions))
          ],
        )
      ],
    );
  }

  Widget fontOptionsList(BuildContext context) {
    final List<String> optionalFontsNames =
        FontsHelper().getFilteredFontsNames(langFilter: langFilter);
    return GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 2 / 1, crossAxisCount: 3),
        itemCount: optionalFontsNames.length,
        cacheExtent: 20,
        itemBuilder: (BuildContext context, int index) {
          return FontText(
            fontName: optionalFontsNames[index],
          );
        });
  }
}
