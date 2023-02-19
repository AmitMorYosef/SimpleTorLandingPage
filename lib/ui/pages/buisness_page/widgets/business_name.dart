import 'package:flutter/material.dart';
import 'package:management_system_app/utlis/validations_utlis.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../general_widgets/custom_widgets/custom_text_form_field.dart';
import '../../../helpers/fonts_helper.dart';
import '../buisness.dart';

class BusinessName extends StatelessWidget {
  final bool includeEdit;
  final double ratio;
  final TextEditingController contentController = TextEditingController();
  static late CustomTextFormField nameField;
  BusinessName({super.key, this.includeEdit = true, this.ratio = 1});

  @override
  Widget build(BuildContext context) {
    contentController.text = SettingsData.settings.shopName;
    nameField = CustomTextFormField(
        context: context,
        isValid: shopNameValidation,
        contentController: contentController,
        typeInput: TextInputType.text);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: gWidth * 0.85),
          child: this.includeEdit &&
                  Buisness.editMode &&
                  UserData.getPermission() == 2
              ? SizedBox(
                  width: gWidth * 0.6,
                  child: nameField,
                )
              : Text(
                  SettingsData.settings.shopName,
                  style: FontsHelper().businessStyle(
                    currentStyle: Theme.of(context)
                        .textTheme
                        .displaySmall!
                        .copyWith(fontSize: 32 * ratio),
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      ],
    );
  }
}
