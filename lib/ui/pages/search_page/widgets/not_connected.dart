import 'dart:math';

import 'package:flutter/material.dart';
import 'package:management_system_app/ui/animations/enter_animation.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/pages/search_page/widgets/app_bar.dart';
import 'package:management_system_app/ui/pages/search_page/widgets/suggestion_item.dart';
import 'package:management_system_app/ui/pages_opener.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../services/enable_scroll_options.dart';
import '../../../../services/in_app_services.dart/language.dart';
import '../../../../utlis/string_utlis.dart';

class NotConnectedPage extends StatelessWidget {
  const NotConnectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final previewsList =
        SettingsData.buisnessesPreview.buisnesses.values.toList();
    previewsList.shuffle();
    return EnterAnimation(
      animationDuration: Duration(milliseconds: 500),
      animate: false,
      child: CustomScrollView(scrollBehavior: EnableScrollOptions(), slivers: [
        AppBarSearch(),
        SliverFillRemaining(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              welcome(context),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                width: gWidth * 0.9,
                child: Text(translate("createBusinessFree"),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18)),
              ),
              SizedBox(
                height: 10,
              ),
              FittedBox(
                child: CustomContainer(
                    image: null,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    onTap: () async {
                      await PagesOpener()
                          .openBusinessCreation(context: context);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.add),
                        Text(translate("craeteMyBusiness"), style: TextStyle()),
                      ],
                    )),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: SizedBox(
                  width: gWidth * 0.95,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: min(
                        5, SettingsData.buisnessesPreview.buisnesses.length),
                    itemBuilder: (context, index) {
                      return SuggestionItem(
                        preview: previewsList[index],
                        isExample: false,
                        fromSearch: false,
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }

  Widget welcome(BuildContext context) {
    return Container(
        width: gWidthOriginal,
        padding: EdgeInsets.all(10.0),
        alignment: ApplicationLocalizations.of(context)!.isRTL()
            ? Alignment.topRight
            : Alignment.topLeft,
        child: SizedBox(
          width: gWidth * 0.7,
          child: Text(
            translate("welcome") + ",",
            style: TextStyle(
                fontSize: 32,
                color: Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(0.7)),
          ),
        ));
  }
}
