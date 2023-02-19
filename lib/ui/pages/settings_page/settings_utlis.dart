import 'package:flutter/material.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/providers/language_provider.dart';
import 'package:management_system_app/providers/worker_provider.dart';
import 'package:management_system_app/ui/general_widgets/buttons/info_button.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/make_sure_dialog.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/ui/pages/settings_page/dialogs/change_language_dialog.dart';
import 'package:management_system_app/ui/pages/settings_page/dialogs/delete_buisness_dialog.dart';
import 'package:management_system_app/ui/pages/settings_page/dialogs/delete_user_dialog.dart';
import 'package:management_system_app/ui/pages/settings_page/dialogs/log_out_dialog.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/app_details.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/block_users.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/business_fonts_management/business_fonts_manager.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/changing_photo_mangement.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/choose_theme_scaffold.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/my_workers.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/payments_details/payment_page.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/products_page/products_management.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/statistcs_page.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/treatments_page/treatments.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/updates_management_page/app_updates.dart';
import 'package:management_system_app/ui/pages/settings_page/switchs/delete_data.dart';
import 'package:management_system_app/ui/pages/settings_page/trailing/string_near_the_booking_time.dart';
import 'package:management_system_app/ui/pages/settings_page/trailing/string_treatments_amount.dart';
import 'package:management_system_app/ui/pages_opener.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../app_statics.dart/settings_data.dart';
import '../../../app_statics.dart/subscription_data.dart';
import '../../../app_statics.dart/user_data.dart';
import '../../../app_statics.dart/worker_data.dart';
import '../../../models/purchase_offering.dart';
import '../../../providers/helpers/purchaces_helper.dart';
import '../../general_widgets/custom_widgets/custom_container.dart';
import '../../general_widgets/custom_widgets/custom_toast.dart';
import '../../general_widgets/custom_widgets/sliding_bottom_sheet.dart';
import '../../general_widgets/loading_widgets/load_products_widget.dart';
import '../../general_widgets/pickers/duration_picker.dart';
import '../../general_widgets/pickers/subscription_picker.dart/choose_purchase_plan.dart';
import 'dialogs/links_dialog.dart';

late BuildContext settingsContext;

List<Map<String, dynamic>> buisnessMaker = [
  {
    "icon": Icon(
      Icons.business,
    ),
    "name": "buisnessCreation",
    "onClick": () async {
      await PagesOpener().openBusinessCreation(context: settingsContext);
    }
  }
];

List<Map<String, dynamic>> loggin = [
  {
    "icon": Icon(Icons.notifications),
    "name": "myNotification",
    "onClick": () async {
      await PagesOpener().openMyNotification(context: settingsContext);
    }
  },
  {
    "icon": Icon(Icons.login),
    "name": "loggin",
    "onClick": () async =>
        await PagesOpener().openLogin(context: settingsContext)
  },
];

List<Map<String, dynamic>> userOption = [
  {
    "icon": Icon(Icons.notifications),
    "name": "myNotification",
    "onClick": () async {
      await PagesOpener().openMyNotification(context: settingsContext);
    }
  },
  {
    "icon": Icon(Icons.logout),
    "name": "logout",
    "onClick": () => logOutDialog(settingsContext)
  },
  {
    "icon": Icon(Icons.delete),
    "name": "deleteUser",
    "onClick": () async {
      deleteUserDialog(settingsContext);
    }
  },
];

List<Map<String, dynamic>> employeeSettings = [
  {
    "icon": Icon(Icons.timelapse),
    "name": "mySchedule",
    "onClick": () async {
      await PagesOpener().openScehduleSettings(context: settingsContext);
    }
  },
  {
    "icon": Icon(Icons.list_alt),
    "name": "myTreatments",
    "trailing": StirngTreatmentsAmount(),
    "onClick": () => Navigator.push(
        settingsContext, MaterialPageRoute(builder: (_) => Treatments()))
  },
  {
    "icon": Icon(Icons.list_alt),
    "name": "upcomingOrder",
    "trailing": StringNearTheBookingTime(),
    "onClick": () async {
      DurationPicker durationPicker = DurationPicker(
          title: infoButton(
            context: settingsContext,
            text: translate("minimumTimeWithoutConfirmation"),
          ),
          initData: durationToMap(
              Duration(minutes: WorkerData.worker.onHoldMinutes)));
      await durationPicker.showPickerModal(settingsContext);
      final resultMinutes = mapToDuration(durationPicker.data).inMinutes;
      WorkerData.worker.onHoldMinutes != resultMinutes
          ? settingsContext
              .read<WorkerProvider>()
              .changeOnHoldMinutes(resultMinutes, settingsContext)
          : CustomToast(context: settingsContext, msg: translate("sameData"))
              .init();
    }
  },
  {
    "icon": Icon(Icons.auto_graph),
    "name": "workerData",
    "onClick": () {
      if (SettingsData.appCollection != "" &&
          SettingsData.settings.productId == "" &&
          UserData.user.previews.containsKey(SettingsData.appCollection)) {
        SubscriptionData.init();

        SlidingBottomSheet(
                context: settingsContext,
                sheet: LoadProductsWidget(
                  childCreator: publishPlanSheet,
                  isWorker: false,
                ),
                size: 1)
            .showSheet();
        return;
      }
      Navigator.push(
          settingsContext, MaterialPageRoute(builder: (_) => StatisticsPage()));
    }
  },
  {
    "icon": Icon(Icons.save),
    "name": "timeThatExpiredDataDeleted",
    "onClick": () => {},
    "suffix": DeleteDataSwitch()
  },
];

List<Map<String, dynamic>> paymentsSettings = [
  {
    "icon": Icon(Icons.payment),
    "name": "acceptPayments",
    "onClick": () => Navigator.push(
        settingsContext, MaterialPageRoute(builder: (_) => PaymentPage())),
  },
];

List<Map<String, dynamic>> blocks = [
  {
    "icon": Icon(Icons.block),
    "name": "blockUsers",
    "onClick": () => Navigator.push(
        settingsContext, MaterialPageRoute(builder: (_) => BlockUsers()))
  },
];

List<Map<String, dynamic>> buisnessEditSettings = [
  {
    "icon": Icon(Icons.work),
    "name": "myWorkers",
    "onClick": () => Navigator.push(
        settingsContext, MaterialPageRoute(builder: (_) => MyWorkers()))
  },
  {
    "icon": Icon(Icons.update),
    "name": "updates",
    "onClick": () => Navigator.push(
        settingsContext, MaterialPageRoute(builder: (_) => AppUpdates()))
  },
  {
    "icon": Icon(Icons.wallet),
    "name": "businessDetails",
    "onClick": () => Navigator.push(
        settingsContext, MaterialPageRoute(builder: (_) => AppDetails()))
  },
];

List<Map<String, dynamic>> purchases = [
  {
    "icon": Icon(Icons.restore),
    "name": "restorePurchase",
    "onClick": () async {
      bool? resp =
          await makeSureDialog(settingsContext, translate("restoreInfo"));
      if (resp == true) {
        await Loading(
                timeOutDuration: Duration(seconds: 10),
                context: settingsContext,
                navigator: Navigator.of(settingsContext),
                future: PurchesesHelper().restorePurchases(),
                msg: translate("restoreSuccessed"))
            .dialog();
      }
    }
  },
  {
    "icon": Icon(Icons.switch_left),
    "name": "changePlan",
    "onClick": () {
      if (!SettingsData.activeBusiness) return;
      if (SettingsData.settings.productId == "") {
        CustomToast(
                context: settingsContext, msg: translate("firstPurchaseSub"))
            .init();
        return;
      }
      if (SettingsData.settings.pendingProductId != "") {
        CustomToast(
                context: settingsContext,
                msg: translate("alreadyHasSubPending"))
            .init();
        return;
      }
      SubscriptionData.init();
      SlidingBottomSheet(
              context: settingsContext,
              sheet: LoadProductsWidget(
                childCreator: changePlanSheet,
                isWorker: false,
              ),
              size: 1)
          .showSheet();
    },
  },
];

Widget changePlanSheet(BuildContext context) {
  Map<String, PurchaseOffering> offeringForUse = {};
  SubscriptionData.subTypeOfferings.forEach((offeringId, offering) {
    if (offering.products.containsKey(SettingsData.settings.productId)) {
      offeringForUse = {offeringId: offering};
    }
  });

  return Container(
      color: Theme.of(context).colorScheme.surface,
      child: ChoosePurchasePlan(
        availableProducts: [],
        productsToNotShow: SubscriptionData.alreadyPurchasedSubs,
        changePlan: true,
        offerings: offeringForUse,
      ));
}

List<Map<String, dynamic>> purchasesForUser = [
  {
    "icon": Icon(Icons.restore),
    "name": "restorePurchase",
    "onClick": () async {
      bool? resp =
          await makeSureDialog(settingsContext, translate("restoreInfo"));
      if (resp == true) {
        await Loading(
                timeOutDuration: Duration(seconds: 10),
                context: settingsContext,
                navigator: Navigator.of(settingsContext),
                future: PurchesesHelper().restorePurchases(),
                msg: translate("restoreSuccessed"))
            .dialog();
      }
    }
  },
];
List<Map<String, dynamic>> buisnessDisplaySettings = [
  {
    "icon": Icon(Icons.sunny),
    "name": "theme",
    "onClick": () => Navigator.push(settingsContext,
        MaterialPageRoute(builder: (_) => ChooseThemeScaffold()))
  },
  {
    "icon": Icon(
      Icons.picture_in_picture,
    ),
    "name": "changingImages",
    "onClick": () => Navigator.push(settingsContext,
        MaterialPageRoute(builder: (_) => ChangingPhotoMangement()))
  },
  {
    "icon": Icon(Icons.shopping_cart),
    "name": "productsImages",
    "onClick": () => Navigator.push(settingsContext,
        MaterialPageRoute(builder: (_) => ProductsManagement()))
  },
  {
    "icon": Icon(Icons.font_download),
    "name": "FontManagementTitle",
    "onClick": () => Navigator.push(settingsContext,
        MaterialPageRoute(builder: (_) => BusinessFontsManager()))
  },
];

List<Map<String, dynamic>> buisnessOptions = [
  {
    "icon": Icon(Icons.link),
    "name": "shareBusiness",
    "onClick": () async {
      if (SettingsData.appCollection != "" &&
          SettingsData.settings.productId == "" &&
          UserData.user.previews.containsKey(SettingsData.appCollection)) {
        SubscriptionData.init();

        SlidingBottomSheet(
                context: settingsContext,
                sheet: LoadProductsWidget(
                  childCreator: publishPlanSheet,
                  isWorker: false,
                ),
                size: 1)
            .showSheet();
        return;
      }
      await linksOptionsDialog(settingsContext);
    }
  },
  {
    "icon": Icon(Icons.delete),
    "name": "deleteBusiness",
    "onClick": () => DeleteBuisnessDialog(settingsContext)
  },
];

List<Map<String, dynamic>> shareBuisness = [
  {
    "icon": Icon(Icons.link),
    "name": "shareBusiness",
    "onClick": () {
      if (!SettingsData.isBusinessPublish()) {
        SubscriptionData.init();
        SlidingBottomSheet(
                context: settingsContext,
                sheet: LoadProductsWidget(
                  childCreator: publishPlanSheet,
                  isWorker: false,
                ),
                size: 1)
            .showSheet();
        return;
      }
      linksOptionsDialog(settingsContext);
    },
  }
];

Widget publishPlanSheet(BuildContext context) {
  final availableProducts =
      SubscriptionData.getAvailableProducts(type: "business");
  return CustomContainer(
      needImage: false,
      showBorder: false,
      geometryRadius: BorderRadius.all(Radius.circular(0)),
      boxBorder: Border.all(width: 0),
      color: Theme.of(context).colorScheme.surface,
      child: ChoosePurchasePlan(
        availableProducts: availableProducts,
        offerings: SubscriptionData.subTypeOfferings,
      ));
}

List<Map<String, dynamic>> language = [
  {
    "icon": Icon(Icons.translate),
    "name": "changeLanguage",
    "onClick": () async {
      dynamic lang = await changeLanguageDialog(settingsContext);
      logger.d("Selected language -> $lang");
      if (lang is String)
        UiManager.updateUi(
            perform:
                settingsContext.read<LanguageProvider>().changeLaguage(lang));
    }
  }
];

// functions
Future<void> allwBokkingsTillPickTime(BuildContext context) async {
  DurationPicker durationPicker = DurationPicker(
      onlyShowDays: true,
      title: infoButton(
        context: context,
        text: translate("timeThatDiaryOpen"),
      ),
      initData:
          durationToMap(Duration(days: WorkerData.worker.daysToAllowBookings)));
  await durationPicker.showPickerModal(context);
  final resultDays = mapToDuration(durationPicker.data).inDays;
  WorkerData.worker.daysToAllowBookings != resultDays
      ? WorkerData.changeDaysToAllowBookings(resultDays, context)
      : CustomToast(context: context, msg: translate("sameData")).init();
}
