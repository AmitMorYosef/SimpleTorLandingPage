import 'package:flutter/material.dart';
import 'package:management_system_app/utlis/image_utlis.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../general_widgets/pickers/pick_circle_image.dart';

class BusinessIcon extends StatelessWidget {
  final double? width;
  final double? height;
  BusinessIcon({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: false,
        child: SizedBox(
          height: height ?? gHeight * 0.07,
          width: width ?? gWidth * 0.07,
          child: PickCircleImage(
              showDelete: false,
              showEdit: false,
              enableCircleEdit: false,
              needLoad: false,
              radius: height ?? gHeight * 0.07,
              currentImage: showCircleCachedImage(
                  SettingsData.settings.shopIconUrl,
                  width ?? gWidth * 0.07,
                  SettingsData.businessIcon!)),
        ));
  }
}
