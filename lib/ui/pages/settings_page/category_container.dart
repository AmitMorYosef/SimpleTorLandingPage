import 'package:flutter/material.dart';
import 'package:management_system_app/providers/settings_provider.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/pages/settings_page/setting_item.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../app_const/app_sizes.dart';
import '../../../app_const/purchases.dart';
import '../../../app_statics.dart/settings_data.dart';
import '../../../app_statics.dart/user_data.dart';
import '../../../utlis/general_utlis.dart';

class CategoryContainer extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> categortSettings;
  final bool isFirst;
  final String explainText;
  final bool needDividers;
  final bool needPadding;
  final Alignment alignment;
  const CategoryContainer({
    Key? key,
    required this.category,
    this.explainText = "",
    this.needPadding = true,
    this.needDividers = true,
    required this.categortSettings,
    this.isFirst = false,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    List<Widget> settingsList = [];
    categortSettings.asMap().forEach((index, map) {
      settingsList.add(Column(
        children: [
          SettingItem(
            trailing: !isDisable(map["name"]) && map.containsKey("trailing")
                ? map["trailing"]
                : null,
            subtitle: map["subtitle"] ?? null,
            children: map["children"] ?? null,
            icon: map["icon"],
            name: translate(map["name"]),
            onClick: isDisable(map["name"]) || !isEligible(map["name"])
                ? () {
                    if (!isEligible(map["name"])) {
                      if (UserData.getPermission() == 2) {
                        funcNotAvailableManagerToast(context);
                      } else {
                        funcNotAvailableClientToast(context);
                      }
                    } else
                      expiredSubToast(context);
                  }
                : () async {
                    if (!await isNetworkConnected() &&
                        map["name"] != 'timeBeforeNotify') {
                      notNetworkConnectedToast(context);
                      return;
                    }

                    map["onClick"]();
                  },
            suffix: !isEligible(map["name"]) || isDisable(map["name"])
                ? Icon(Icons.lock)
                : map.keys.contains("suffix")
                    ? map["suffix"]
                    : Icon(Icons.arrow_forward_ios,
                        size: 14, color: Color(0xffA2A2B5)),
          ),
          index == categortSettings.length - 1 || !needDividers
              ? SizedBox()
              : SizedBox(
                  width: gWidth * 0.8,
                  child: Divider(
                    height: 6,
                    thickness: 1,
                  ),
                )
        ],
      ));
    });
    return Container(
      alignment: alignment,
      padding: this.isFirst
          ? const EdgeInsets.only(top: 10)
          : const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${category}",
            style:
                Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 13.3),
          ),
          SizedBox(
            height: 7,
          ),
          CustomContainer(
            padding:
                needPadding ? const EdgeInsets.symmetric(vertical: 7) : null,
            width: gWidth * 0.85,
            raduis: 16,
            child: Column(
              children: settingsList,
            ),
          ),
          explainText != ""
              ? SizedBox(
                  width: gWidth * 0.7,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3, right: 5),
                    child: Text(
                      explainText,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ))
              : SizedBox()
        ],
      ),
    );
  }

  bool isEligible(String name) {
    if (SettingsData.appCollection != "" &&
        SettingsData.businessSubtype == SubType.basic &&
        advanceOrHigherSettings.contains(name)) return false;
    return true;
  }

  bool isDisable(String name) {
    final changeableSettings = [
      "changePlan",
      "productsImages",
      "changingImages",
      "myWorkers"
    ];
    if (this.category == translate('user') ||
        this.category == translate('buisnessCreation') ||
        this.category == translate('notifications') ||
        this.category == translate("language") ||
        name == "restorePurchase" ||
        name == "deleteBusiness" ||
        name == "myWorkers") return false;
    if (changeableSettings.contains(name) &&
        SettingsData.isPassedLimit() &&
        SettingsData.activeBusiness) return false;

    return !SettingsData.activeBusiness || SettingsData.isPassedLimit();
  }
}
