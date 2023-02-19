import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:management_system_app/providers/settings_provider.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_text_form_field.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_toast.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/utlis/general_utlis.dart';
import 'package:management_system_app/utlis/image_utlis.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:management_system_app/utlis/validations_utlis.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../../app_const/app_sizes.dart';
import '../../../../../app_const/platform.dart';
import '../../../../../app_const/purchases.dart';
import '../../../../../app_const/resources.dart';
import '../../../../../app_statics.dart/settings_data.dart';
import '../../../../general_widgets/pickers/price_picker.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  late SettingsProvider settingsProvider;
  final productsImagesLimit =
      SettingsData.settings.limits[BuisnessLimitations.products]!;
  XFile? image;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  PricePicker pricePicker = PricePicker();
  late CustomTextFormField title, description;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    titleController.addListener(() => showSave());
    descriptionController.addListener(() => showSave());
  }

  void showSave() {
    if (image != null && title.contentValid && description.contentValid != '')
      setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    title = CustomTextFormField(
        context: context,
        typeInput: TextInputType.text,
        isValid: productNameValidation,
        contentController: titleController,
        hintText: translate("productName"));
    description = CustomTextFormField(
        context: context,
        typeInput: TextInputType.text,
        isValid: productDecriptionValidation,
        contentController: descriptionController,
        hintText: translate("infoAboutProdutc"));
    settingsProvider = context.watch<SettingsProvider>();
    return Column(
      children: [
        DottedBorder(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          dashPattern: [25],
          strokeWidth: 3,
          color: Colors.grey.withOpacity(0.5),
          borderType: BorderType.RRect,
          radius: Radius.circular(20),
          child: SizedBox(
            width: gWidth * .8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    height: gHeight * .12,
                    child: SingleChildScrollView(child: title)),
                SizedBox(
                    height: gHeight * .12,
                    child: SingleChildScrollView(child: description)),
                SizedBox(
                    height: gHeight * .12,
                    child: SingleChildScrollView(child: pricePicker)),
                SizedBox(
                  width: productWidth,
                  height: productHeight,
                  child: DottedBorder(
                      dashPattern: [25],
                      strokeWidth: 3,
                      color: Colors.grey.withOpacity(0.5),
                      borderType: BorderType.RRect,
                      radius: Radius.circular(20),
                      child: Container(
                        width: productHeight,
                        height: productWidth,
                        child: image == null
                            ? pickImage(context)
                            : Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    child: Image.file(
                                      File(image!.path),
                                      fit: BoxFit.cover,
                                      width: productWidth,
                                      height: productHeight,
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(left: 10, bottom: 10),
                                    alignment: Alignment.bottomLeft,
                                    child: GestureDetector(
                                        onTap: () => setState(() {
                                              image = null;
                                            }),
                                        child: Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 1),
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .background,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(999))),
                                            child: Icon(Icons.delete))),
                                  )
                                ],
                              ),
                      )),
                ),
              ],
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: image != null && titleController.text != ''
              ? saveNewProduct()
              : SizedBox(),
        )
      ],
    );
  }

  Widget saveNewProduct() {
    return CustomContainer(
      onTap: () async {
        if (!pricePicker.contentValid) return;
        await Loading(
                context: context,
                navigator: Navigator.of(context),
                future: settingsProvider.saveProduct(
                    context: context,
                    image: image,
                    description: descriptionController.text,
                    name: titleController.text,
                    price: pricePicker.price),
                animation: successAnimation,
                msg: translate('productUploaded'))
            .dialog();
      },
      raduis: 999,
      padding: EdgeInsets.symmetric(vertical: 10),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      color: Theme.of(context).colorScheme.secondary,
      alignment: Alignment.center,
      child: Text(
        translate("save"),
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
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
          } else {
            if (SettingsData.productsCacheImages.length >=
                productsImagesLimit) {
              CustomToast(
                context: context,
                msg: translate('youCantGoUpMore') +
                    " " +
                    productsImagesLimit.toString() +
                    " " +
                    translate('changingImages'),
                gravity: ToastGravity.BOTTOM,
              ).init();
              return;
            }

            image = await _picker.pickImage(
                imageQuality: 100, source: ImageSource.gallery);
            image = await cropImage(
              image,
              CropStyle.rectangle,
              context,
              height: 1024,
              width: 1024,
              loacRatio: true,
              aspectRatio: CropAspectRatio(
                  ratioX: productImageRatioX / productImageRatioY, ratioY: 1),
            );
            if (image != null &&
                SettingsData.productsCacheImages.length + 1 >
                    productsImagesLimit) {
              CustomToast(
                context: context,
                msg: translate('youCantGoUpMore') +
                    " " +
                    productsImagesLimit.toString() +
                    " " +
                    translate('changingImages'),
                gravity: ToastGravity.BOTTOM,
              ).init();
              return;
            }
            setState(() {});
          }
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
