import 'package:flutter/material.dart';
import 'package:management_system_app/ui/pages/buisness_page/widgets/business_name.dart';

import '../../../../../../app_const/app_sizes.dart';
import '../../../../../../services/enable_scroll_options.dart';
import '../../../../buisness_page/widgets/animated_images.dart';
import '../../../../buisness_page/widgets/app_icons.dart';
import '../../../../buisness_page/widgets/business_icon.dart';
import '../../../../buisness_page/widgets/products.dart';
import '../../../../buisness_page/widgets/story.dart';
import '../../../../buisness_page/widgets/updates.dart';
import '../business_fonts_manager.dart';

class PhoneFontsExample extends StatefulWidget {
  PhoneFontsExample({super.key});

  @override
  State<PhoneFontsExample> createState() => _PhoneFontsExampleState();
}

class _PhoneFontsExampleState extends State<PhoneFontsExample> {
  final double pHeigth = gHeight / 2.2;
  final double pWidth = gWidth / 2.2;
  final double ratio = 1 / 2.2;

  @override
  void initState() {
    super.initState();
    BusinessFontsManager.setPhoneState = changeFont;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: pHeigth,
      width: pWidth * 1.1,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.circular(25),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: CustomScrollView(
            scrollBehavior: EnableScrollOptions(),
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: (changingImagesHeight) * ratio,
                toolbarHeight: (changingImagesHeight * 0.32) * ratio,
                stretchTriggerOffset: 150 * ratio,
                onStretchTrigger: () async {
                  return;
                },
                stretch: true,
                elevation: 0,
                pinned: true,
                leading: SizedBox(),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(
                      bottom: 5), // remove default bottom padding
                  centerTitle: true,
                  stretchModes: [
                    StretchMode.zoomBackground,
                    //StretchMode.blurBackground,
                    StretchMode.fadeTitle
                  ],
                  background: AnimatedImages(editMode: false),
                  title: BusinessIcon(
                    height: pHeigth * 0.16,
                    width: pWidth * 0.16,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(businessBody()),
              )
            ]),
      ),
    );
  }

  void changeFont() {
    setState(() {});
  }

  List<Widget> businessBody() {
    return [
      BusinessName(includeEdit: false, ratio: ratio),
      SizedBox(
        height: 60 * ratio,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9),
        child: Updates(
          editMode: false,
          ratio: ratio * 1.3,
        ),
      ),
      SizedBox(height: 30 * ratio),
      Story(
        editMode: false,
        ratio: ratio * 1.3,
      ),
      SizedBox(height: 30 * ratio),
      Products(
        editMode: false,
        ratio: ratio * 1.3,
      ),
      Center(
          child: AppIcons(
        maxWidth: pWidth * .7,
        editMode: false,
        ratio: ratio * 1.3,
      )),
      SizedBox(
        height: pHeigth * .1,
      )
    ];
  }
}
