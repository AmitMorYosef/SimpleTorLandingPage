import 'package:flutter/material.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/schedule_page/schedule_utils.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/worker_provider.dart';
import '../../../../../utlis/string_utlis.dart';
import '../../../../general_widgets/buttons/info_button.dart';
import '../../category_container.dart';

// ignore: must_be_immutable
class SettingsSchedulePage extends StatelessWidget {
  SettingsSchedulePage({super.key});
  @override
  Widget build(BuildContext context) {
    scheduleContext = context;
    context.watch<WorkerProvider>();
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          appBar: AppBar(
            actions: [
              infoButton(
                  context: context,
                  text: translate("hereYouCanManageYourScheduleSettings")),
            ],
            elevation: 0,
            title: Text(translate("mySchedule")),
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Column(children: [
            workContainer(),
            eventsContainer(),
            designContainer()
          ]),
        ),
      ),
    );
  }

  Widget workContainer() {
    return CategoryContainer(
      key: UniqueKey(),
      category: translate("work"),
      categortSettings: work,
      isFirst: true,
    );
  }

  Widget eventsContainer() {
    return CategoryContainer(
      key: UniqueKey(),
      category: translate("events"),
      categortSettings: events,
    );
  }

  Widget designContainer() {
    return CategoryContainer(
      key: UniqueKey(),
      category: translate("design"),
      categortSettings: design,
    );
  }
}
