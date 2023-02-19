import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../../app_const/app_sizes.dart';
import '../../app_statics.dart/user_data.dart';
import '../../utlis/string_utlis.dart';
import '../helpers/fonts_helper.dart';

class OpenProductsPageShorcut extends StatelessWidget {
  const OpenProductsPageShorcut({super.key});

  @override
  Widget build(BuildContext context) {
    if (UserData.getPermission() != 2) return SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: productWidth,
            height: productHeight + gHeight * .07,
            child: DottedBorder(
              padding: EdgeInsets.all(5),
              dashPattern: [25],
              strokeWidth: 3,
              color: Colors.grey.withOpacity(0.5),
              borderType: BorderType.RRect,
              radius: Radius.circular(20),
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      translate("EditProducts"),
                      textAlign: TextAlign.center,
                      style: FontsHelper()
                          .businessStyle(currentStyle: TextStyle(fontSize: 18)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
