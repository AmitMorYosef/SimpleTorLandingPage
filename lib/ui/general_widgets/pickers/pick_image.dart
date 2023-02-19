import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/utlis/image_utlis.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app_const/app_sizes.dart';
import '../../../app_const/platform.dart';
import '../../../utlis/general_utlis.dart';

class PickImage extends StatefulWidget {
  final String imageUrl;
  static bool imageDeleted = false;
  static XFile? image;
  const PickImage({super.key, required this.imageUrl});

  @override
  State<PickImage> createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  String? imageUrl;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    imageUrl = widget.imageUrl;
    PickImage.image = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: productHeight,
      width: productWidth,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
      alignment: Alignment.center,
      child: Stack(
        children: [
          imageWidget(),
          imageUrl != null || PickImage.image != null
              ? Container(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    height: 30,
                    width: 30,
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.all(Radius.circular(999))),
                    child: GestureDetector(
                      child: Icon(Icons.delete),
                      onTap: () {
                        imageUrl = null;
                        PickImage.image = null;
                        PickImage.imageDeleted = true;
                        updateScreen();
                      },
                    ),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }

  Widget imageWidget() {
    if (imageUrl != null) return initialImage();
    if (PickImage.image != null) return updatedImage();
    return emptyImage();
  }

  Widget initialImage() {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: CachedNetworkImage(
        height: productHeight,
        width: productWidth,
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget emptyImage() {
    return DottedBorder(
        dashPattern: [25],
        strokeWidth: 3,
        color: Colors.grey.withOpacity(0.5),
        borderType: BorderType.RRect,
        radius: Radius.circular(20),
        child: Container(
            width: productHeight,
            height: productWidth,
            child: pickImage(context)));
  }

  Widget updatedImage() {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: Image.file(
        File(PickImage.image!.path),
        fit: BoxFit.cover,
        width: productWidth,
        height: productHeight,
      ),
    );
  }

  void updateScreen() {
    setState(() {});
  }

  Widget pickImage(BuildContext context) {
    return GestureDetector(
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
          }

          PickImage.image = await _picker.pickImage(
            imageQuality: 100,
            source: ImageSource.gallery,
          );
          PickImage.image = await cropImage(
            PickImage.image,
            CropStyle.rectangle,
            context,
            height: 1024,
            width: 1024,
            loacRatio: true,
            aspectRatio: CropAspectRatio(
                ratioX: productImageRatioX / productImageRatioY, ratioY: 1),
          );
          setState(() {});
          return;
        }
      },
      child: Container(
        alignment: Alignment.center,
        height: productHeight,
        width: productWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                size: 30,
              ),
              Text(
                translate('addImage'),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 17),
              )
            ],
          ),
        ),
      ),
    );
  }
}
