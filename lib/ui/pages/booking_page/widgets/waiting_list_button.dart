import 'package:flutter/material.dart';
import 'package:management_system_app/models/notification_topic.dart';
import 'package:management_system_app/providers/user_provider.dart';
import 'package:management_system_app/ui/animations/rotate_animation.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/utlis/general_utlis.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/notification.dart';
import '../../../../app_const/purchases.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../models/worker_model.dart';
import '../../../general_widgets/loading_widgets/loading_button.dart';

// ignore: must_be_immutable
class WaitingListButton extends StatelessWidget {
  NotificationTopic topic;
  WorkerModel worker;

  DateTime date;

  WaitingListButton(
      {super.key,
      required this.topic,
      required this.worker,
      required this.date});

  late UserProvider userProvider;
  late LoadingButton buttonIndicator;

  @override
  Widget build(BuildContext context) {
    userProvider = context.watch<UserProvider>();

    buttonIndicator = LoadingButton(
      key: UniqueKey(),
      startState: isSub()
          ? buttonWidget(context, translate('leveWaitingList'))
          : buttonWidget(context, translate('joinWaitingList')),
      middleState: CustomContainer(
        raduis: 60,
        height: 50,
        margin: EdgeInsets.symmetric(horizontal: gWidthOriginal * 0.1),
        color: Theme.of(context).colorScheme.secondary,
        child: Center(
            child: RotateAnimation(
                child: Icon(
          Icons.change_circle,
          color: Theme.of(context).colorScheme.onSecondary,
        ))),
      ),
    );

    return buttonIndicator;
  }

  bool isSub() {
    return userProvider.isAlreadySub(
        topicId: topic.toTopicStr(), sort: NotifySorts.waitingList);
  }

  Widget buttonWidget(BuildContext context, String text) {
    return CustomContainer(
      onTap: () {
        if (SettingsData.businessSubtype == SubType.basic) {
          UserData.getPermission() == 2
              ? funcNotAvailableManagerToast(context)
              : funcNotAvailableClientToast(context);
          return;
        }
        buttonIndicator.load!(
          startState: isSub()
              ? buttonWidget(context, translate('leveWaitingList'))
              : buttonWidget(context, translate('joinWaitingList')),
          endState: isSub()
              ? buttonWidget(context, translate('joinWaitingList'))
              : buttonWidget(context, translate('leveWaitingList')),
          future: () => isSub()
              ? userProvider.unSubNotification(
                  topicId: this.topic.toTopicStr(),
                  sort: NotifySorts.waitingList)
              : userProvider.subToNotification(
                  worker: worker,
                  date: date,
                  userName: UserData.user.name,
                  userPhone: UserData.user.phoneNumber,
                  notificationTopicObject: this.topic,
                  sort: NotifySorts.waitingList),
        );
      },
      raduis: 60,
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: gWidthOriginal * 0.1),
      color: Theme.of(context).colorScheme.secondary,
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
