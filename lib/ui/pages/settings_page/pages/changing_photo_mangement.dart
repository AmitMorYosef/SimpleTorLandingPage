import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/ui/general_widgets/pickers/duration_picker.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/platform.dart';
import '../../../../app_const/purchases.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_const/times.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../providers/manager_provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../utlis/general_utlis.dart';
import '../../../../utlis/image_utlis.dart';
import '../../../general_widgets/buttons/info_button.dart';
import '../../../general_widgets/custom_widgets/custom_toast.dart';
import '../../../general_widgets/dialogs/general_delete_dialog.dart';

// ignore: must_be_immutable
class ChangingPhotoMangement extends StatelessWidget {
  ChangingPhotoMangement({super.key});
  late SettingsProvider settingsProvider;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  ManagerProvider managerProvider = ManagerProvider();
  final changingPhotosLimit =
      SettingsData.settings.limits[BuisnessLimitations.changingPhotos]!;
  double width = gWidth * 0.9;
  double height = gWidth * 0.9 / 1.5;

  @override
  Widget build(BuildContext context) {
    DurationPicker durationPicker = DurationPicker(initData: {
      TimeUnit.day: 0,
      TimeUnit.hour: 0,
      TimeUnit.minute: 0,
      TimeUnit.seconds: SettingsData.settings.changingImagesSwapSeconds
    });
    settingsProvider = context.watch<SettingsProvider>();
    int addContainer =
        changingPhotosLimit <= SettingsData.changingImages.length ? 0 : 1;
    return Scaffold(
      appBar: AppBar(
        actions: [
          infoButton(
              context: context, text: translate('hereYouManageBusinessUpdates'))
        ],
        elevation: 0,
        title: Text(translate('changingImages')),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                width: gWidthOriginal * .9,
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount:
                        SettingsData.changingImages.length + addContainer,
                    itemBuilder: ((context, index) {
                      final image = index == SettingsData.changingImages.length
                          ? addArea(context)
                          : SettingsData.changingImages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Column(
                          children: [
                            ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                child: Container(
                                  height: changingImagesHeight * .9,
                                  width: gWidthOriginal * .9,
                                  child: image,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                )),
                            index == SettingsData.changingImages.length
                                ? SizedBox()
                                : IconButton(
                                    onPressed: () async {
                                      bool? resp = await showMakeSureDialog(
                                          context,
                                          SettingsData.changingImages[index]);
                                      if (resp == true) {
                                        await Loading(
                                                context: context,
                                                navigator:
                                                    Navigator.of(context),
                                                future: settingsProvider
                                                    .deleteChangingImage(
                                                        context,
                                                        SettingsData
                                                            .changingImages[
                                                                index]
                                                            .imageUrl),
                                                animation: deleteAnimation,
                                                msg: translate("deletedImage"))
                                            .dialog();
                                      }
                                    },
                                    icon: Icon(Icons.delete))
                          ],
                        ),
                      );
                    })),
              ),
            ),
            CustomContainer(
                onTap: () async {
                  bool? resp = await showSecondsDialog(context, durationPicker);
                  if (resp == true) {
                    SettingsData.changeChangingImagesSwapSeconds(
                        durationPicker.data[TimeUnit.seconds]!, context);
                  }
                },
                margin: EdgeInsets.only(bottom: 20, top: 20),
                color: Theme.of(context).colorScheme.secondary,
                padding: EdgeInsets.all(8),
                child: Text(
                    translate("imagesChangingEvrey") +
                        SettingsData.settings.changingImagesSwapSeconds
                            .toString() +
                        " " +
                        translate("seconds"),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontSize: 17))),
            SettingsData.limitionPassed
                    .contains(BuisnessLimitations.changingPhotos)
                ? Container(
                    margin: EdgeInsets.only(bottom: 20),
                    width: gWidth * 0.7,
                    child: Text(
                      translate("youPassedChangingImagesLimit") +
                          (subsLevels[SettingsData.businessSubtype] == 1
                              ? ""
                              : " " + translate("orChangePlan")),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Colors.red),
                    ),
                  )
                : SizedBox(),
            SettingsData.limitionPassed
                    .contains(BuisnessLimitations.changingPhotos)
                ? Container(
                    margin: EdgeInsets.only(bottom: 20),
                    width: gWidth * 0.7,
                    child: Text(
                      translate("theLimit") +
                          ": " +
                          SettingsData.settings
                              .limits[BuisnessLimitations.changingPhotos]!
                              .toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Colors.red),
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Future<bool?> showSecondsDialog(
      BuildContext context, DurationPicker durationPicker) async {
    return await genralDialog(
      animationType: DialogTransitionType.slideFromBottomFade,
      context: context,
      content: durationPicker.pickerWidgetSeconds(context, 3),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(translate('cancel')),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text(translate('save')),
        ),
      ],
    );
  }

  Widget addArea(BuildContext context) {
    return changingPhotosLimit == SettingsData.changingImages.length
        ? SizedBox()
        : GestureDetector(
            onTap: () async {
              if (isWeb) {
                webAccessToImageToast(context);
                return;
              } else {
                var status = await Permission.photos.status;
                if (status.isPermanentlyDenied) {
                  genralDialog(
                      context: context,
                      title: translate('noPemission'),
                      content: Text(
                        translate('needToAllowImagesInSettings'),
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(translate('ok')))
                      ]);
                } else {
                  await uploadPhoto(context);
                }
              }
            },
            child: DottedBorder(
              dashPattern: [25],
              strokeWidth: 3,
              color: Colors.grey.withOpacity(0.5),
              borderType: BorderType.RRect,
              radius: Radius.circular(20),
              child: Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 60),
                        Text(
                          translate('preferableHorizintalImage') +
                              "\n(${translate('maximum')} ${changingPhotosLimit - SettingsData.changingImages.length} ${translate('images')})",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Future<void> uploadPhoto(BuildContext context) async {
    if (SettingsData.changingImages.length >= changingPhotosLimit) {
      CustomToast(
        context: context,
        msg: translate('youCantGoUpMore') +
            " " +
            changingPhotosLimit.toString() +
            " " +
            translate('changingImages'),
        gravity: ToastGravity.BOTTOM,
      ).init();
      return;
    }
    final ImagePicker _picker = ImagePicker();
    List<XFile> images = await _picker.pickMultiImage(
        maxHeight: 1024, maxWidth: 1024, imageQuality: 100);
    List<XFile> cropImages = [];
    if (images.isNotEmpty &&
        SettingsData.changingImages.length + images.length >
            changingPhotosLimit) {
      CustomToast(
        context: context,
        msg: translate('youCantGoUpMore') +
            " " +
            changingPhotosLimit.toString() +
            " " +
            translate('changingImages'),
        gravity: ToastGravity.BOTTOM,
      ).init();
      return;
    }
    for (var image in images) {
      XFile? crepped = await cropImage(image, CropStyle.rectangle, context,
          height: 1024,
          width: 1024,
          loacRatio: true,
          aspectRatio: CropAspectRatio(
              ratioX: 1, ratioY: changingImagesRatioY / changingImagesRatioX));
      if (crepped != null) cropImages.add(crepped);
    }
    images = cropImages;
    if (images.length == 0) {
      CustomToast(context: context, msg: translate("noPickedImages")).init();
      return;
    }
    await Loading(
            context: context,
            navigator: Navigator.of(context),
            future: settingsProvider.uploadChangingImages(context, images),
            animation: successAnimation,
            msg: images.length == 1
                ? translate('imageUpload')
                : translate('imagesUpload'))
        .dialog();
  }

  Future<bool?> showMakeSureDialog(
      BuildContext context, CachedNetworkImage image) async {
    return await genralDeleteDialog(
      context: context,
      title: translate('deleteImage'),
      content: SizedBox(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                translate('ensureDeleteImage'),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: SizedBox(
                      height: gHeight * 0.2, width: gWidth * 0.6, child: image))
            ],
          ),
        ),
      ),
      onCancel: () => Navigator.pop(context, false),
      onDelete: () => Navigator.pop(context, true),
    );
  }
}
