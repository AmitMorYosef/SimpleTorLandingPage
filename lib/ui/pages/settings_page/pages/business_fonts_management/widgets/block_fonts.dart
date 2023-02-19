import 'package:flutter/material.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/business_fonts_management/business_fonts_manager.dart';

class BlockFonts extends StatefulWidget {
  BlockFonts({super.key});

  @override
  State<BlockFonts> createState() => _BlockFontsState();
}

class _BlockFontsState extends State<BlockFonts> {
  @override
  void initState() {
    BusinessFontsManager.setBlockFontsState = updateScreen;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BusinessFontsManager.useDefault!
        ? Container(
            color: Colors.grey.withOpacity(0.7),
            child: Icon(Icons.lock),
          )
        : SizedBox();
  }

  void updateScreen(bool val) {
    setState(() {
      BusinessFontsManager.useDefault = val;
    });
  }
}
