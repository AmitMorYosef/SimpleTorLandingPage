import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

import '../app_const/resources.dart';
import '../app_statics.dart/settings_data.dart';
import '../ui/general_widgets/dialogs/general_delete_dialog.dart';
import '../ui/general_widgets/loading_widgets/loading_dialog.dart';
import '../ui/general_widgets/pickers/pick_circle_image.dart';

Future<XFile?> cropImage(
    XFile? image, CropStyle cropStyle, BuildContext context,
    {CropAspectRatio? aspectRatio,
    bool loacRatio = false,
    int height = 512,
    int width = 512}) async {
  if (image == null) return null;
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    maxHeight: height,
    maxWidth: width,
    aspectRatio: aspectRatio,
    sourcePath: image.path,
    cropStyle: cropStyle,
    uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Edit',
          toolbarColor: Theme.of(context).colorScheme.secondary,
          hideBottomControls: true,
          lockAspectRatio: loacRatio),
      IOSUiSettings(
          title: 'Edit',
          showCancelConfirmationDialog: true,
          hidesNavigationBar: true,
          aspectRatioLockEnabled: loacRatio),
    ],
  );
  if (croppedFile == null) return null;
  return XFile(croppedFile.path);
}

Widget showCircleCachedImage(
    String imageUrl, double radius, String defaultImage) {
  return SizedBox(
    height: radius,
    width: radius,
    child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(500)),
        child: imageUrl.isEmpty
            ? Image.asset(
                defaultImage,
                width: radius,
                height: radius,
              )
            : CachedNetworkImage(
                cacheManager: SettingsData.businessCacheManager,
                fit: BoxFit.cover,
                imageUrl: imageUrl,
                placeholder: (context, url) => Image.asset(
                  defaultImage,
                  fit: BoxFit.cover,
                ),
                errorWidget: (context, url, error) => Image.asset(
                  defaultImage,
                  fit: BoxFit.cover,
                ),
              )),
  );
}

Future<dynamic> uploadImage(BuildContext context) async {
  await Loading(
          context: context,
          navigator: Navigator.of(context),
          timeOutDuration: Duration(seconds: 7),
          future: Future(() async {
            return await SettingsData.updateShopIcon(
                PickCircleImage.imageForBusiness);
          }),
          animation: successAnimation,
          msg: translate('iconSuccessfullyChanged'))
      .dialog();
}

Future<bool> confirmDelete(BuildContext context) async {
  String? resp = await genralDeleteDialog(
    context: context,
    title: translate('delete'),
    content: Text(
      translate('cofirmDeleteProfileImage'),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium,
    ),
    onCancel: () => Navigator.pop(context, 'CANCEL'),
    onDelete: () => Navigator.pop(context, 'DELETE'),
  );
  if (resp == 'DELETE') {
    String iconUrl = SettingsData.settings.shopIconUrl;
    return await Loading(
            context: context,
            navigator: Navigator.of(context),
            timeOutDuration: Duration(seconds: 7),
            future: Future(() async {
              await SettingsData.businessCacheManager.removeFile(iconUrl);
              return await SettingsData.deleteShopIcon();
            }),
            animation: successAnimation,
            msg: translate('successfulltdeletedIcon'))
        .dialog();
  }
  return false;
}
