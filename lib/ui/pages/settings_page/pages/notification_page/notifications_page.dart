import 'package:flutter/material.dart';
import 'package:management_system_app/ui/pages/settings_page/category_container.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/notification_page/notification_utils.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/notification_page/widgets/subs_to.dart';

import '../../../../../app_statics.dart/user_data.dart';
import '../../../../../utlis/string_utlis.dart';
import '../../../../general_widgets/buttons/info_button.dart';

// ignore: must_be_immutable
class NotificationsPage extends StatelessWidget {
  NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    notificationContext = context;
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          appBar: AppBar(
            actions: [
              infoButton(
                  context: context,
                  text: translate("hereYouCanSeeYourNotifications")),
            ],
            elevation: 0,
            title: Text(translate("notifications")),
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          body:
              Column(children: [user(), worker(), manager(), SubToCategory()]),
        ),
      ),
    );
  }

  Widget user() {
    return CategoryContainer(
      key: UniqueKey(),
      category: translate("settings"),
      categortSettings: userSettings,
      isFirst: true,
    );
  }

  Widget manager() {
    if (UserData.getPermission() < 2) return SizedBox();
    return CategoryContainer(
      key: UniqueKey(),
      category: translate("managerNotifications"),
      categortSettings: managerSettings,
    );
  }

  Widget worker() {
    if (UserData.getPermission() < 1) return SizedBox();
    return CategoryContainer(
      key: UniqueKey(),
      category: translate("workerNotifications"),
      categortSettings: workerSettings,
    );
  }
}
