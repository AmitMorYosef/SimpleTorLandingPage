import 'dart:async';

import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:simple_tor_web/ui/pages/buisness_page/widgets/fade_widget.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/display.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/screens_data.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../app_statics.dart/theme_data.dart';
import '../../../../providers/settings_provider.dart';

class AnimatedImages extends StatefulWidget {
  final bool editMode;
  AnimatedImages({super.key, required this.editMode});
  @override
  AnimatedImagesState createState() => AnimatedImagesState();
}

class AnimatedImagesState extends State<AnimatedImages> {
  late Timer? _everySecond;
  late SettingsProvider settingsProvider;

  @override
  void dispose() {
    super.dispose();
    try {
      _everySecond!.cancel();
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();

    if (SettingsData.changingImages.isEmpty) return;
    // defines a timer
    _everySecond = Timer.periodic(
        Duration(seconds: SettingsData.settings.changingImagesSwapSeconds),
        (Timer t) {
      setState(() {
        if (ScreensData.changingPhotoIndex >=
            SettingsData.changingImages.length - 1) {
          ScreensData.changingPhotoIndex = 0;
        } else {
          ScreensData.changingPhotoIndex = ScreensData.changingPhotoIndex + 1;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 3), // prevent line on the fade
          width: gWidthOriginal,
          child: SettingsData.changingImages.isEmpty
              ? defaultImage()
              : changingImages(),
          color: Theme.of(context).colorScheme.background,
        ),
        Align(alignment: Alignment.bottomCenter, child: FadeWidget()),
      ],
    );
  }

  Widget defaultImage() {
    return Image.asset(
      AppThemeData.currentKeyTheme == Themes.dark
          ? defaultPhoto
          : defaultPhotoLight,
      width: gWidthOriginal * 2,
      height: changingImagesHeight * 2,
      fit: BoxFit.cover,
    );
  }

  Widget changingImages() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 1000),
      child: SettingsData.changingImages[ScreensData.changingPhotoIndex],
    );
  }
}
