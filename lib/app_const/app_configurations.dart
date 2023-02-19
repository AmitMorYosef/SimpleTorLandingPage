import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:management_system_app/services/in_app_services.dart/language.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../providers/booking_provider.dart';
import '../providers/device_provider.dart';
import '../providers/language_provider.dart';
import '../providers/links_provider.dart';
import '../providers/loading_provider.dart';
import '../providers/login_provider.dart';
import '../providers/manager_provider.dart';
import '../providers/payments_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../providers/worker_provider.dart';

/// Thes file is saving the const vars of 'main.dart'
/// and hold the configurations of the app

// app high level providers
List<SingleChildWidget> appProviders = [
  ChangeNotifierProvider(create: (_) => LanguageProvider()),
  ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ChangeNotifierProvider(create: (_) => SettingsProvider()),
  ChangeNotifierProvider(create: (_) => LoadingProvider()),
  ChangeNotifierProvider(create: (_) => DeviceProvider()),
  ChangeNotifierProvider(create: (_) => LinksProvider()),
  ChangeNotifierProvider(create: (_) => WorkerProvider()),
  ChangeNotifierProvider(create: (_) => LogginProvider()),
  ChangeNotifierProvider(create: (_) => ManagerProvider()),
  ChangeNotifierProvider(create: (_) => BookingProvider()),
  ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
  ChangeNotifierProvider(create: (_) => PaymentsProvider()),
  ChangeNotifierProvider(create: (_) => UserProvider()),
  // -----------------------------------------------------------
  // ChangeNotifierProvider(create: (_) => context.read<UserProvider>()),
  // ChangeNotifierProvider(create: (_) => ManagerProvider()),
  // ChangeNotifierProvider(create: (_) => WorkerProvider()),
  // ChangeNotifierProvider(create: (_) => BookingProvider()),
  // ChangeNotifierProvider(create: (_) => DeviceProvider()),
  // ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
  // ChangeNotifierProvider(create: (_) => PaymentsProvider()),
  // ChangeNotifierProvider(create: (_) => ScreensProvider()),
  // ChangeNotifierProvider(create: (_) => context.read<UserProvider>()),
  // //ChangeNotifierProvider(create: (_) => ManagerProvider()),
  // ChangeNotifierProvider(create: (_) => WorkerProvider()),
  // //ChangeNotifierProvider(create: (_) => BookingProvider()),
  // ChangeNotifierProvider(create: (_) => SettingsProvider()),
  // //ChangeNotifierProvider(create: (_) => LogginProvider()),
  // ChangeNotifierProvider(create: (_) => ScreensProvider()),
  // ChangeNotifierProvider(create: (_) => LinksProvider()),
  // ChangeNotifierProvider(create: (_) => LoadingProvider()),
  // ChangeNotifierProvider(create: (_) => DeviceProvider()),
  // ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
  // ChangeNotifierProvider(create: (_) => PaymentsProvider()),
];

// app localizations - control the language of the app
Iterable<LocalizationsDelegate<dynamic>> appLocalizationDelegate = const [
  ApplicationLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];

Iterable<Locale> supportedLocals = <Locale>[
  Locale("en", "US"),
  Locale("he", "IL"),
];

/// Get: `language` ('hebrew') and Return: app `Local()` obj
Locale getLocal(String language) {
  Locale locale = const Locale("he", "IL");
  switch (language) {
    case "en":
      {
        locale = const Locale("en", "US");
      }
      break;
    case "he":
      {
        locale = const Locale("he", "IL");
      }
      break;
  }
  return locale;
}
