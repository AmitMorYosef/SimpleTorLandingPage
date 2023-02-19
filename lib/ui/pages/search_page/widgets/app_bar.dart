import 'dart:io';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/general_widgets/qr_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/display.dart';
import '../../../../app_const/platform.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/theme_data.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../utlis/general_utlis.dart';
import '../../../../utlis/image_utlis.dart';
import '../../../../utlis/string_utlis.dart';
import '../../../general_widgets/custom_widgets/custom_container.dart';
import '../../../general_widgets/loading_widgets/loading_dialog.dart';
import '../../../pages_opener.dart';
import '../../settings_page/dialogs/log_out_dialog.dart';
import 'custome_search_delegate.dart';

class AppBarSearch extends StatelessWidget {
  const AppBarSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      toolbarHeight: 50,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.only(top: 4.0, right: 6, left: 6, bottom: 4),
          title: SizedBox(
              height: 50, width: gWidth * 0.95, child: searchBar(context)),
          collapseMode: CollapseMode.pin,
          centerTitle: true,
          expandedTitleScale: 1,
          background: title(context)),
      floating: true,
      pinned: true,
      expandedHeight: gHeight * 0.17,
    );
  }

  Widget title(BuildContext context) {
    return Container(
        padding:
            EdgeInsets.symmetric(vertical: gHeight * 0.025, horizontal: 10),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [logoAndName(context), loginOrOutButton(context)],
          ),
        ));
  }

  Widget searchBar(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Hero(
            tag: Key("kkk"),
            child: CustomContainer(
                margin:
                    EdgeInsets.only(top: (isWeb || !Platform.isIOS) ? 5 : 0),
                onTap: () async => await showSearch(
                    context: context, delegate: CustomSearchDelegate()),
                alignment: Alignment.topCenter,
                color:
                    Theme.of(context).colorScheme.background.withOpacity(0.2),
                image: null,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          translate('search'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Icon(Icons.search,
                            color: Theme.of(context)
                                .iconTheme
                                .color!
                                .withOpacity(0.5)),
                      ],
                    ),
                  ),
                )),
          ),
        ),
        BouncingWidget(
          onPressed: () => openQrScanner(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.qr_code_scanner_outlined),
          ),
        ),
      ],
    );
  }

  void openQrScanner(BuildContext context) async {
    if (!isWeb) {
      var status = await Permission.camera.status;
      if (status.isPermanentlyDenied) {
        genralDialog(
            context: context,
            title: translate('noPemission'),
            content: Text(
              translate('needToAllowImagesInSettings'),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(translate('ok')))
            ]);
      }
    }
    await genralDialog(
            animationType: DialogTransitionType.slideFromTopFade,
            context: context,
            title: translate("ScanBusinessCode"),
            content: QrScanner())
        .then((businessId) {
      if (businessId == null) return;
      loadBusinessFromQr(context, businessId);
    });
  }

  Widget loginOrOutButton(BuildContext context) {
    return BouncingWidget(
        child: Icon(UserData.isConnected() ? Icons.logout : Icons.login),
        onPressed: () async {
          UserData.isConnected()
              ? logOutDialog(context)
              : (await PagesOpener().openLogin(context: context));
        });
  }

  Widget logoAndName(BuildContext context) {
    return BouncingWidget(
      onPressed: () async {
        await PagesOpener()
            .openBusinessCreation(context: context, showToasts: false);
      },
      scaleFactor: 0.3,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            showCircleCachedImage(
                '',
                35,
                themes[AppThemeData.currentKeyTheme]!.brightness ==
                        Brightness.light
                    ? darkIcon
                    : launchIcon),
            SizedBox(width: 10),
            Text("Simple Tor",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 20)),
          ],
        ),
      ),
    );
  }

  Future<void> loadBusinessFromQr(
      BuildContext context, String businessId) async {
    if (!await isNetworkConnected()) {
      notNetworkConnectedToast(context);
      return;
    }
    await Loading(
            context: context,
            navigator: Navigator.of(context),
            future: context
                .read<SettingsProvider>()
                .loadBuisness(context, businessId),
            msg: translate('successfullyLoadedBuisness'),
            animation: successAnimation)
        .dialog();
  }
}
