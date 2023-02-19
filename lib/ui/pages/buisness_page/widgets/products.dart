import 'package:flutter/material.dart';
import 'package:simple_tor_web/ui/helpers/fonts_helper.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../utlis/string_utlis.dart';
import '../../../general_widgets/open_products_page_shortcut.dart';
import '../../../general_widgets/product_item.dart';

class Products extends StatefulWidget {
  final bool editMode;
  final double ratio;
  const Products({super.key, required this.editMode, this.ratio = 1});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  @override
  Widget build(BuildContext context) {
    if (SettingsData.settings.products.values.length == 0 && widget.editMode) {
      return OpenProductsPageShorcut();
    } else if (SettingsData.settings.products.values.length == 0) {
      return SizedBox();
    }
    return Column(
      children: [
        Text(
          translate("ourProducts") + ":",
          style: FontsHelper().businessStyle(
              currentStyle: TextStyle(
                  fontSize: 18 * widget.ratio,
                  color: Theme.of(context).colorScheme.secondary)),
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          height: (productHeight + gHeight * .1) *
              widget.ratio, //productHeight + 50,
          child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: SettingsData.settings.products.values.length +
                  (widget.editMode ? 1 : 0),
              itemBuilder: ((context, index) {
                if (SettingsData.settings.products.values.length == index) {
                  return OpenProductsPageShorcut();
                }
                final product =
                    SettingsData.settings.products.values.toList()[index];
                final image = SettingsData.productsCacheImages[index];

                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.0 * widget.ratio),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ProductItem(
                        image: image,
                        product: product,
                        ratio: widget.ratio,
                      )
                    ],
                  ),
                );
              })),
        ),
        SizedBox(height: 30 * widget.ratio),
      ],
    );
  }
}
