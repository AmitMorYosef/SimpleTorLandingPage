import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/sliding_bottom_sheet.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/load_products_widget.dart';
import 'package:management_system_app/ui/general_widgets/pickers/subscription_picker.dart/choose_purchase_plan.dart';
import 'package:management_system_app/ui/pages/settings_page/category_container.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/widgets/support_page.dart';
import 'package:management_system_app/ui/pages/settings_page/settings_utlis.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../app_const/app_sizes.dart';
import '../../../app_const/platform.dart';
import '../../../app_const/resources.dart';
import '../../../app_statics.dart/screens_data.dart';
import '../../../app_statics.dart/settings_data.dart';
import '../../../app_statics.dart/subscription_data.dart';
import '../../../app_statics.dart/user_data.dart';
import '../../../providers/user_provider.dart';
import '../../../services/enable_scroll_options.dart';
import 'dialogs/profile.dart';

// ignore: must_be_immutable
class SettingsPage extends StatefulWidget {
  final bool onlyForDisplay;
  final ScrollController settingsPageController;
  SettingsPage(
      {super.key,
      this.onlyForDisplay = false,
      required this.settingsPageController});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool needRenewPurchase = false;
  List<Map<String, dynamic>> widgetNames = [];

  String showDate = '';

  @override
  void initState() {
    super.initState();
    createItemsList();
    widget.settingsPageController.addListener(() {
      ScreensData.settingsScrollControllerOffset =
          widget.settingsPageController.offset;
    });
  }

  @override
  void dispose() {
    //widget.settingsPageController.dispose();
    super.dispose();
  }

  void createItemsList() {
    /*
    calculate which containers will be displayed - enable the usage on
    listView.builder() when passing over this list
     */
    int userPermission = UserData.getPermission();
    if (widget.onlyForDisplay) {
      userPermission = 2;
    }

    widgetNames = [
      {'name': 'userProfileDetails'},
    ];
    if (UserData.isConnected()) {
      widgetNames += [
        {'name': 'user', 'settings': userOption},
      ];
    }

    if (userPermission > 0) {
      widgetNames += [
        {'name': 'work', 'settings': employeeSettings},
      ];
    }
    if (userPermission > 1) {
      widgetNames += [
        {'name': 'payments', 'settings': paymentsSettings},
        {'name': 'edits', 'settings': buisnessEditSettings},
        {'name': 'display', 'settings': buisnessDisplaySettings},
        {'name': 'options', 'settings': buisnessOptions},
        {'name': 'blocks', 'settings': blocks},
      ];
    }
    if (userPermission > 1 && !isWeb) {
      widgetNames += [
        {'name': 'purchases', 'settings': purchases},
      ];
    }
    if (userPermission == 1) {
      widgetNames += [
        {'name': 'shareBusiness', 'settings': shareBuisness}
      ];
    }
    if (UserData.isConnected()) {
      widgetNames += [
        {'name': 'buisnessCreation', 'settings': buisnessMaker},
      ];
    } else {
      widgetNames += [
        {'name': 'user', 'settings': loggin},
        {'name': 'buisnessCreation', 'settings': buisnessMaker},
      ];
    }
    widgetNames.add({'name': 'language', 'settings': language});

    if (userPermission != 2 && UserData.isConnected() && !isWeb) {
      widgetNames += [
        {'name': 'purchases', 'settings': purchasesForUser},
      ];
    }
  }

  Widget listOfSettings(int userPermission) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(childCount: widgetNames.length + 1,
            (context, index) {
      // space at the end of the list
      if (index == widgetNames.length) {
        return Column(
          children: [
            SizedBox(
              height: 20,
            ),
            NoUsedSubsIndicator(),
            SizedBox(
              height: gHeight * 0.08,
            ),
          ],
        );
      }
      // return the containers from the widgetNames
      Map<String, dynamic> currentContainer = widgetNames[index];
      switch (currentContainer['name']) {
        case 'userProfileDetails':
          return userProfileDetails(userPermission);

        case 'notifications':
          return CategoryContainer(
            isFirst: currentContainer['isFirst'],
            category: translate(currentContainer['name']),
            categortSettings: currentContainer['settings'],
          );
        case 'buisnessCreation':
          return Opacity(
            opacity: UserData.user.limitOfBuisnesses >
                    UserData.user.myBuisnessesIds.length
                ? 1
                : 0.6,
            child: CategoryContainer(
              category: translate(currentContainer['name']),
              categortSettings: currentContainer['settings'],
            ),
          );
        default:
          return CategoryContainer(
            category: translate(currentContainer['name']),
            categortSettings: currentContainer['settings'],
          );
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    int userPermission = UserData.getPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.settingsPageController.hasClients)
        widget.settingsPageController
            .jumpTo(ScreensData.settingsScrollControllerOffset);
    });
    // UpgradeAlert(
    //       child: Scaffold(
    //     appBar: AppBar(title: Text('Upgrader Example')),
    //     body: Center(child: Text('Checking...')),
    //   )),

    settingsContext = context;
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
          scrollBehavior: EnableScrollOptions(),
          controller: widget.settingsPageController,
          slivers: [
            widget.onlyForDisplay
                ? SliverToBoxAdapter()
                : SliverAppBar(
                    elevation: 0,
                    toolbarHeight: 44,
                    stretch: true,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.all(8.0),
                      title: SettingsAppBar(context),
                      stretchModes: [StretchMode.blurBackground],
                      collapseMode: CollapseMode.parallax,
                      centerTitle: true,
                    ),
                    floating: true,
                    pinned: true,
                    expandedHeight: 44,
                  ),
            listOfSettings(userPermission),
          ]),
    );
  }

  Widget userProfileDetails(int userPermission) {
    return Stack(
      children: [
        Container(
          width: gWidthOriginal,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                trialIndicator(),
                Profile(
                  showEdit: false,
                  editWhenTap: true,
                  raduis: gDiagnol * 0.1,
                ),
              ],
            ),
          ),
        ),
        reminderNavigator()
      ],
    );
  }

  Widget trialIndicator() {
    if (SettingsData.isBusinessPublish() || UserData.getPermission() != 2)
      return SizedBox();

    return Container(
        width: gWidth * 0.4,
        child: Text(
          translate("businesssNotActiveForEveryone"),
          style: TextStyle(fontSize: gDiagnol * 0.015),
          textAlign: TextAlign.center,
        ));
  }

  Widget SettingsAppBar(BuildContext context) {
    return SizedBox(
      width: gWidth * .85,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 22,
          ),
          GestureDetector(
            onTap: () {
              widget.settingsPageController.animateTo(0,
                  duration: Duration(
                      milliseconds:
                          (widget.settingsPageController.offset / 20).floor()),
                  curve: Curves.linear);
            },
            child: Container(
              height: 44,
              alignment: Alignment.center,
              child: Text(translate("settings"),
                  style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          contactUsButton()
        ],
      ),
    );
  }

  Widget contactUsButton() {
    return GestureDetector(
        onTap: () async {
          dynamic resp = await SlidingBottomSheet(
                  context: settingsContext, sheet: SupportPage(), size: 0.7)
              .showSheet();
        },
        child: Icon(
          Icons.support_agent_outlined,
          size: 22,
        )
        // Transform.rotate(
        //     angle: pi / 1.3,
        //     child: Icon(
        //       Icons.send,
        //       size: 18,
        //     )),
        );
  }

  Widget reminderNavigator() {
    if (UserData.getPermission() != 2) {
      return SizedBox();
    }
    if (SettingsData.activeBusiness && SettingsData.isBusinessPublish())
      return SizedBox();

    return Positioned(
      left: 10,
      top: 0,
      child: SafeArea(
        child: CustomContainer(
          image: null,
          onTap: () async {
            SubscriptionData.init();

            SlidingBottomSheet(
                    context: context,
                    sheet: LoadProductsWidget(
                      childCreator: purchasePlanSheet,
                      isWorker: false,
                    ),
                    size: 1)
                .showSheet();
          },
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              Lottie.asset(attentionAnimation,
                  height: gHeight * 0.05, width: gHeight * 0.05, repeat: false),
              Container(
                constraints: BoxConstraints(
                    maxWidth: gWidth * 0.22, minWidth: gWidth * 0.14),
                child: Text(
                  UserData.user.previews.containsKey(SettingsData.appCollection)
                      ? translate("publishBusiness")
                      : translate("subscriptionRenewal"),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget purchasePlanSheet(BuildContext context) {
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
}

class NoUsedSubsIndicator extends StatelessWidget {
  const NoUsedSubsIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<UserProvider>();
    int notUsedSubsCount = 0;
    UserData.user.productsIds.forEach((productsId, details) {
      if (details["businessId"] == "") {
        notUsedSubsCount += 1;
      }
    });

    String notUsedSubs = "";
    if (notUsedSubsCount != 0) {
      notUsedSubs =
          "${translate("youHave")} ($notUsedSubsCount) ${translate("subsNoInUse")}";
    }

    return notUsedSubs != ""
        ? SizedBox(
            width: gWidthOriginal * 0.4,
            child: Text(
              notUsedSubs,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontSize: 17),
            ),
          )
        : SizedBox();
  }
}
