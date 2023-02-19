import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:simple_tor_web/app_const/application_general.dart';
import 'package:simple_tor_web/providers/booking_provider.dart';
import 'package:simple_tor_web/providers/language_provider.dart';
import 'package:simple_tor_web/providers/links_provider.dart';
import 'package:simple_tor_web/providers/loading_provider.dart';
import 'package:simple_tor_web/providers/login_provider.dart';
import 'package:simple_tor_web/providers/payments_provider.dart';
import 'package:simple_tor_web/providers/settings_provider.dart';
import 'package:simple_tor_web/providers/user_provider.dart';
import 'package:simple_tor_web/providers/worker_provider.dart';

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
    } else if (provider == Providers.language) {
      updatesQueue = {Providers.language};
    } else {
      if (updatesQueue.contains(Providers.loading) || // update all screens...
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

        case Providers.payments:
          context!.read<PaymentsProvider>().updateScreen();
          break;
      }
    });
    updatesQueue = {};
  }
}
