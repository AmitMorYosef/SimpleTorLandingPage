import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:simple_tor_web/app_const/application_general.dart';
import 'package:simple_tor_web/models/product_model.dart';
import 'package:simple_tor_web/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:simple_tor_web/ui/pages/product_page/product.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';

import '../../app_const/app_sizes.dart';
import '../helpers/fonts_helper.dart';

class ProductItem extends StatelessWidget {
  final ProductModel product;
  final CachedNetworkImage image;
  final double ratio;
  const ProductItem(
      {super.key, required this.product, required this.image, this.ratio = 1});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => Product(
                    product: product,
                    image: image,
                  ))),
      child: Hero(
        tag: image.imageUrl,
        child: Material(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5 * ratio),
              topRight: Radius.circular(5 * ratio)),
          child: CustomContainer(
            raduis: 5 * ratio,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: productWidth * ratio,
                      height: productHeight * ratio,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5 * ratio),
                                topRight: Radius.circular(5 * ratio)),
                            child: this.image,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    Text(product.name,
                        style: FontsHelper().businessStyle(
                            currentStyle: TextStyle(
                          fontSize: 20 * ratio,
                          //color: Theme.of(context).colorScheme.secondary
                        ))),
                  ],
                ),
                // Container(
                //   height: gHeight * .1,
                //   width: productWidth,
                //   color: Colors.white,
                // )

                SizedBox(),
                Text(
                  "${translate("price")}:  ${product.price}",
                  style: FontsHelper().businessStyle(
                      currentStyle: TextStyle(
                    fontSize: 13 * ratio,
                    //color: Theme.of(context).colorScheme.secondary
                  )),
                ),
                SizedBox(
                  height: 1,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
