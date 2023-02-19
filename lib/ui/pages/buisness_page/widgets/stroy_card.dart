import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:management_system_app/ui/pages/buisness_page/widgets/story.dart';
import 'package:management_system_app/ui/pages/buisness_page/widgets/story_dialog.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/gender.dart';
import '../../../../app_const/platform.dart';
import '../../../../app_const/purchases.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../models/worker_model.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../utlis/general_utlis.dart';
import '../../../../utlis/image_utlis.dart';
import '../../../general_widgets/custom_widgets/custom_toast.dart';
import '../../../general_widgets/dialogs/genral_dialog.dart';
import '../../../general_widgets/loading_widgets/loading_dialog.dart';
import '../../../helpers/fonts_helper.dart';

class StoryCard extends StatefulWidget {
  final Map<String, CachedNetworkImage> images;
  final String? workerPhone, imageId;
  final int index;
  final Map<int, WorkerModel> workerByIndex;
  final bool editMode;
  final double ratio;

  StoryCard(
      {super.key,
      required this.images,
      required this.imageId,
      required this.workerByIndex,
      required this.index,
      required this.workerPhone,
      required this.editMode,
      this.ratio = 1});

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  @override
  Widget build(BuildContext context) {
    final worker = SettingsData.workers[widget.workerPhone] ?? null;

    return widget.images[widget.imageId] == null
        ? addPhotoSpace()
        : Padding(
            padding: EdgeInsets.all(15.0),
            child: Hero(
              tag: widget.imageId!,
              child: GestureDetector(
                onTap: () {
                  Map<String, String> likesToLoad = {};
                  /*load likes for the pressed image and for the previous 
                    and next images*/
                  likesToLoad[widget.images.keys.elementAt(widget.index)] =
                      widget.workerByIndex[widget.index]!.phone;

                  if (widget.index + 1 < widget.workerByIndex.length) {
                    likesToLoad[
                            widget.images.keys.elementAt(widget.index + 1)] =
                        widget.workerByIndex[widget.index + 1]!.phone;
                  }

                  if (widget.index - 1 >= 0) {
                    likesToLoad[
                            widget.images.keys.elementAt(widget.index - 1)] =
                        widget.workerByIndex[widget.index - 1]!.phone;
                  }

                  SettingsData.loadLikes(likesToLoad);
                  StoryDialog(
                          images: widget.images,
                          workerPhone: widget.workerPhone!,
                          workerByIndex: widget.workerByIndex,
                          index: widget.index,
                          editMode: widget.editMode,
                          ancestorContext: context)
                      .showDialog();
                },
                child: ClipRRect(
                    borderRadius:
                        BorderRadius.all(Radius.circular(20 * widget.ratio)),
                    child: Stack(children: [
                      Container(
                        width: storyImagesWidth * widget.ratio,
                        child: widget.images[widget.imageId]!,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(20 * widget.ratio)),
                        ),
                      ),
                      worker != null
                          ? Positioned(
                              bottom: 15,
                              left: 15,
                              child: showCircleCachedImage(
                                  worker.profileImg,
                                  40,
                                  worker.gender == Gender.female
                                      ? defaultWomanImage
                                      : defaultManImage),
                            )
                          : SizedBox(),
                      widget.editMode &&
                              (UserData.getPermission() == 2 ||
                                  widget.workerPhone! ==
                                      UserData.user.phoneNumber)
                          ? Positioned(
                              top: 5,
                              left: 5,
                              child: Material(
                                color: Colors.transparent,
                                child: Checkbox(
                                  shape: CircleBorder(),
                                  value: Story.imagesToDelete
                                      .containsKey(widget.imageId),
                                  activeColor:
                                      Theme.of(context).colorScheme.secondary,
                                  onChanged: (value) {
                                    if (value != null &&
                                        widget.imageId != null &&
                                        widget.workerPhone != null) {
                                      setState(() {
                                        value
                                            ? Story.imagesToDelete[
                                                widget.imageId!] = {
                                                "workerPhone":
                                                    widget.workerPhone!,
                                                "imageUrl": widget
                                                    .images[widget.imageId]!
                                                    .imageUrl
                                              }
                                            : Story.imagesToDelete
                                                .remove(widget.imageId);
                                      });
                                      StoryDeleteButton.onChanged!();
                                    }
                                  },
                                ),
                              ))
                          : SizedBox()
                    ])),
              ),
            ),
          );
  }

  Widget addPhotoSpace() {
    if (!widget.editMode) {
      return SizedBox();
    }
    int storyPhotosCurrentLimit =
        SettingsData.settings.limits[BuisnessLimitations.storyPhotos]!;
    SettingsData.storyCacheImages.forEach(
        (workerPhone, images) => storyPhotosCurrentLimit -= images.length);
    return (UserData.getPermission() < 1 || storyPhotosCurrentLimit <= 0)
        ? SizedBox()
        : Padding(
            padding: EdgeInsets.all(15.0),
            child: GestureDetector(
              onTap: () async {
                if (isWeb) {
                  webAccessToImageToast(context);
                  return;
                }
                if (!await isNetworkConnected()) {
                  notNetworkConnectedToast(context);
                  return;
                }
                if (!SettingsData.activeBusiness) {
                  expiredSubToast(context);
                  return;
                }
                var status = await Permission.photos.status;
                if (status.isPermanentlyDenied) {
                  genralDialog(
                      context: context,
                      title: translate('premissionDenide'),
                      content: Text(
                        translate('needToAllowImagesInSettings'),
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(translate('ok')))
                      ]);
                } else
                  uploadPhotos();
              },
              child: DottedBorder(
                dashPattern: [25],
                strokeWidth: 2,
                color: Colors.grey.withOpacity(0.5),
                borderType: BorderType.RRect,
                radius: Radius.circular(20),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    height: storyImagesHeigth * widget.ratio,
                    width: storyImagesWidth * widget.ratio,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              size: 60,
                            ),
                            Text(
                              translate('pichStoryDetails') +
                                  "\n(${translate('maximum')} ${storyPhotosCurrentLimit.toString()} ${translate('images')})",
                              textAlign: TextAlign.center,
                              style: FontsHelper().businessStyle(
                                  currentStyle:
                                      Theme.of(context).textTheme.titleLarge),
                            )
                          ],
                        ),
                      ),
                    )),
              ),
            ));
  }

  Future<void> uploadPhotos() async {
    final storyPhotosLimit =
        SettingsData.settings.limits[BuisnessLimitations.storyPhotos]!;
    int storyAmount = 0;
    SettingsData.storyCacheImages
        .forEach((workerPhone, images) => storyAmount += images.length);
    if (storyAmount >= storyPhotosLimit) {
      CustomToast(
        context: context,
        msg: "${translate('storyCrossLimit')} - $storyPhotosLimit",
        gravity: ToastGravity.BOTTOM,
      ).init();
      return;
    }
    final ImagePicker _picker = ImagePicker();
    List<XFile> images = await _picker.pickMultiImage(
        maxHeight: 1024, maxWidth: 1024, imageQuality: 100);
    List<XFile> cropImages = [];
    if (storyAmount + images.length > storyPhotosLimit) {
      CustomToast(
        context: context,
        msg: "${translate('storyCrossLimit')} - $storyPhotosLimit",
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
              ratioX: 1, ratioY: storyImagesRatioY / storyImagesRatioX));
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
            future: context
                .read<SettingsProvider>()
                .uploadStoryImages(context, images, UserData.user.phoneNumber),
            animation: successAnimation,
            msg: images.length == 1
                ? translate('successfullyUploadedImage')
                : translate('successfullyUploadedImages'))
        .dialog();
  }
}
