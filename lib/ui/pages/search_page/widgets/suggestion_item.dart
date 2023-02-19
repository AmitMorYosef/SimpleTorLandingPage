import 'dart:math';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:management_system_app/ui/general_widgets/buttons/info_button.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/business_types.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../models/preview_model.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../providers/user_provider.dart';
import '../../../../utlis/general_utlis.dart';
import '../../../../utlis/image_utlis.dart';

class SuggestionItem extends StatelessWidget {
  final Preview preview;
  final bool fromSearch;
  final bool fromLastVisited;
  final bool isPrivate;
  final bool isExample;
  SuggestionItem(
      {super.key,
      required this.preview,
      this.isExample = false,
      this.fromSearch = true,
      this.isPrivate = false,
      this.fromLastVisited = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          await loadItem(context);
        },
        child: isExample ? exampleItem(context) : onSearchItem(context));
  }

  Widget exampleItem(BuildContext context) {
    return CustomContainer(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(8.0),
      width: gWidth * 0.27,
      needImage: false,
      child: Column(children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            preview.name,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            preview.address,
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 10),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        showCircleCachedImage(preview.imageUrl, 50, SettingsData.businessIcon!),
      ]),
    );
  }

  Widget onSearchItem(BuildContext context) {
    return CustomContainer(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.all(8.0),
        needImage: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 60,
              padding: EdgeInsets.only(left: 10),
              child: showCircleCachedImage(
                  preview.imageUrl, 50, SettingsData.businessIcon!),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      preview.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      preview.address,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            iconsRow(context)
          ],
        ));
  }

  Widget iconsRow(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          businessTypeIcon(context),
          privateIcon(context),
          delete(context)
        ],
      ),
    );
  }

  Widget privateIcon(BuildContext context) {
    return isPrivate
        ? infoButton(
            padding: EdgeInsets.only(left: 2),
            context: context,
            text: translate("privateBusinessExplain"),
            child: Icon(Icons.privacy_tip_sharp, size: 17))
        : SizedBox();
  }

  Widget businessTypeIcon(BuildContext context) {
    return !isPrivate
        ? Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn),
              child: Image.asset(
                businessTypesToIcon[preview.businesseType]!,
                width: min(30, gDiagnol * 0.03),
                height: min(30, gDiagnol * 0.03),
              ),
            ),
          )
        : SizedBox();
  }

  Widget delete(BuildContext context) {
    return fromLastVisited
        ? Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: BouncingWidget(
              onPressed: () async {
                UiManager.updateUi(
                    context: context,
                    perform: Future((() => context
                        .read<UserProvider>()
                        .deleteVisitedBuisness(preview.buisnessId))));
              },
              child: Icon(
                FontAwesomeIcons.x,
                size: 15,
              ),
            ),
          )
        : SizedBox();
  }

  Future<void> loadItem(BuildContext context) async {
    overLaysHandling();
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    if (!await isNetworkConnected()) {
      notNetworkConnectedToast(context);
      return;
    }
    await Loading(
            context: context,
            navigator: Navigator.of(context),
            future: context.read<SettingsProvider>().loadBuisness(
                context, preview.buisnessId.replaceFirst(" ", '')),
            msg: translate('successfullyLoadedBuisness'),
            animation: successAnimation)
        .dialog()
        .then((value) {
      if (value is bool && value == true) {
        if (fromSearch) Navigator.pop(context, this.preview.buisnessId);
      } else {
        if (value is String && value == translate('alreadyDeletedBuisness')) {
          UiManager.updateUi(
              context: context,
              perform: Future(() async {
                context
                    .read<UserProvider>()
                    .removeDeletedLastVisitedBuisnesses();
                await SettingsData.emptyBusinessData();
              }));
        } else {
          //if fail we want to delete all the data that already pass
          UiManager.updateUi(
              context: context, perform: SettingsData.emptyBusinessData());
        }
      }
    });
  }
}
