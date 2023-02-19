import 'package:flutter/material.dart';
import 'package:management_system_app/providers/settings_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../../app_statics.dart/settings_data.dart';
import '../../../../../../providers/device_provider.dart';
import '../../../../../../utlis/notifications_utlis.dart';

class NotifyOnNewCustomer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    return Container(
      height: 20,
      width: 25,
      child: Switch(
          activeColor: Theme.of(context).colorScheme.secondary,
          value: SettingsData.settings.notifyOnNewCustomer,
          onChanged: (val) async {
            if (val && !context.read<DeviceProvider>().isAllowedNotification) {
              await activateNotificationDialog(context);
            }
            if (!val || context.read<DeviceProvider>().isAllowedNotification) {
              SettingsData.changeNotifyOnNewCustomer(val, context);
            }
          }),
    );
  }
}
