import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:management_system_app/app_statics.dart/general_data.dart';
import 'package:management_system_app/providers/language_provider.dart';
import 'package:management_system_app/providers/login_provider.dart';
import 'package:management_system_app/providers/theme_provider.dart';
import 'package:management_system_app/services/external_services/firebase_notifications.dart';
import 'package:management_system_app/services/in_app_services.dart/notification_api.dart';
import 'package:management_system_app/ui/load_app.dart' deferred as appLoader;
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/general_utlis.dart';
import 'package:management_system_app/web_middle_page.dart';
import 'package:provider/provider.dart';

import 'app_const/app_configurations.dart';
import 'app_const/application_general.dart';
import 'app_const/db.dart';
import 'app_const/display.dart';
import 'app_const/platform.dart';
import 'app_const/resources.dart';
import 'app_statics.dart/language_data.dart';
import 'app_statics.dart/settings_data.dart';
import 'app_statics.dart/subscription_data.dart';
import 'app_statics.dart/theme_data.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // try {
  //   FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  //   await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);

  // } catch (e) {
  //   // ignore: avoid_print

  // }

  // await FirebaseFirestore.instance.collection('Entries').add(<String, String>{
  //   'title': "entry.title",
  //   'date': "entry.date.toString()",
  //   'text': "entry.text",
  // });
  // if (envKey != 'enviroments/$productionKey' && !isWeb) {
  //   var defaultHost = Platform.isAndroid ? "127.0.0.1" : "localhost";
  //   // [Firestore | localhost:8080]
  //   FirebaseFirestore.instance.useFirestoreEmulator(defaultHost, 8080);

  //   // [Authentication | localhost:9099]
  //   await FirebaseAuth.instance.useAuthEmulator(defaultHost, 9099);

  //   // [Storage | localhost:9199]
  //   await FirebaseStorage.instance.useStorageEmulator(defaultHost, 9199);
  // }
  // load the app services
  await loadServices();
  runApp(
    MultiProvider(providers: appProviders, child: MyApp()),
  );
}

Future<void> loadServices() async {
  if (isWeb) {
    return;
  }
  // -------------- library loaders -----------------
  await appLoader.loadLibrary();
  // -------------- services ------------------
  //prevent from the screen enter to lanndscape mode
  preventRotate();
  //initilize the notification
  NotificationApi.init();
  // initial the purchase service
  await SubscriptionData.initPurchasesServer();
  // initialize firebase notifications
  await FirebaseNotifications.initialService();
  //firebase notifications init
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // load the last theme
  await AppThemeData.loadSavedTheme();
  // load the app language
  await LanguageData.loadSavedLanguage();
  overLaysHandling();
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
    //RemoteMessage
    dynamic message) async {
  if (isWeb) {
    return;
  }
  await FirebaseNotifications.showNotification(message.data);
  logger.d("Handling a background message: ${message.messageId}");
}

class MyApp extends StatefulWidget {
  static String? initalPayload;
  static BuildContext? mainContext;
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  //String host = Platform.isAndroid ? "10.0.2.2" : "localhost";
  int count = 0;
  @override
  void initState() {
    if (isWeb) {
      return;
    }
    WidgetsBinding.instance.addObserver(this);
    // listen to notifications
    listenToNotification();
    //GoogleFonts.config.allowRuntimeFetching = false;
    /* firestore emulators */
    // firestore = FirebaseFirestore.instance;
    // firestore.settings =
    //     const Settings(persistenceEnabled: false, sslEnabled: false);
    // firestore.useFirestoreEmulator(host, 8080);
    /* ------------------- */
    super.initState();
  }

  void listenToNotification() async {
    // RemoteMessage?
    dynamic initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    // firebase initial notification
    if (initialMessage != null) {
      GeneralData.currentBusinesssId = initialMessage.data["shopId"];
      //updateAppScreen();
    }
    // firebase notification listener
    FirebaseMessaging.onMessageOpenedApp.listen(((message) {
      if (message.data["shopId"] != null) {
        GeneralData.currentBusinesssId = message.data["shopId"];
        updateAppScreen();
      }
    }));
    // firebase local notifications listener
    FirebaseNotifications.onNotification.stream.listen((event) {
      logger.d(
          "Firebase notifications value ${FirebaseNotifications.onNotification.value}");
      if (event != null) {
        GeneralData.currentBusinesssId = event;
        updateAppScreen();
      }
    });
  }

  void updateAppScreen() {
    // changing the status promise data re-loading --> load the new data
    //context.read<LoadingProvider>().status = LoadingStatuses.loading;
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (isWeb) {
      return;
    }
    if (state != AppLifecycleState.resumed) return;
    if (state == AppLifecycleState.resumed) {
      // UiManager.updateUi(
      //     context: context,
      //     perform: context.read<LinksProvider>().linksAfterResumeApp(context));
      overLaysHandling();
      logger.d("Main changed the after resume now");
      // user cameback from background
      if (!await isTimeUpdated()) {
        // make shure user didnt change the times
        updateAppScreen();
      }
    }
  }

  void duplicateData() async {
    // Client client = Client();
    //client.logout();

    // List<String> users =
    //     await client.getAllDocIdsInsideCollection(path: usersCollection);
    // for (String user in users) {
    //   User us = User.fromJson(
    //       (await client.getDoc(path: usersCollection, docId: user)).data()!);
    //   for (String business in us.permission.keys.toList()) {
    //     (await client.deleteDoc(
    //         path: "buisnesses/$business/${workersCollection}",
    //         docId: us.phoneNumber));
    //   }
    //   // String phone = us.phoneNumber.replaceFirst('0', "+972");
    //   // us.phoneNumber = us.phoneNumber.replaceFirst('0', "+972-");

    //   // await client.createDoc(
    //   //     path: usersCollection, docId: phone, valueAsJson: us.toJson());

    //   (await client.deleteDoc(path: usersCollection, docId: us.phoneNumber));
    // }
  }

  Future<void> eventsChecker() async {
    // Client client = Client();
    // try {
    //   await client.createDoc(
    //       insideEnviroments: false,
    //       path: "revenueCatEvents",
    //       docId: Uuid().v1(),
    //       valueAsJson: {
    //         "type": "CANCELLATION",
    //         "product_id": "simpletor_basic_business_month_1",
    //         //"new_product_id": "simpletor_basic_business_month_1",
    //         "app_user_id": "3d815c00-9c09-11ed-b29a-a32d7f60d04b",
    //         "environment": "SANDBOX"
    //       });
    // } catch (e) {}
  }

  Future<void> r() async {
    // Client client = Client();

    // Map<String, String> keys = {
    //   '1 Worker': 'simpletor_1worker_month1',
    //   '2 Worker': 'simpletor_2worker_month1',
    //   '3 Worker': 'simpletor_3worker_month1',
    //   'Monthly ,basic business': 'simpletor_basic_business_month_1',
    //   'Monthly ,advanced business': 'simpletor_advanced_business_month_1',
    // };

    // Map<String, dynamic> data = (await client.getDoc(
    //   insideEnviroments: false,
    //   path: "generalSettings",
    //   docId: "englishPurchases",
    // ))
    //     .data()!;
    // keys.forEach((old, newd) {
    //   data['productsNames'][newd] = data['productsNames'][old];
    //   data['productsNames'].remove(old);
    //   //
    //   data['productsDescription'][newd] = data['productsDescription'][old];
    //   data['productsDescription'].remove(old);
    // });
    // data.forEach((key, value) {

    // });
    // await client.setDoc(
    //     insideEnviroments: false,
    //     path: "generalSettings",
    //     docId: "englishPurchases",
    //     valueAsJson: data);
  }

  /// Get: language and Return: app Local() obj
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

  @override
  Widget build(BuildContext context) {
    MyApp.mainContext = context;
    LogginProvider logginProvider = context.watch<LogginProvider>();
    //eventsChecker();
    context.watch<ThemeProvider>();
    // watch the languge - if changeing the the main re-build
    context.watch<LanguageProvider>();
    UiManager.updateUi(
        context: context,
        perform: Future(
          () => logginProvider.logoutIfSignUpNotCompleted(),
        )); // user finish sign up

    if (AppThemeData.currentKeyTheme == null) {
      AppThemeData.currentKeyTheme = AppThemeData.defaultTheme;
    }
    switch (AppThemeData.currentKeyTheme) {
      case Themes.light:
        SettingsData.businessIcon = darkShopIcon;
        break;
      case Themes.dark:
        SettingsData.businessIcon = lightShopIcon;
        break;
      case null:
        SettingsData.businessIcon = lightShopIcon;
        break;
    }
    return MaterialApp(
      debugShowCheckedModeBanner:
          envKey != 'enviroments/$productionKey' ? true : false,
      theme: themes[AppThemeData.currentKeyTheme],
      localizationsDelegates: appLocalizationDelegate,
      supportedLocales: supportedLocals,
      locale: getLocal(LanguageData.currentLaguageCode),
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocaleLanguage in supportedLocales) {
          if (supportedLocaleLanguage.languageCode == locale!.languageCode &&
              supportedLocaleLanguage.countryCode == locale.countryCode) {
            return supportedLocaleLanguage;
          }
        }
        return supportedLocales.first;
      },
      home: isWeb ? MiddlePage() : appLoader.LoadApp(),
    );
  }
}

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:management_system_app/firebase_options.dart';
// import 'package:management_system_app/web_middle_page.dart';
// import 'package:provider/provider.dart';

// import 'app_const/app_configurations.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(MultiProvider(
//     providers: appProviders,
//     child: MyApp(),
//   ));
// }

// class MyApp extends StatefulWidget {
//   static String? initalPayload;
//   static BuildContext? mainContext;
//   MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
//   //String host = Platform.isAndroid ? "10.0.2.2" : "localhost";

//   @override
//   Widget build(BuildContext context) {
//     MyApp.mainContext = context;
//     // LogginProvider logginProvider = context.watch<LogginProvider>();
//     //eventsChecker();
//     //context.watch<ThemeProvider>();
//     // watch the languge - if changeing the the main re-build
//     //context.watch<LanguageProvider>();
//     // UiManager.updateUi(
//     //     context: context,
//     //     perform: Future(
//     //       () => logginProvider.logoutIfSignUpNotCompleted(),
//     //     )); // user finish sign up

//     // if (ThemeProvider.currentKeyTheme == null)
//     //   ThemeProvider.currentKeyTheme = ThemeProvider.defaultTheme;

//     // switch (ThemeProvider.currentKeyTheme) {
//     //   case Themes.light:
//     //     SettingsData.businessIcon = darkShopIcon;
//     //     break;
//     //   case Themes.dark:
//     //     SettingsData.businessIcon = lightShopIcon;
//     //     break;
//     //   case null:
//     //     SettingsData.businessIcon = lightShopIcon;
//     //     break;
//     // }
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       //envKey != 'enviroments/$productionKey' ? true : false,
//       //theme: DarkTheme, // ThemeProvider.themes[ThemeProvider.currentKeyTheme],
//       // localizationsDelegates: appLocalizationDelegate,
//       // supportedLocales: supportedLocals,
//       // locale: getLocal('LanguageProvider.currentLaguageCode'),
//       // localeResolutionCallback: (locale, supportedLocales) {
//       //   for (var supportedLocaleLanguage in supportedLocales) {
//       //     if (supportedLocaleLanguage.languageCode == locale!.languageCode &&
//       //         supportedLocaleLanguage.countryCode == locale.countryCode) {
//       //       return supportedLocaleLanguage;
//       //     }
//       //   }

//       //   return supportedLocales.first;
//       // },
//       home: MiddlePage(),
//     );
//   }
// }
