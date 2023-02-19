import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:management_system_app/providers/links_provider.dart';
import 'package:management_system_app/providers/loading_provider.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_toast.dart';
import 'package:management_system_app/ui/pages/maintenance_page/maintenance.dart';
import 'package:management_system_app/ui/pages/new_update_page/new_update.dart';
import 'package:management_system_app/ui/pages/pages_manager.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:upgrader/upgrader.dart';

import '../app_const/app_sizes.dart';
import '../app_const/loading_statuses.dart';
import '../app_const/resources.dart';
import '../app_statics.dart/user_data.dart';
import '../providers/settings_provider.dart';
import '../services/errors_service/app_errors.dart';
import '../utlis/general_utlis.dart';

// ignore: must_be_immutable
class LoadApp extends StatelessWidget {
  late LoadingProvider loadingProvider;
  static bool firstTime = true;
  List<SingleChildWidget> loadAppProviders = [];
  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider = context.read<SettingsProvider>();
    LinksProvider linksProvider = context.watch<LinksProvider>();
    loadingProvider = context.watch<LoadingProvider>();
    UserData.userListinerAllowUpdate = false;
    //return TransactionPage();
    if (loadingProvider.status == LoadingStatuses.loading)
      UiManager.updateUi(
          context: context,
          perform: loadingProvider
              .loadAppData(
                  settingsProvider: settingsProvider,
                  linksProvider: linksProvider,
                  context: context)
              .timeout(Duration(seconds: 10), onTimeout: () {
            CustomToast(
                    gravity: ToastGravity.CENTER,
                    context: context,
                    child: SizedBox(
                      height: 150,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 60,
                            ),
                            Text(
                              translate("slowConnection"),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            )
                          ],
                        ),
                      ),
                    ),
                    msg: '',
                    toastLength: Duration(seconds: 4))
                .init();
            loadingProvider.updateStatus(LoadingStatuses.success);
          }));
    return getScreen(loadingProvider.status, context);
    // MultiProvider(
    //     providers: loadAppProviders,
    //     child: getScreen(loadingProvider.status, context));
    //return MyWidget();
  }

  Widget getScreen(LoadingStatuses status, BuildContext context) {
    switch (loadingProvider.status) {
      case LoadingStatuses.loading:
        return screenLoadingWidget(context);
      case LoadingStatuses.unknownError:
        return errorWidget(context);
      case LoadingStatuses.timeEror:
        return timeError(context);
      case LoadingStatuses.updateAvilable:
        return NewUpdate();
      case LoadingStatuses.success:
        return getPagesManager();
      case LoadingStatuses.maintenanceMode:
        return Maintenance();
    }
  }

  Widget getPagesManager() {
    if (firstTime) {
      firstTime = false;
      return UpgradeAlert(
          upgrader: Upgrader(
            durationUntilAlertAgain: Duration(days: 1),
            //debugDisplayOnce: true,
            showIgnore: false,
            // debugDisplayAlways: true,
          ),
          child: PagesManager());
    }
    return PagesManager();
  }

  Widget screenLoadingWidget(BuildContext context) {
    return Material(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
            width: 60,
            height: 60,
            child: loadingWidget(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(translate("waitForResult")),
          ),
        ]),
      ),
    );
  }

  Widget errorWidget(BuildContext context) {
    vibrate();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: CustomContainer(
          width: gWidth * 0.7,
          height: gHeight * 0.6,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AppErrors.displayError(title: 'ישנה בעיה בכניסה'),
              GestureDetector(
                child: Icon(
                  Icons.refresh,
                  size: 40,
                ),
                onTap: () {
                  loadingProvider.status = LoadingStatuses.loading;
                  Navigator.pop(context);
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => LoadApp()));
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget timeError(BuildContext context) {
    vibrate();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: CustomContainer(
          padding: EdgeInsets.symmetric(horizontal: 5),
          width: gWidth * 0.7,
          height: gHeight * 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Center(
                        child: Text(
                          translate("timeAndNetworkError"),
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      translate("checkDateTime"),
                      textAlign: TextAlign.center,
                    ),
                    Text(translate("everythingOk")),
                    Text(translate("checkVpn")),
                    Text(translate("everythingOk")),
                  ]),
              GestureDetector(
                child: Icon(
                  Icons.refresh,
                  size: 40,
                ),
                onTap: () {
                  loadingProvider.status = LoadingStatuses.loading;
                  Navigator.pop(context);
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => LoadApp()));
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget loadingWidget() {
    return SizedBox(
      height: gHeight * 0.25,
      child: Center(
        child: Lottie.asset(loadingAnimation,
            width: gWidth * 0.3, height: gHeight * 0.2),
      ),
    );
  }
}
