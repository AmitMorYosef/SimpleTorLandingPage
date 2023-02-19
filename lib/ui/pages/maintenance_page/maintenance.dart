import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_tor_web/providers/loading_provider.dart';
import 'package:simple_tor_web/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:provider/provider.dart';

import '../../../app_const/app_sizes.dart';
import '../../../app_const/loading_statuses.dart';
import '../../../app_const/resources.dart';
import '../../../utlis/string_utlis.dart';
import '../../animations/enter_animation.dart';
import '../../general_widgets/buttons/change_lang_button.dart';
import '../../load_app.dart';

class Maintenance extends StatelessWidget {
  const Maintenance({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Stack(
          children: [
            Positioned(
              child: ChangeLangButton(),
              top: 40,
              right: 20,
            ),
            Container(
              padding: EdgeInsets.only(top: gHeight * 0.1),
              width: gWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(maintenanceAnimation, height: gHeight * 0.43),
                  SizedBox(
                    height: gHeight * .05,
                  ),
                  SizedBox(
                    width: gWidth * .9,
                    height: gHeight * .42,
                    child: EnterAnimation(
                      animationDuration: Duration(milliseconds: 800),
                      childCreator: detailsColumn,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget detailsColumn(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          translate("WorkOnIt"),
          textAlign: TextAlign.center,
          style:
              Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 24),
        ),
        SizedBox(
          height: 15,
        ),
        SizedBox(
          width: gWidth * .8,
          child: Text(
            translate("maintenanceDescription"),
            style:
                Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
        Spacer(),
        updateButton(context)
      ],
    );
  }

  Widget updateButton(BuildContext context) {
    return CustomContainer(
      onTap: () async {
        context.read<LoadingProvider>().status = LoadingStatuses.loading;
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => LoadApp()));
      },
      color: Theme.of(context).colorScheme.secondary,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 12),
      margin: EdgeInsets.only(bottom: 40),
      raduis: 999,
      width: gWidth * .88,
      child: Text(
        translate("Reload"),
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 18),
      ),
    );
  }
}
