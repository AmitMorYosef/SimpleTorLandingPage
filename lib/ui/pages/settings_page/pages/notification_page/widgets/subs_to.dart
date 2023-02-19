import 'package:flutter/material.dart';
import 'package:management_system_app/providers/user_provider.dart';
import 'package:management_system_app/ui/animations/rotate_animation.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_button.dart';
import 'package:management_system_app/ui/pages/settings_page/category_container.dart';
import 'package:management_system_app/utlis/image_utlis.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

import '../../../../../../app_const/notification.dart';
import '../../../../../../app_statics.dart/settings_data.dart';
import '../../../../../../app_statics.dart/user_data.dart';
import '../../../../../../models/notification_topic.dart';
import '../../../../../../services/in_app_services.dart/language.dart';

// ignore: must_be_immutable
class SubToCategory extends StatelessWidget {
  SubToCategory({super.key});
  late UserProvider userProvider;
  List<Widget> waitingListNotifications = [];
  List<Widget> businessNotifications = [];
  List<Map<String, dynamic>> listsWidgets = [];

  @override
  Widget build(BuildContext context) {
    ///userProvider = context.watch<UserProvider>();
    businessNotifications = [];
    listsWidgets = [];
    if (UserData.user.subToNotifications.containsKey(NotifySorts.buisness)) {
      UserData.user.subToNotifications[NotifySorts.buisness]!.values
          .forEach((data) {
        businessNotifications
            .add(notificationTile(data, NotifySorts.buisness, context));
      });
    }

    listsWidgets.add({
      "icon": Icon(Icons.list_alt),
      "name": "businesses",
      "subtitle": Text(
          businessNotifications.length == 1
              ? translate("oneBusiness")
              : "${businessNotifications.length} ${translate("businesses")}",
          style: TextStyle(fontSize: 11)),
      "children": businessNotifications,
      "onClick": () {},
    });
    if (UserData.user.subToNotifications.containsKey(NotifySorts.waitingList)) {
      UserData.user.subToNotifications[NotifySorts.waitingList]!.values
          .forEach((data) {
        waitingListNotifications
            .add(notificationTile(data, NotifySorts.waitingList, context));
      });
    }

    listsWidgets.add({
      "icon": Icon(Icons.list_alt),
      "name": "waitingLists",
      "subtitle": Text(
          waitingListNotifications.length == 1
              ? translate("oneList")
              : "${waitingListNotifications.length} ${translate("lists")}",
          style: TextStyle(fontSize: 11)),
      "children": waitingListNotifications,
      "onClick": () {},
    });

    return CategoryContainer(
      needDividers: false,
      needPadding: false,
      category: translate("myNotification"),
      categortSettings: listsWidgets,
      explainText: translate("myNotificationsExplain"),
    );
  }

  Widget notificationTile(
      String topicStr, NotifySorts sort, BuildContext context) {
    /**
     TODO: check if business exist
     */
    NotificationTopic notificationTopic =
        NotificationTopic.fromTopicStr(topicStr);
    String buisnessName = notificationTopic.businessName;
    Text nameWidget = Text(
      buisnessName,
      style: Theme.of(context).textTheme.titleLarge,
    );

    Widget details = nameWidget;

    final buisnessImage = notificationTopic.imageUrl;
    details = Row(
      children: [
        showCircleCachedImage(buisnessImage, 34, SettingsData.businessIcon!),
        SizedBox(width: 10),
        nameWidget
      ],
    );

    LoadingButton loadingWidget = LoadingButton(
      key: UniqueKey(),
      neewUiUpdate: true,
      startState: Icon(Icons.delete),
      middleState: RotateAnimation(child: Icon(Icons.change_circle)),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          details,
          sort == NotifySorts.waitingList
              ? Container(
                  margin: EdgeInsets.symmetric(vertical: 1),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        notificationTopic.workerName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        notificationTopic.date,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ))
              : SizedBox(),
          Container(
              alignment: ApplicationLocalizations.of(context)!.isRTL()
                  ? Alignment.topLeft
                  : Alignment.topRight,
              width: 50,
              child: trashIcon(context, loadingWidget, notificationTopic, sort))
        ],
      ),
    );
  }

  Widget trashIcon(BuildContext context, LoadingButton loadingWidget,
      NotificationTopic notificationTopic, NotifySorts sort) {
    return InkWell(
        onTap: () async {
          if (loadingWidget.isNowLoading) return;
          loadingWidget.load!(
            startState: Icon(Icons.delete),
            endState: SizedBox(),
            future: () => userProvider.unSubNotification(
                topicId: notificationTopic.toTopicStr(), sort: sort),
          );
        },
        child: loadingWidget);
  }
}
