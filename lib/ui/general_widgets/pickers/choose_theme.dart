import 'package:flutter/material.dart';
import 'package:management_system_app/providers/theme_provider.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_divider.dart';
import 'package:management_system_app/ui/pages/buisness_page/widgets/fade_widget.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../app_const/app_sizes.dart';
import '../../../app_const/display.dart';
import '../../../app_const/resources.dart';
import '../../../app_statics.dart/theme_data.dart';
import '../../../providers/settings_provider.dart';

// ignore: must_be_immutable
class ChooseTheme extends StatefulWidget {
  bool changeThemeInDb;
  static Themes? currentTheme;
  ChooseTheme({super.key, this.changeThemeInDb = true});

  @override
  State<ChooseTheme> createState() => _ChooseThemeState();
}

class _ChooseThemeState extends State<ChooseTheme> {
  double currentHeight = gHeight * .4;
  double currentWidth = gWidth * .45;

  @override
  void initState() {
    if (ChooseTheme.currentTheme == null) {
      ChooseTheme.currentTheme = AppThemeData.currentKeyTheme!;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            phoneExample(),
            spaceBetweenObjects,
            SizedBox(
              width: gWidth * .8,
              child: CustomDivider(txt: Text(translate('chooseThemes'))),
            ),
            spaceBetweenObjects,
            SizedBox(
              width: gWidth * .6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  option('dark'),
                  option('light'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget option(String optionKey) {
    return Column(
      children: [
        Text(translate(optionKey)),
        Radio<String>(
            value: optionKey,
            groupValue: themeToStr[ChooseTheme.currentTheme],
            onChanged: (String? value) {
              setState(() {
                if (value != null) {
                  final themeTemp = themeFromStr[value];

                  ChooseTheme.currentTheme = themeTemp!;
                  UiManager.updateUi(
                      context: context,
                      perform: Future(
                        () async {
                          await context.read<ThemeProvider>().changeTheme(
                                context,
                                themeTemp,
                              );
                          if (widget.changeThemeInDb) {
                            context
                                .read<SettingsProvider>()
                                .changeTheme(themeTemp);
                          }
                        },
                      ));
                }
              });
            }),
      ],
    );
  }

  Widget phoneExample() {
    return Container(
      height: currentHeight,
      width: currentWidth,
      decoration: BoxDecoration(
        color: themes[ChooseTheme.currentTheme]!.colorScheme.background,
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.circular(25),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
                width: currentWidth,
                height: currentHeight * .41,
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  fit: StackFit.expand,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.only(bottom: 3), // prevent line on fade
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25)),
                        child: Image.asset(
                          width: currentWidth,
                          ChooseTheme.currentTheme == Themes.dark
                              ? defaultPhoto
                              : defaultPhotoLight,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: FadeWidget(
                          color: themes[ChooseTheme.currentTheme]!
                              .colorScheme
                              .background,
                        )),
                  ],
                )),
            Text(translate('myBusiness'),
                style: themes[ChooseTheme.currentTheme]!
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 20)),
            SizedBox(
              height: currentHeight * .04,
            ),
            CustomContainer(
                color: themes[ChooseTheme.currentTheme]!.colorScheme.surface,
                raduis: 10,
                image: null,
                width: currentWidth * .8,
                height: currentHeight * .3,
                child: Center(
                    child: Text(translate('updates'),
                        style: themes[ChooseTheme.currentTheme]!
                            .textTheme
                            .titleLarge!
                            .copyWith(fontSize: 16)))),
            SizedBox(
              height: 15,
            ),
            Container(
              height: 8,
              decoration:
                  BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
            ),
            SizedBox(
              height: currentHeight * .04,
            ),
          ],
        ),
      ),
    );
  }
}
