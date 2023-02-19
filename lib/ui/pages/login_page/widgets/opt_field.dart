import 'package:flutter/material.dart';
import 'package:management_system_app/ui/general_widgets/pickers/pick_phone_number.dart';
import 'package:management_system_app/ui/pages/login_page/widgets/opt_instructions.dart';
import 'package:management_system_app/ui/pages/login_page/widgets/otp_text_field.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../providers/login_provider.dart';
import '../../../../providers/user_provider.dart';
import '../../../../utlis/general_utlis.dart';
import '../../../general_widgets/loading_widgets/loading_dialog.dart';

class OptField extends StatefulWidget {
  final AnimationController controller;
  OptField({Key? key, required this.controller}) : super(key: key);
  @override
  State<OptField> createState() => _OptFieldState();
}

class _OptFieldState extends State<OptField> {
  late LogginProvider loggin;
  OtpFieldController optController = OtpFieldController();

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    end: Offset.zero,
    begin: const Offset(-1.2, 0.0),
  ).animate(CurvedAnimation(
    parent: widget.controller,
    curve: Curves.easeInCubic,
  ));

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    loggin = context.watch<LogginProvider>();
    return SlideTransition(
      position: _offsetAnimation,
      child: SizedBox(
        width: gWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.lock, size: 50), OptInstructions(), optCells()],
        ),
      ),
    );
  }

  Widget optCells() {
    return Container(
      height: 60,
      width: gWidth,
      alignment: Alignment.center,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: OTPTextField(
            controller: optController,
            length: 6,
            width: gWidth * .93,
            fieldWidth: gWidth * 0.11,
            otpFieldStyle: OtpFieldStyle(
                enabledBorderColor: Theme.of(context).colorScheme.secondary,
                focusBorderColor: Theme.of(context).colorScheme.onBackground),
            style:
                Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 17),
            textFieldAlignment: MainAxisAlignment.spaceAround,
            fieldStyle: FieldStyle.box,
            onChanged: (value) => {},
            onCompleted: (pin) async => await verify(pin)),
      ),
    );
  }

  Future<void> verify(pin) async {
    // if auto complete the code removing focus sron last field
    overLaysHandling();
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    // ---------------------------------------------------------
    loggin.opt = pin;
    await Loading(
            desplayErrorDetails: true,
            displayErrorDuration: Duration(milliseconds: 1500),
            navigator: Navigator.of(context),
            isBoolCondition: true,
            context: context,
            msg: "${translate('authenticationCompleted')}",
            future: verifyAndTryToLoadUser(), //tryLogin(),
            animation: successAnimation)
        .dialog()
        .then((value) async {
      if (value == true) {
        bool userExistInDb = UserData.user.phoneNumber != '';
        if (!userExistInDb) {
          // close the sheet and open sign up sheet
          Navigator.pop(context, "SIGN_UP");
        } else {
          Navigator.pop(context, "LOGED_IN");
        }
      } else {
        // auth failed --> stay in same screen to allowed the user fix opt
        //optController.clear();
      }
    });
  }

  Future<bool> verifyAndTryToLoadUser() async {
    bool isVerified = await loggin.verifyOpt(context);
    if (!isVerified) {
      // validation error
      return false;
    }
    /*
    register: don't logout the user didn't created yet
    loggin: don't loggout -> exist: load user. disen't exist: signUp schem
     */
    await context.read<UserProvider>().setupUser(
        phone: PickPhoneNumber.completePhone,
        logoutIfDosentExist: false); // setup the logged it user
    UiManager.cleanQueue();
    return isVerified;
  }
}
