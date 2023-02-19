import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

import '../../../app_const/display.dart';
import '../../../app_const/resources.dart';
import '../../../app_statics.dart/theme_data.dart';

class CustomContainer extends StatelessWidget {
  final double? height;
  final double? width;
  final Widget? child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Function? onTap;
  final double? opacity;
  final double raduis;
  final Color? color;
  final bool showBorder;
  final double? borderWidth;
  final Alignment? alignment;
  final BorderRadiusGeometry? geometryRadius;
  DecorationImage? image;
  final bool needImage;
  final BoxBorder? boxBorder;
  final BoxConstraints? constraints;
  CustomContainer(
      {super.key,
      this.width,
      this.height,
      this.borderWidth,
      this.showBorder = true,
      this.child,
      this.padding,
      this.margin,
      this.opacity,
      this.needImage = true,
      this.alignment = null,
      this.raduis = 20,
      this.color = null,
      this.onTap,
      this.boxBorder,
      this.constraints = null,
      this.image = const DecorationImage(
        image: AssetImage(lightCardImage),
        fit: BoxFit.cover,
      ),
      this.geometryRadius = null});

  @override
  Widget build(BuildContext context) {
    final isDark =
        themes[AppThemeData.currentKeyTheme]!.brightness == Brightness.dark;
    this.image = this.image !=
            const DecorationImage(
              image: AssetImage(lightCardImage),
              fit: BoxFit.cover,
            )
        ? null
        : DecorationImage(
            image: AssetImage(isDark ? cardImage : lightCardImage),
            fit: BoxFit.cover,
          );

    return onTap != null
        ? BouncingWidget(
            onPressed: () => onTap!(),
            scaleFactor: 0.4,
            duration: Duration(milliseconds: 100),
            child: container(context, isDark))
        : container(context, isDark);
  }

  Widget container(BuildContext context, bool isDark) {
    return Opacity(
      opacity: opacity ?? 1,
      child: Container(
          alignment: alignment,
          height: this.height,
          width: this.width,
          padding: this.padding,
          margin: margin,
          constraints: constraints,
          decoration: BoxDecoration(
            color: this.color ?? Theme.of(context).colorScheme.surface,
            border: showBorder
                ? this.boxBorder ??
                    GradientBoxBorder(
                      gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  Color(0xffFFFFFF).withOpacity(0.15),
                                  Color(0x000000).withOpacity(0.1)
                                ]
                              : [
                                  Color(0x000000).withOpacity(0.1),
                                  Color(0xffFFFFFF).withOpacity(0.15),
                                ]),
                      width: borderWidth ?? 1,
                    )
                : null,
            image: needImage ? image : null,
            borderRadius: geometryRadius ??
                BorderRadius.all(Radius.circular(this.raduis)),
          ),
          child: this.child),
    );
  }
}
