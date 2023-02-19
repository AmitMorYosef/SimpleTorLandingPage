import 'package:flutter/material.dart';
import 'package:simple_tor_web/utlis/general_utlis.dart';

// ignore: must_be_immutable
class CustomTextFormField extends StatefulWidget {
  bool contentValid = true;
  BuildContext context;
  TextEditingController contentController;
  TextInputType typeInput;
  Function? onChanged;
  String? text;
  Function? isValid;
  double? width;
  double? hight;
  String? hintText;
  String? initialValue;
  int? maxLength;
  int? maxLines;
  Function? check;
  Function(String?)? onSaved;
  CustomTextFormField(
      {required this.context,
      required this.contentController,
      required this.typeInput,
      Function? this.onChanged,
      Function? this.isValid,
      double? this.width,
      double? this.hight,
      String? this.hintText,
      String? this.initialValue,
      int? this.maxLength,
      int? this.maxLines});

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  void initState() {
    if (widget.isValid != null) widget.check = onChanged;

    if (widget.isValid != null &&
        widget.isValid!(widget.contentController.text) != '')
      widget.contentValid = false;
    super.initState();
  }

  String validationText = '';
  bool hasValidation = false;
  @override
  Widget build(BuildContext context) {
    if (widget.isValid != null) {
      hasValidation = true;
    }

    return customTextFormField(
      hasValidation: hasValidation,
      validationText: validationText,
      context: widget.context,
      onChanged: onChanged,
      contentController: widget.contentController,
      typeInput: widget.typeInput,
      width: widget.width,
      hight: widget.hight,
      hintText: widget.hintText,
      initialValue: widget.initialValue,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
    );
  }

  void onChanged(String text) {
    if (widget.isValid != null) {
      validationText = widget.isValid!(text.trim());
      if (validationText == '') {
        valid();
      } else {
        notvValid();
      }
    }
    if (widget.onChanged != null) widget.onChanged!(text);
  }

  void valid() {
    setState(() {
      widget.contentValid = true;
    });
  }

  void notvValid() {
    setState(() {
      widget.contentValid = false;
    });
  }
}

Widget customTextFormField({
  required BuildContext context,
  required TextEditingController contentController,
  required TextInputType typeInput,
  required Function onChanged,
  required String validationText,
  required bool hasValidation,
  double? width,
  double? hight,
  String? hintText,
  String? initialValue,
  int? maxLength,
  int? maxLines,
}) {
  return Column(children: [
    Row(
      children: [
        Expanded(
          child: Container(
            width: width,
            height: hight,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 2.0,
                    color: hasValidation && validationText != ''
                        ? Colors.red
                        : Theme.of(context).colorScheme.onBackground),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                        keyboardAppearance: Theme.of(context).brightness,
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        onChanged: (value) => onChanged(value),
                        initialValue: initialValue,
                        maxLength: maxLength,
                        maxLines: maxLines,
                        controller: contentController,
                        keyboardType: typeInput,
                        onEditingComplete: () {
                          overLaysHandling();
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        decoration: InputDecoration(
                            icon: hasValidation && validationText != ''
                                ? Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  )
                                : SizedBox(),
                            border: InputBorder.none,
                            hintText: hintText,
                            hintStyle: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onBackground
                                    .withOpacity(0.5)))),
                  ),
                  IconButton(
                    onPressed: () {
                      contentController.clear();
                      onChanged(contentController.text);
                    },
                    icon: Icon(Icons.delete),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    SizedBox(
      height: 5,
    ),
    validationText == ""
        ? SizedBox()
        : Text(
            validationText,
            textAlign: TextAlign.center,
          )
  ]);
}
