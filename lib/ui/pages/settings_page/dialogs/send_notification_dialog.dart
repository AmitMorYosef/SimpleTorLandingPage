import 'package:flutter/material.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

import '../../../../utlis/validations_utlis.dart';
import '../../../general_widgets/custom_widgets/custom_text_form_field.dart';

TextEditingController controller = TextEditingController();
CustomTextFormField? massageField;

Future<String?> sendNotificationDialog(BuildContext context) async {
  return await genralDialog(
    context: context,
    title: translate("sendNotificationToClients"),
    content: massageFieldWidget(context),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          controller.text = "";
          Navigator.pop(context);
        },
        child: Text(translate("cancel")),
      ),
      TextButton(
        onPressed: () {
          if (controller.text == "") {
            massageField!.check!("");
          }
          if (massageField!.contentValid)
            Navigator.pop(context, controller.text);
          controller.text = "";
        },
        child: Text(translate("save")),
      ),
    ],
  );
}

Widget massageFieldWidget(BuildContext context) {
  massageField = CustomTextFormField(
      context: context,
      maxLength: 40,
      maxLines: 2,
      isValid: notificationMassageValidation,
      typeInput: TextInputType.text,
      contentController: controller);

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          translate("putMassage"),
        ),
        SizedBox(
          height: 10,
        ),
        massageField!
      ],
    ),
  );
}
