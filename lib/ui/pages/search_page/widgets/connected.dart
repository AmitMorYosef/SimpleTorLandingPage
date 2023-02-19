import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:management_system_app/ui/pages/search_page/widgets/app_bar.dart';
import 'package:management_system_app/ui/pages/search_page/widgets/suggestion_item.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/limitations.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/screens_data.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../models/preview_model.dart';
import '../../../../services/enable_scroll_options.dart';
import '../../../../utlis/string_utlis.dart';
import '../../../general_widgets/custom_widgets/custom_container.dart';
import '../../../pages_opener.dart';

class ConnectedPage extends StatelessWidget {
  ConnectedPage({super.key});
  late List<Tab> tabs;

  @override
  Widget build(BuildContext context) {
    tabs = <Tab>[
      Tab(
          child: Text(
        translate('recently'),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 15),
      )),
      Tab(
          child: Text(
        translate('myBuisnesses'),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 15),
      )),
    ];

    return DefaultTabController(
      length: tabs.length,
      initialIndex: ScreensData.searchTabIndex,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context);
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            ScreensData.searchTabIndex = tabController.index;
          }
        });
        return CustomScrollView(
            scrollBehavior: EnableScrollOptions(),
            slivers: [
              AppBarSearch(),
              SliverFillRemaining(
                fillOverscroll: true,
                child: Column(
                  children: [
                    TabBar(
                      splashFactory: NoSplash.splashFactory,
                      tabs: tabs,
                      indicatorColor: Theme.of(context).colorScheme.secondary,
                    ),
                    Expanded(
                      child: SizedBox(
                        width: gWidth,
                        child: TabBarView(
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              LastVisitedBuisnesses(),
                              myBuisnessesList(context),
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
            ]);
      }),
    );
  }

  RenderObjectWidget myBuisnessesList(BuildContext context) {
    final buisnesses = SettingsData.buisnessesPreview.buisnesses;

    Set<Preview> previews = UserData.user.previews.values.toSet();
    for (final buisnessId in UserData.user.myBuisnessesIds) {
      if (buisnesses.containsKey(buisnessId))
        previews.add(buisnesses[buisnessId]!);
    }
    List<Widget> previewsWidget = [];
    previews.forEach((element) {
      previewsWidget.add(SuggestionItem(
        isPrivate: UserData.user.previews.containsKey(element.buisnessId),
        fromSearch: false,
        preview: element,
      ));
    });

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: previews.isEmpty
          ? Column(
              children: [
                Lottie.asset(createBusinessAnimation, height: gHeight * 0.43),
                SizedBox(
                  height: gHeight * 0.03,
                ),
                FittedBox(
                  child: CustomContainer(
                      image: null,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      onTap: () async {
                        await PagesOpener()
                            .openBusinessCreation(context: context);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          Text(translate("craeteMyBusiness", needGender: false),
                              style: TextStyle()),
                        ],
                      )),
                ),
              ],
            )
          : Column(
              children: previewsWidget,
            ),
    );
  }
}

class LastVisitedBuisnesses extends StatelessWidget {
  const LastVisitedBuisnesses({super.key});

  @override
  Widget build(BuildContext context) {
    final buisnesses = SettingsData.buisnessesPreview.buisnesses;

    List<Preview> previews = [];

    final lastVisitedReveresed =
        [...UserData.user.lastVisitedBuisnesses].reversed;

    lastVisitedReveresed.forEach((buisnessId) {
      if (previews.length < lastVisitedBuisnessesLimit &&
          buisnesses.containsKey(buisnessId))
        previews.add(buisnesses[buisnessId]!);
    });

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: previews.isEmpty
          ? Column(
              children: [
                Text(
                  translate('clickToFindBuisnesses'),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Icon(Icons.search,
                    size: 20, color: Theme.of(context).iconTheme.color!)
              ],
            )
          : buisnessesWidget(previews),
    );
  }

  Widget buisnessesWidget(Iterable<Preview> reversedPreviews) {
    List<Widget> previewsWidget = [];
    reversedPreviews.forEach((element) {
      previewsWidget.add(SuggestionItem(
        isPrivate: UserData.user.previews.containsKey(element.buisnessId),
        fromSearch: false,
        fromLastVisited: true,
        preview: element,
      ));
    });
    return Column(
      children: previewsWidget,
    );
  }
}
