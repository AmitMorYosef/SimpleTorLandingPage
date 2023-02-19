import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../../../../utlis/string_utlis.dart';
import '../../../helpers/fonts_helper.dart';

class AddProductsWidget extends StatelessWidget {
  const AddProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: DottedBorder(
          padding: EdgeInsets.all(15),
          dashPattern: [25],
          strokeWidth: 3,
          color: Colors.grey.withOpacity(0.5),
          borderType: BorderType.RRect,
          radius: Radius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                translate("EditProducts"),
                style: FontsHelper().businessStyle(
                    currentStyle: TextStyle(
                  fontSize: 18,
                )),
              )
            ],
          )),
    );
  }
}
