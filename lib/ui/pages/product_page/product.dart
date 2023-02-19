import 'package:cached_network_image/cached_network_image.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:management_system_app/models/product_model.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

import '../../../app_const/app_sizes.dart';
import '../../helpers/fonts_helper.dart';

// ignore: must_be_immutable
class Product extends StatefulWidget {
  final ProductModel product;
  final CachedNetworkImage image;

  Product({super.key, required this.product, required this.image});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> with SingleTickerProviderStateMixin {
  bool onlyImage = true;
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    animation = Tween<double>(begin: .0, end: 1).animate(controller);
    //UserProvider.startLisening();
  }

  @override
  void dispose() {
    controller.dispose();
    //UserProvider.cancelListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      title: Center(
          child: Text(
        widget.product.name,
        style: FontsHelper().businessStyle(currentStyle: null),
        textAlign: TextAlign.center,
      )),
      actions: [
        SizedBox(
          width: 40,
        )
      ],
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (onlyImage) {
        onlyImage = false;
        setState(() {});
        controller.forward();
      }
    });
    return Scaffold(
      appBar: appBar,
      body: Hero(
          tag: widget.image.imageUrl,
          child: Material(
            color: Theme.of(context).colorScheme.background,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      productImage(),
                      Visibility(
                        visible: !onlyImage,
                        child: Expanded(
                            child: FadeTransition(
                                //
                                opacity: animation,
                                child: productData(context))),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: !onlyImage,
                  child: FadeTransition(
                      //
                      opacity: animation,
                      //visible: !onlyImage,
                      child: backButtom(context)),
                )
              ],
            ),
          )),
    );
  }

  Widget backButtom(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: CustomContainer(
        alignment: Alignment.center,
        raduis: 1,
        width: gWidth * .8,
        color: Theme.of(context).colorScheme.secondary,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        margin: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          translate("back"),
          style: FontsHelper().businessStyle(
              currentStyle: Theme.of(context).textTheme.headlineSmall),
        ),
      ),
    );
  }

  Widget productImage() {
    return FittedBox(
      fit: BoxFit.cover,
      child: Container(
        alignment: Alignment.center,
        width: gWidthOriginal,
        height: gWidthOriginal * (productImageRatioY / productImageRatioX),
        child: Container(
          height: widget.image.height!,
          width: widget.image.width!,
          child: Container(
            child: FlipCard(
              front: ClipRRect(child: widget.image),
              back: ClipRRect(child: widget.image),
            ),
          ),
        ),
      ),
    );
  }

  Widget productData(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      width: gWidth * .95,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                widget.product.description,
                style: FontsHelper().businessStyle(
                    currentStyle: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(fontSize: 22)),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              "${translate("price")}: ${widget.product.price}",
              style: FontsHelper().businessStyle(
                  currentStyle: Theme.of(context).textTheme.headlineSmall),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
