import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

class BusinessProduct extends StatelessWidget {
  final XFile image;
  final String title;
  final String price;
  const BusinessProduct(
      {super.key,
      required this.image,
      required this.title,
      required this.price});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          height: 200,
          width: 250,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: Image.file(File(image.path)),
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: 10),
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.red, //Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Text(
                title,
                style: TextStyle(fontSize: 15),
              ),
            )),
        Container(
          margin: EdgeInsets.only(bottom: 10, right: 10),
          alignment: Alignment.bottomRight,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: Colors.red, //Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Text(
              translate("price") + ':' + this.price,
              style: TextStyle(fontSize: 15),
            ),
          ),
        )
      ],
    );
  }
}
