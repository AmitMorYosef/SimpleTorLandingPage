import 'package:flutter/material.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/business_creation/widgets/continue_button.dart';

import '../../../../../../app_const/app_sizes.dart';
import '../../../../../../utlis/string_utlis.dart';
import '../../../../../general_widgets/custom_widgets/bullet_list_text.dart';
import '../../../../../general_widgets/pickers/pick_circle_image.dart';
import '../make_new_buisness.dart';

class BusinessCreationOpenScreen extends StatelessWidget {
  BusinessCreationOpenScreen({super.key});

  final List<String> lines = [
    translate('forBusinessCreation1'),
    translate('forBusinessCreation2'),
    translate('forBusinessCreation3'),
    translate('forBusinessCreation4'),
    translate('forBusinessCreation5'),
    translate('forBusinessCreation6'),
    translate('forBusinessCreation7')
  ];

  @override
  Widget build(BuildContext context) {
    PickCircleImage.imageForBusiness = null;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        title: Text(translate("buisnessCreation")),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Simple Tor",
            style:
                Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 60),
          ),
          promotionText(context),
          ContinueButton(
              width: gWidth * 0.9,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MakeNewBuisness(),
                    ));
              }),
          SizedBox(
            height: gHeight * 0.09,
          )
        ],
      ),
    );
  }

  Widget promotionText(BuildContext context) {
    return Expanded(
      child: Center(
        child: SizedBox(
          width: gWidthOriginal,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  translate('hereYouOpenBusiness'),
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                BulletListText(lines: lines),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  width: gWidth * .8,
                  child: Text(
                    translate('forBusinessCreation8'),
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall!
                        .copyWith(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Text line(String txt, BuildContext context) {
    return Text(
      txt,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16),
      textAlign: TextAlign.center,
    );
  }
}
