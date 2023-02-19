import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:simple_tor_web/providers/login_provider.dart';
import 'package:simple_tor_web/providers/user_provider.dart';
import 'package:simple_tor_web/ui/animations/enter_animation.dart';
import 'package:simple_tor_web/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:simple_tor_web/ui/pages/login_page/widgets/confirm_policy.dart';
import 'package:simple_tor_web/ui/ui_manager.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../app_const/app_sizes.dart';
import '../../../app_const/application_general.dart';
import '../../../app_const/resources.dart';
import '../../../app_statics.dart/user_data.dart';
import '../../../utlis/general_utlis.dart';
import '../../../utlis/validations_utlis.dart';
import '../../general_widgets/buttons/info_button.dart';
import '../../general_widgets/custom_widgets/custom_text_form_field.dart';
import '../../general_widgets/custom_widgets/custom_toast.dart';
import '../../general_widgets/loading_widgets/loading_dialog.dart';
import '../../general_widgets/pickers/gender_picker.dart';

// ignore: must_be_immutable
class SignUp extends StatelessWidget {
  late LogginProvider loggin;

  @override
  Widget build(BuildContext context) {
    loggin = context.read<LogginProvider>();
    overLaysHandling();

    return GestureDetector(
      onTap: () {
        overLaysHandling();
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: SingleChildScrollView(
        child: CustomContainer(
          image: null,
          borderWidth: 0,
          padding: EdgeInsets.only(top: gHeight * 0.01, bottom: gHeight * 0.03),
          geometryRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          child: EnterAnimation(
            paddingFromTop: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                nameField(context),
                GenderPicker(),
                signUpButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget nameField(BuildContext context) {
    return SizedBox(
      width: gWidth * .95,
      child: Column(
        children: [
          Text(translate('fullname')),
          SizedBox(
            height: gHeight * 0.01,
          ),
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                    context: context,
                    contentController: loggin.userNameController,
                    typeInput: TextInputType.name,
                    isValid: nameValidation,
                    hintText: translate('typeHere')),
              ),
              infoButton(context: context, text: translate('nameInfo'))
            ],
          ),
        ],
      ),
    );
  }

  Widget signUpButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!loggin.confirmedPolicy) {
          CustomToast(
            context: context,
            msg: translate('pleaseConfirmePolicy'),
            gravity: ToastGravity.CENTER,
          ).init();
          return;
        }
        if (nameValidation(loggin.userNameController.text) != '') {
          CustomToast(
            context: context,
            msg: translate('illegalName'),
            gravity: ToastGravity.BOTTOM,
          ).init();
          return;
        }
        UiManager.insertUpdate(Providers.settings);
        dynamic resp = await Loading(
                needUiUpdate: false,
                navigator: Navigator.of(context),
                context: context,
                msg: translate('successfulySignUp'),
                future: register(context),
                animation: successAnimation)
            .dialog();
        resp
            ? Navigator.pop(context, "SUCSSES")
            : CustomToast(
                context: context,
                msg: translate('sumethingWentWrongTryAgain'),
                gravity: ToastGravity.BOTTOM,
              ).init();
      },
      child: ConfirmPolicyAndSignUp(),
    );
  }

  Future<bool> register(BuildContext context) async {
    return await context
        .read<UserProvider>()
        .createUser(context, GenderPicker.selectedGender, loggin.submitedPhone)
        .then((value) async {
      if (value) {
        logger.i("Save the name --> ${loggin.userNameController.text}");
        return await loggin
            .saveUserNameLocally(
                name: loggin.userNameController.text.trim(),
                phonePrefix: loggin.submitedPhone.split('-')[0])
            .then((value) async {
          if (value) {
            //await Future.delayed(Duration(seconds: 5));
            UserData.userDoc = null; // force db load user
            return await context.read<UserProvider>().setupUser();
          }
          return value;
        });
      }
      return value;
    });
  }
}
