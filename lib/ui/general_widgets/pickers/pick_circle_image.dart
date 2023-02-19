import 'dart:io';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/utlis/general_utlis.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app_const/platform.dart';
import '../../../app_statics.dart/settings_data.dart';
import '../../../utlis/image_utlis.dart';
import '../../../utlis/string_utlis.dart';

// ignore: must_be_immutable
class PickCircleImage extends StatefulWidget {
  PickCircleImage(
      {super.key,
      this.upload,
      this.delete,
      this.currentImage,
      this.radius,
      this.needLoad = true,
      this.showDelete = true,
      this.showEdit = true,
      this.enableCircleEdit = false,
      this.cleanLastImage = true});
  static XFile? imageForBusiness = null;
  final Future<dynamic> Function(BuildContext context)? upload;
  final Future<dynamic> Function(BuildContext context)? delete;
  final bool needLoad;
  final bool showDelete;
  final bool showEdit;
  final double? radius;
  final bool enableCircleEdit;
  final bool cleanLastImage;
  Widget? currentImage;

  @override
  State<PickCircleImage> createState() => _PickCircleImageState();
}

class _PickCircleImageState extends State<PickCircleImage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.cleanLastImage) {
      PickCircleImage.imageForBusiness = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      PickCircleImage.imageForBusiness != null
          ? selectedImageIcon()
          : BouncingWidget(
              scaleFactor: 0.5,
              onPressed: () async {
                if (!widget.enableCircleEdit) {
                  return;
                }

                if (!widget.needLoad) return;

                await upload();
              },
              child: Stack(
                fit: StackFit.loose,
                children: [
                  widget.currentImage ?? emptyIcon(),
                  editModeIndicator()
                ],
              )),
      editButton(context)
    ]);
  }

  Widget editModeIndicator() {
    return Visibility(
      visible: widget.enableCircleEdit,
      child: CircleAvatar(
        radius: (widget.radius ?? 85) * 0.5,
        backgroundColor: Colors.grey.withOpacity(0.6),
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 15,
        ),
      ),
    );
  }

  Widget emptyIcon() {
    return showCircleCachedImage(
        '', widget.radius ?? 85, SettingsData.businessIcon!);
  }

  Widget selectedImageIcon() {
    return GestureDetector(
      onTap: () async {
        if (!widget.needLoad) return;
        await upload();
      },
      child: SizedBox(
          height: widget.radius ?? 85,
          width: widget.radius ?? 85,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(90)),
            child: Image.file(
              File(PickCircleImage.imageForBusiness!.path),
              fit: BoxFit.cover,
            ),
          )),
    );
  }

  Widget editButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widget.showEdit
            ? IconButton(
                onPressed: () async => await upload(), icon: Icon(Icons.edit))
            : SizedBox(),
        widget.showDelete &&
                (PickCircleImage.imageForBusiness != null ||
                    widget.currentImage != null)
            ? IconButton(
                onPressed: () async {
                  if (isWeb) {
                    webAccessToImageToast(context);
                    return;
                  }
                  if (widget.delete != null) {
                    widget.currentImage = null;
                    await widget.delete!(context).then((value) {
                      if (value == true) {
                        PickCircleImage.imageForBusiness = null;
                        updateScreen();
                      }
                    });
                  } else {
                    PickCircleImage.imageForBusiness = null;
                    updateScreen();
                  }
                },
                icon: Icon(Icons.delete))
            : SizedBox(),
      ],
    );
  }

  Future<void> upload() async {
    if (isWeb) {
      webAccessToImageToast(context);
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
    } else {
      PickCircleImage.imageForBusiness =
          await _picker.pickImage(source: ImageSource.gallery);
      PickCircleImage.imageForBusiness = await cropImage(
          PickCircleImage.imageForBusiness, CropStyle.circle, context);
      if (PickCircleImage.imageForBusiness != null) {
        if (widget.upload != null) await widget.upload!(context);
        updateScreen();
      }
    }
  }

  void updateScreen() => setState(() {});
}
