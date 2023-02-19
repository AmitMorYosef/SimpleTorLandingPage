import 'package:flutter/cupertino.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/providers/booking_provider.dart';
import 'package:management_system_app/providers/language_provider.dart';
import 'package:management_system_app/providers/links_provider.dart';
import 'package:management_system_app/providers/loading_provider.dart';
import 'package:management_system_app/providers/login_provider.dart';
import 'package:management_system_app/providers/manager_provider.dart';
import 'package:management_system_app/providers/payments_provider.dart';
import 'package:management_system_app/providers/settings_provider.dart';
import 'package:management_system_app/providers/subscription_provider.dart';
import 'package:management_system_app/providers/theme_provider.dart';
import 'package:management_system_app/providers/user_provider.dart';
import 'package:management_system_app/providers/worker_provider.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/device_provider.dart';

class UiManager {
  static Set<Providers> updatesQueue = {};

  static insertUpdate(Providers provider) {
    /*
    "theme & loggin & language" are listened my the main -> update of one of them will
    update all the screens so there is no need to add another screens
    to the updatesQueue
    */
    if (provider == Providers.login) {
      updatesQueue = {Providers.login};
    } else if (provider == Providers.theme) {
      updatesQueue = {Providers.theme};
    } else if (provider == Providers.language) {
      updatesQueue = {Providers.language};
    } else {
      if (updatesQueue.contains(Providers.theme) ||
          updatesQueue.contains(Providers.loading) || // update all screens...
          updatesQueue.contains(Providers.language) ||
          updatesQueue.contains(Providers.login)) return;
      logger.i("adding the provider $provider to queue");
      updatesQueue.add(provider);
    }
  }

  /// used to prevent context problems if you are sure
  /// you already going to update all the context by higher context level
  /// exmaple: Queue(userProvider) -> clean -> insert(settingProvider)
  /// this update the pages_manager and also all the user provider listiners
  static void cleanQueue() {
    updatesQueue = {};
  }

  static Future<void> updateUi(
      {BuildContext? context, Future<void>? perform}) async {
    if (context == null) {
      logger.d('Null context --> using the MyApp.mainContext');
      context = MyApp.mainContext;
    }
    if (context == null) {
      logger.d('This is a null context stop updating');
      return;
    }
    if (perform != null) await perform;
    updatesQueue.forEach((provider) {
      logger.i("update listeners of -> $provider");
      switch (provider) {
        case Providers.login:
          MyApp.mainContext!.read<LogginProvider>().updateScreen();
          break;
        case Providers.theme:
          MyApp.mainContext!.read<ThemeProvider>().updateScreen();
          break;
        case Providers.language:
          MyApp.mainContext!.read<LanguageProvider>().updateScreen();
          break;
        case Providers.loading:
          context!.read<LoadingProvider>().updateScreen();
          break;
        case Providers.user:
          context!.read<UserProvider>().updateScreen();
          break;
        case Providers.worker:
          context!.read<WorkerProvider>().updateScreen();
          break;
        case Providers.manager:
          context!.read<ManagerProvider>().updateScreen();
          break;
        case Providers.settings:
          context!.read<SettingsProvider>().updateScreen();
          break;
        case Providers.booking:
          context!.read<BookingProvider>().updateScreen();
          break;
        case Providers.links:
          context!.read<LinksProvider>().updateScreen();
          break;
        case Providers.device:
          context!.read<DeviceProvider>().updateScreen();
          break;
        case Providers.purchase:
          context!.read<SubscriptionProvider>().updateScreen();
          break;
        case Providers.payments:
          context!.read<PaymentsProvider>().updateScreen();
          break;
      }
    });
    updatesQueue = {};
  }
}
