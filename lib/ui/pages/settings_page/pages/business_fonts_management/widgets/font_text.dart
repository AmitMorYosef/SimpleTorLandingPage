import 'package:flutter/material.dart';

import '../../../../../../app_statics.dart/settings_data.dart';
import '../../../../../helpers/fonts_helper.dart';
import '../business_fonts_manager.dart';

class FontText extends StatefulWidget {
  final String fontName;
  final bool isDefaultText;
  FontText({super.key, required this.fontName, this.isDefaultText = false});
  @override
  State<FontText> createState() => _FontTextState();
}

class _FontTextState extends State<FontText> {
  bool isStateActive = true;
  void updateScreen() {
    if (!isStateActive) return;
    setState(() {});
  }

  @override
  void initState() {
    // in case is selected -> state disposed -> new this obj built -> save
    // the changing function
    super.initState();
    if (widget.isDefaultText) {
      BusinessFontsManager.currentFontChangeState = updateScreen;
    }
    if (SettingsData.settings.fontName == widget.fontName) {
      BusinessFontsManager.lastSelectedFontChangeState = updateScreen;
    }
  }

  @override
  void dispose() {
    isStateActive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (SettingsData.settings.fontName == widget.fontName) {
          return;
        }
        if (BusinessFontsManager.useDefault!) {
          return; // there is the block container but this for current font btn
        }
        // remove selection from current font
        BusinessFontsManager.currentFontChangeState!();
        // remove the last text selection
        BusinessFontsManager.lastSelectedFontChangeState!();
        // put itself in the selection removal func
        BusinessFontsManager.lastSelectedFontChangeState = updateScreen;
        // update the font name
        SettingsData.settings.fontName = widget.fontName;
        // mark itself as seleceted
        setState(() {});
        // update the phone widget
        BusinessFontsManager.setPhoneState!();
      },
      child: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Text(
            widget.fontName,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: FontsHelper().custumStyle(
                fontName: widget.fontName,
                currentStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 20,
                    color: SettingsData.settings.fontName == widget.fontName
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.onBackground)),
          ),
        ),
      ),
    );
  }
}
