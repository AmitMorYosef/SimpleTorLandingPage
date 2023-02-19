import 'package:flutter/material.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/business_fonts_management/business_fonts_manager.dart';

import '../../../../../../app_statics.dart/settings_data.dart';

class UseSDefaultSwitch extends StatefulWidget {
  const UseSDefaultSwitch({super.key});

  @override
  State<UseSDefaultSwitch> createState() => _UseSDefaultSwitchState();
}

class _UseSDefaultSwitchState extends State<UseSDefaultSwitch> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 25,
      child: Switch(
          value: BusinessFontsManager.useDefault!,
          onChanged: (val) {
            if (!val) {
              SettingsData.settings.fontName = BusinessFontsManager.savedFont!;
            } else {
              BusinessFontsManager.savedFont = SettingsData.settings.fontName;
              SettingsData.settings.fontName = '';
            }
            // update block the fonts container
            BusinessFontsManager.setBlockFontsState!(val);
            // update color of current font
            BusinessFontsManager.currentFontChangeState!();
            // update color of selected font
            BusinessFontsManager.lastSelectedFontChangeState!();
            // update the phone example
            BusinessFontsManager.setPhoneState!();
            setState(() {});
          }),
    );
  }
}
