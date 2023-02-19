import 'package:flutter/material.dart';

import '../app_const/operations.dart';

class ScreensData {
  static PageController controller =
      PageController(initialPage: 1); // screen controller
  static int screenIndex = 1; // index of the current screen

  static int screensCount =
      0; // count of screens (changing between user permissions)
  static bool buisnessInit = true; // if buisnesses firt time luanch this time
  static int changingPhotoIndex =
      0; // index of the changing images - buisness page
  static double homeScrollControllerOffset = 0; // ofset of the buisness page
  static double settingsScrollControllerOffset = 0;
  static double scheduleScrollControllerOffset = 0;
  static int searchTabIndex = 0;
  static Operations? nextOperation;
  //static bool dismissSlidingBottomSheetDrop = true;
  //static SheetController? sheetController;

  static void setOperation(Operations operation) {
    nextOperation = operation;
  }

  static void cleanOperation() {
    nextOperation = null;
  }

  static initOffests() {
    homeScrollControllerOffset = 0; // ofset of the buisness page
    settingsScrollControllerOffset = 0;
    scheduleScrollControllerOffset = 0;
  }
}
