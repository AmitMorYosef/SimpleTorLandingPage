import 'dart:io';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:management_system_app/providers/settings_provider.dart';
import 'package:management_system_app/providers/user_provider.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/ui/general_widgets/native_options_bottom_sheet.dart';
import 'package:management_system_app/ui/general_widgets/pickers/gender_picker.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/application_general.dart';
import '../../../../app_const/gender.dart';
import '../../../../app_const/platform.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../app_statics.dart/worker_data.dart';
import '../../../../providers/worker_provider.dart';
import '../../../../utlis/general_utlis.dart';
import '../../../../utlis/image_utlis.dart';
import '../../../../utlis/validations_utlis.dart';
import '../../../general_widgets/custom_widgets/custom_text_form_field.dart';

// ignore: must_be_immutable
class Profile extends StatelessWidget {
  final bool? showEdit;
  final bool? editWhenTap;
  double? raduis;
  Profile({Key? key, this.showEdit, this.editWhenTap, this.raduis})
      : super(key: key);
  late WorkerProvider workerProvider;

  late UserProvider userProvider;

  late SettingsProvider settingsProvider;

  TextEditingController nameController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  late CustomTextFormField nameFormField;

  XFile? image = null;

  @override
  Widget build(BuildContext context) {
    this.raduis = this.raduis ?? gHeight * 0.1;
    workerProvider = context.watch<WorkerProvider>();
    userProvider = context.watch<UserProvider>();

    settingsProvider = context.read<SettingsProvider>();
    nameFormField = CustomTextFormField(
        context: context,
        hintText: translate("name"),
        isValid: nameValidation,
        typeInput: TextInputType.text,
        contentController: nameController);

    return BouncingWidget(
      onPressed: () async {
        if (this.editWhenTap == true) {
          await editProfile(context);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          showCircleCachedImage(
              UserData.getPermission() > 0 ? WorkerData.worker.profileImg : '',
              this.raduis ?? gHeight * 0.1,
              UserData.user.gender == Gender.female
                  ? defaultWomanImage
                  : defaultManImage),
          SizedBox(
            height: raduis! * 0.2,
          ),
          Text(
            UserData.user.name == "guest"
                ? translate("guest")
                : UserData.user.name,
            style: TextStyle(fontSize: raduis! * 0.23),
          ),
          (UserData.isConnected() && this.showEdit != false)
              ? CustomContainer(
                  width: 87,
                  height: 32,
                  padding: EdgeInsets.only(top: this.raduis! * 0.2),
                  alignment: Alignment.center,
                  onTap: () async => await editProfile(context),
                  child: Text(translate("edit")),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  Future<void> editProfile(BuildContext context) async {
    if (!await isNetworkConnected()) {
      notNetworkConnectedToast(context);
      return;
    }
    nameController.text = UserData.user.name;
    await getUpdatedFields(context);
  }

  Future<void> getUpdatedFields(BuildContext context) {
    GenderPicker.selectedGender = UserData.user.gender;
    return genralDialog(
      context: context,
      title: translate("detailsUpdate"),
      content: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            circleImage(context),
            UserData.getPermission() > 0 && WorkerData.worker.profileImg != ''
                ? deleteButton(context)
                : SizedBox(
                    height: 40,
                  ),
            nameFormField,
            SizedBox(
              height: 20,
            ),
            UserData.isConnected()
                ? GenderPicker(
                    radius: 40,
                  )
                : SizedBox()
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'Cancel');
          },
          child: Text(translate("cancel")),
        ),
        TextButton(
          onPressed: () {
            if (!nameFormField.contentValid) return;
            Navigator.pop(context, 'OK');
            if (UserData.user.name != nameController.text ||
                (UserData.getPermission() > 0 && this.image != null) ||
                UserData.user.gender != GenderPicker.selectedGender) {
              if (UserData.getPermission() == 0) {
                Loading(
                        navigator: Navigator.of(context),
                        msg: translate("yourDetailsUpdateSuccess"),
                        animation: successAnimation,
                        context: context,
                        future: updateUserProvider(context))
                    .dialog();
              } else {
                Loading(
                        navigator: Navigator.of(context),
                        msg: translate("yourDetailsUpdateSuccess"),
                        context: context,
                        animation: successAnimation,
                        future: updateWorkerProvider(context))
                    .dialog();
                ;
              }
            }
          },
          child: Text(translate("save")),
        ),
      ],
    );
  }

  Widget deleteButton(BuildContext context) {
    return IconButton(
        onPressed: () async {
          String resp = await genralDialog(
              context: context,
              title: translate("deleting"),
              content: Text(
                translate("removeProfileImage"),
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'CANCEL');
                  },
                  child: Text(translate("no")),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'DELETE');
                  },
                  child: Text(translate("yes")),
                )
              ]);
          if (resp == 'DELETE') {
            await Loading(
                    timeOutDuration: Duration(seconds: 10),
                    navigator: Navigator.of(context),
                    msg: translate("yourImageRemoveSuccess"),
                    animation: successAnimation,
                    context: context,
                    future: workerProvider.deleteWorkerImage())
                .dialog();
            Navigator.pop(context);
          }
        },
        icon: Icon(Icons.delete));
  }

  Widget circleImage(BuildContext context) {
    return UserData.getPermission() > 0
        ? GestureDetector(
            onTap: () async {
              if (isWeb) {
                webAccessToImageToast(context);
                return;
              } else {
                List<BottomSheetActionDetails> options = [
                  BottomSheetActionDetails(
                      title: Text(
                        translate("takePhoto"),
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.normal),
                      ),
                      onPressed: (_) async {
                        var status = await Permission.camera.status;
                        if (status.isPermanentlyDenied) {
                          await genralDialog(
                              context: context,
                              title: translate("noPemission"),
                              content: Text(
                                translate("needToAllowCameraInSettings"),
                                textAlign: TextAlign.center,
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(translate("ok")))
                              ]);
                          Navigator.pop(context);
                        } else {
                          Navigator.pop(context, ImageSource.camera);
                        }
                      }),
                  BottomSheetActionDetails(
                      title: Text(
                        translate("gallery"),
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.normal),
                      ),
                      onPressed: (_) async {
                        var status = await Permission.photos.status;
                        if (status.isPermanentlyDenied) {
                          await genralDialog(
                              context: context,
                              title: translate("noPemission"),
                              content: Text(
                                translate("needToAllowImagesInSettings"),
                                textAlign: TextAlign.center,
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(translate("ok")))
                              ]);
                          Navigator.pop(context);
                        } else {
                          Navigator.pop(context, ImageSource.gallery);
                        }
                      })
                ];
                dynamic src = await showNativeOptionsBottomSheet(
                    context,
                    Text(translate("pickSurce"),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontSize: 14)),
                    options);
                if (!(src is ImageSource)) {
                  return;
                }
                this.image = await _picker.pickImage(source: src);
                // this.image =
                //     await _picker.pickImage(source: ImageSource.gallery);
                this.image =
                    await cropImage(this.image, CropStyle.circle, context);
                // pop current dialog
                Navigator.pop(context);
                // push current dialog with the imag
                getUpdatedFields(context);
              }
            },
            child: Stack(
              children: [
                this.image == null
                    ? showCircleCachedImage(
                        WorkerData.worker.profileImg,
                        85,
                        UserData.user.gender == Gender.female
                            ? defaultWomanImage
                            : defaultManImage)
                    : SizedBox(
                        height: 85,
                        width: 85,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(90)),
                          child: Image.file(
                            File(this.image!.path),
                            fit: BoxFit.cover,
                          ),
                        )),
                CircleAvatar(
                  radius: 43,
                  backgroundColor: Colors.grey.withOpacity(0.6),
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        : SizedBox();
  }

  Future<bool> updateWorkerProvider(BuildContext context) async {
    bool resp = true;
    await workerProvider.updateWokerImage(context, image);
    if (GenderPicker.selectedGender != UserData.user.gender)
      resp = resp && await userProvider.setGender(GenderPicker.selectedGender);
    resp = resp && await userProvider.setName(nameController.text, context);
    UiManager.insertUpdate(Providers.worker);
    return resp;
  }

  Future<bool> updateUserProvider(BuildContext context) async {
    bool resp = true;
    if (GenderPicker.selectedGender != UserData.user.gender)
      resp = resp && await userProvider.setGender(GenderPicker.selectedGender);
    resp = resp && await userProvider.setName(nameController.text, context);
    UiManager.insertUpdate(Providers.user);
    return resp;
  }
}
