import 'package:flutter/material.dart';
import 'package:management_system_app/providers/settings_provider.dart';
import 'package:management_system_app/ui/general_widgets/buttons/info_button.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/ui/general_widgets/product_item.dart';
import 'package:management_system_app/ui/pages/settings_page/dialogs/edit_product_dialog.dart';
import 'package:provider/provider.dart';

import '../../../../../app_const/app_sizes.dart';
import '../../../../../app_const/purchases.dart';
import '../../../../../app_const/resources.dart';
import '../../../../../app_statics.dart/settings_data.dart';
import '../../../../../utlis/general_utlis.dart';
import '../../../../../utlis/string_utlis.dart';
import '../../../../general_widgets/dialogs/general_delete_dialog.dart';
import 'add_product.dart';

// ignore: must_be_immutable
class ProductsManagement extends StatefulWidget {
  ProductsManagement({super.key});

  @override
  State<ProductsManagement> createState() => _ProductsManagementState();
}

class _ProductsManagementState extends State<ProductsManagement> {
  bool showImages =
      true; /* once you change cacheImage with the same url 
  you have to remove all the pointers to the image in order to update screen
  to the new image -> 
  temporarily update screen to nothing then -> to the products
  */
  late SettingsProvider settingsProvider;

  final productsImagesLimit =
      SettingsData.settings.limits[BuisnessLimitations.products]!;

  @override
  Widget build(BuildContext context) {
    if (!showImages)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          showImages = true;
        });
      });
    settingsProvider = context.watch<SettingsProvider>();
    int addContainer =
        productsImagesLimit <= SettingsData.productsCacheImages.length ? 0 : 1;
    return Scaffold(
      appBar: AppBar(
        actions: [
          infoButton(context: context, text: translate('manageProductsInfo'))
        ],
        elevation: 0,
        title: Text(translate('products')),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: GestureDetector(
        onTap: () {
          overLaysHandling();
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: SizedBox(
                  width: gWidth * 0.9,
                  child: showImages
                      ? ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount:
                              SettingsData.settings.products.values.length +
                                  addContainer,
                          itemBuilder: ((context, index) {
                            Widget widget = Padding(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: AddProduct(),
                            );
                            if (index <
                                SettingsData.productsCacheImages.length) {
                              final product = SettingsData
                                  .settings.products.values
                                  .toList()[index];
                              final image =
                                  SettingsData.productsCacheImages[index];
                              widget = Column(
                                children: [
                                  ProductItem(image: image, product: product),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                          onPressed: () async {
                                            dynamic resp =
                                                await EditProductDialog(
                                              context: context,
                                              image: image,
                                              product: product,
                                              productId: SettingsData
                                                  .settings.products.keys
                                                  .toList()[index],
                                            ).dialog();
                                            if (resp == 'OK') {
                                              setState(() {
                                                showImages = false;
                                              });
                                              //Navigator.pop(context);
                                            }
                                          },
                                          icon: Icon(Icons.edit)),
                                      IconButton(
                                          onPressed: () async {
                                            bool? resp =
                                                await showMakeSureDialog(
                                                    context,
                                                    ProductItem(
                                                        image: image,
                                                        product: product),
                                                    SettingsData
                                                        .settings.products.keys
                                                        .toList()[index]);
                                            if (resp == true) {
                                              await Loading(
                                                      context: context,
                                                      navigator:
                                                          Navigator.of(context),
                                                      future: settingsProvider
                                                          .deleteProduct(
                                                              context,
                                                              SettingsData
                                                                      .settings
                                                                      .products
                                                                      .keys
                                                                      .toList()[
                                                                  index]),
                                                      animation:
                                                          deleteAnimation,
                                                      msg: translate(
                                                          "productDeleted"))
                                                  .dialog();
                                            }
                                          },
                                          icon: Icon(Icons.delete)),
                                    ],
                                  )
                                ],
                              );
                            }
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  widget,
                                ],
                              ),
                            );
                          }))
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: AddProduct(),
                        ),
                ),
              ),
              SettingsData.limitionPassed.contains(BuisnessLimitations.products)
                  ? Container(
                      margin: EdgeInsets.only(bottom: 20),
                      width: gWidth * 0.7,
                      child: Text(
                        translate("youPassedProductsLimit") +
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
              Container(
                margin: EdgeInsets.only(bottom: 20),
                width: gWidth * 0.7,
                child: Text(
                  translate("theLimit") +
                      ": " +
                      SettingsData
                          .settings.limits[BuisnessLimitations.products]!
                          .toString(),
                  textAlign: TextAlign.center,
                  style: SettingsData.limitionPassed
                          .contains(BuisnessLimitations.products)
                      ? Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Colors.red)
                      : Theme.of(context).textTheme.titleLarge!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> productsList(BuildContext context) {
    List<Widget> products = [];
    int index = 0;
    SettingsData.settings.products.forEach((id, product) {
      final image = SettingsData.productsCacheImages[index];
      products.add(Column(
        children: [
          ProductItem(image: image, product: product),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () async {
                    dynamic resp = await EditProductDialog(
                      context: context,
                      image: image,
                      product: product,
                      productId: id,
                    ).dialog();
                    if (resp == 'OK') {
                      setState(() {
                        showImages = false;
                      });
                    }
                  },
                  icon: Icon(Icons.edit)),
              IconButton(
                  onPressed: () => showMakeSureDialog(
                      context,
                      ProductItem(image: image, product: product),
                      SettingsData.settings.products.keys.toList()[index]),
                  icon: Icon(Icons.delete)),
            ],
          )
        ],
      ));
      index += 1;
    });
    products.add(Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: AddProduct(),
    ));

    return products;
  }

  Future<bool?> showMakeSureDialog(
    BuildContext context,
    Widget product,
    String productId,
  ) async {
    return await genralDeleteDialog(
      context: context,
      title: translate('removeProduct'),
      content: SizedBox(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                translate('confirmRemoveProduct'),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              product
            ],
          ),
        ),
      ),
      onCancel: () => Navigator.pop(context, false),
      onDelete: () => Navigator.pop(context, true),
    );
  }
}
