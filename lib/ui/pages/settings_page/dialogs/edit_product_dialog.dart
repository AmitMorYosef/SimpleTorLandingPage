import 'package:flutter/material.dart';
import 'package:management_system_app/models/product_model.dart';
import 'package:management_system_app/providers/settings_provider.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_text_form_field.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/ui/general_widgets/pickers/pick_image.dart';
import 'package:management_system_app/ui/general_widgets/pickers/price_picker.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:management_system_app/utlis/validations_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/resources.dart';

class EditProductDialog {
  BuildContext context;
  TextEditingController nameController = TextEditingController();

  TextEditingController descriptionController = TextEditingController();
  PricePicker pricePicker = PricePicker();
  Widget image;
  final String productId;
  ProductModel product;
  late CustomTextFormField name, description;

  EditProductDialog(
      {required this.context,
      required this.image,
      required this.product,
      required this.productId});

  dynamic dialog() {
    nameController.text = product.name;
    descriptionController.text = product.description;
    pricePicker.price = product.price!;
    name = CustomTextFormField(
        context: context,
        typeInput: TextInputType.text,
        isValid: productNameValidation,
        contentController: nameController,
        hintText: translate("productName"));
    description = CustomTextFormField(
        context: context,
        typeInput: TextInputType.text,
        isValid: productDecriptionValidation,
        contentController: descriptionController,
        hintText: translate("infoAboutProdutc"));
    return genralDialog(
      context: context,
      title: translate('updateProduct'),
      content: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            children: [
              name,
              description,
              pricePicker,
              PickImage(
                imageUrl: product.imageUrl,
              )
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: Text(translate('cancel')),
        ),
        TextButton(
          onPressed: () async {
            if (PickImage.imageDeleted && PickImage.image == null) return;
            ProductModel newProduct = ProductModel.fromProduct(product);
            newProduct.name = nameController.text;
            newProduct.description = descriptionController.text;
            newProduct.price = pricePicker.price;
            await Loading(
              animation: successAnimation,
              context: context,
              future: context.read<SettingsProvider>().updateProduct(
                  context: context,
                  image: PickImage.image,
                  newProduct: newProduct,
                  productId: productId),
              msg: translate("productUpdated"),
              navigator: Navigator.of(context),
            ).dialog();
            Navigator.pop(context, 'OK');
          },
          child: Text(translate('save')),
        ),
      ],
    );
  }
}
