import 'package:flutter/material.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

import '../../../app_const/app_sizes.dart';
import '../../../utlis/general_utlis.dart';

class SlidingBottomSheet {
  SheetController controller = SheetController();
  BuildContext context;
  Widget sheet;
  double size;

  SlidingBottomSheet({
    required this.context,
    required this.sheet,
    required this.size,
  });

  Future showSheet() {
    //  ScreensData.sheetController = controller;
    return showSlidingBottomSheet(
      context,
      builder: (conntext) => SlidingSheetDialog(
          onDismissPrevented: (backButton, backDrop) {
            overLaysHandling();
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          headerBuilder: (context, state) {
            return Container(
              width: gWidthOriginal,
              color: Theme.of(context).colorScheme.surface,
              child: CustomContainer(
                  margin: EdgeInsets.symmetric(
                      vertical: 7, horizontal: gWidthOriginal * 0.4),
                  height: 5,
                  image: null,
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.3)),
            );
          },
          controller: controller,
          snapSpec: SnapSpec(snappings: [size]),
          builder: buildSheet,
          cornerRadiusOnFullscreen: 0,
          duration: const Duration(milliseconds: 500),
          cornerRadius: 20),
    );
  }

  Widget buildSheet(_, __) {
    return Material(child: sheet);
  }
}
