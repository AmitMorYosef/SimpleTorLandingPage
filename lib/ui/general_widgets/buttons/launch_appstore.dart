import 'package:flutter/material.dart';
import 'package:management_system_app/services/in_app_services.dart/app_launcher.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';

import '../../../app_const/app_sizes.dart';
import '../../helpers/fonts_helper.dart';

class LaunchAppButton extends StatelessWidget {
  final String text;
  const LaunchAppButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: () => AppLauncher().lunchStore(),
      raduis: 60,
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: gWidthOriginal * 0.1),
      color: Theme.of(context).colorScheme.secondary,
      child: Center(
        child: Text(
          text,
          style: FontsHelper().businessStyle(
              currentStyle: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontSize: 16)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
