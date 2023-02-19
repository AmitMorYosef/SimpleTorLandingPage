import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:management_system_app/models/worker_model.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/gender.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../utlis/image_utlis.dart';
import '../../../animations/hero_dialog.dart';
import '../../../animations/like_animation.dart';
import '../../../general_widgets/dialogs/genral_dialog.dart';

class StoryDialog {
  String workerPhone;
  Map<String, CachedNetworkImage> images;
  int index;
  double width = min(storyImagesWidth * 1.5, gWidth * 1.9);
  double height = storyImagesHeigth * 1.5;
  Map<int, WorkerModel> workerByIndex;
  BuildContext ancestorContext;
  final bool editMode;

  StoryDialog(
      {required this.images,
      required this.workerPhone,
      required this.index,
      required this.workerByIndex,
      required this.ancestorContext,
      this.editMode = false});

  Future<dynamic> showDialog() {
    return Navigator.push(
      ancestorContext,
      new HeroDialogRoute(
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            content: Container(
              child: Hero(
                tag: images.keys.elementAt(index),
                child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Container(
                    height: height,
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      child: PinchZoom(
                          resetDuration: const Duration(milliseconds: 100),
                          maxScale: 3,
                          onZoomStart: () {},
                          onZoomEnd: () {},
                          child: ImageCard(
                            ancestorContext: ancestorContext,
                            images: images,
                            width: width,
                            height: height,
                            workerByIndex: workerByIndex,
                            initialIndex: index,
                            editMode: editMode,
                          )),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ImageCard extends StatefulWidget {
  final Map<String, CachedNetworkImage> images;
  final BuildContext ancestorContext;
  final Map<int, WorkerModel> workerByIndex;
  final int initialIndex;
  final double width, height;
  final bool editMode;
  ImageCard(
      {super.key,
      required this.width,
      required this.height,
      required this.ancestorContext,
      required this.workerByIndex,
      required this.images,
      required this.initialIndex,
      this.editMode = false});

  @override
  State<ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  int imageIndex = 0;
  WorkerModel? worker;
  String imageId = "";
  List<Widget> imagesWidgets = [];
  late PageController controller;
  @override
  void initState() {
    widget.images.forEach((id, image) {
      imagesWidgets.add(Container(
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(0)),
            child: widget.images[id]!),
      ));
    });
    controller = PageController(initialPage: widget.initialIndex);
    super.initState();
    imageIndex = widget.initialIndex;
    imageId = widget.images.keys.elementAt(imageIndex);
    worker = widget.workerByIndex[imageIndex];
  }

  @override
  Widget build(BuildContext context) {
    final alreadyLiked = UserData.user.storyLikes.contains(imageId);
    LikeAniamtion likeWidget = LikeAniamtion(
      workerPhone: worker!.phone,
      imageId: imageId,
      key: UniqueKey(),
      alreadyLiked: alreadyLiked,
      likesAmount:
          SettingsData.workers[worker!.phone]!.storylikesAmount[imageId] ?? 0,
    );

    return Stack(
      children: [
        GestureDetector(
            onDoubleTap: () {
              if (likeWidget.clickLike != null) {
                likeWidget.clickLike!();
              }
            },
            child: PageView(
              children: imagesWidgets,
              controller: controller,
              onPageChanged: (index) {
                Map<String, String> likesToLoad = {};
                if (index + 1 < widget.workerByIndex.length) {
                  likesToLoad[widget.images.keys.elementAt(index + 1)] =
                      widget.workerByIndex[index + 1]!.phone;
                }
                if (index - 1 >= 0) {
                  likesToLoad[widget.images.keys.elementAt(index - 1)] =
                      widget.workerByIndex[index - 1]!.phone;
                }

                SettingsData.loadLikes(likesToLoad);
                setState(() {
                  imageIndex = index;
                  imageId = widget.images.keys.elementAt(index);
                  worker = widget.workerByIndex[index];
                });
              },
            )),
        Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (imageIndex != 0) {
                      controller.animateToPage(imageIndex - 1,
                          duration: Duration(milliseconds: 200),
                          curve: Curves.linear);
                    }
                  },
                  child: Opacity(
                      opacity: imageIndex == 0 ? 0.5 : 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 14),
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 17,
                        ),
                      ))),
              GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (imageIndex != widget.images.length - 1) {
                      controller.animateToPage(imageIndex + 1,
                          duration: Duration(milliseconds: 200),
                          curve: Curves.linear);
                    }
                  },
                  child: Opacity(
                      opacity: imageIndex == widget.images.length - 1 ? 0.5 : 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 14),
                        child: Icon(Icons.arrow_forward_ios, size: 17),
                      ))),
            ],
          ),
        )),
        Positioned(right: 15, bottom: 15, child: likeWidget),
        workerPhoto(),
        widget.editMode ? deleteButton() : SizedBox()
      ],
    );
  }

  Widget workerPhoto() {
    return worker != null
        ? Positioned(
            bottom: 15,
            left: 15,
            child: showCircleCachedImage(
                worker!.profileImg,
                40,
                worker!.gender == Gender.female
                    ? defaultWomanImage
                    : defaultManImage),
          )
        : SizedBox();
  }

  Widget deleteButton() {
    return UserData.getPermission() == 2 ||
            UserData.user.phoneNumber == worker!.phone
        ? Positioned(
            left: 15,
            top: 15,
            child: GestureDetector(
              onTap: () async {
                if (await deleteDialog(context, widget.images[imageId]!) ==
                    "OK") {
                  Navigator.pop(context);
                  await Loading(
                          context: widget.ancestorContext,
                          navigator: Navigator.of(widget.ancestorContext),
                          future:
                              context.read<SettingsProvider>().deleteStoryImage(
                                    widget.ancestorContext,
                                    worker!.phone,
                                    imageId,
                                    widget.images[imageId]!.imageUrl,
                                  ),
                          animation: deleteAnimation,
                          msg: translate("deletedImage"))
                      .dialog();
                }
              },
              child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.background),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Center(child: Icon(Icons.delete)),
                  )),
            ))
        : SizedBox();
  }

  Future<String> deleteDialog(
      BuildContext context, CachedNetworkImage image) async {
    return await genralDialog(
      context: context,
      title: translate("deleteImage"),
      content: SizedBox(
          height: gHeight * 0.3,
          child: Column(
            children: [
              Text(
                translate('confirmDeleteImage'),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: SizedBox(
                      height: gHeight * 0.2, width: gWidth * 0.2, child: image))
            ],
          )),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: Text(translate('cancel')),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'OK');
          },
          child: Text(translate('delete')),
        ),
      ],
    );
  }
}
