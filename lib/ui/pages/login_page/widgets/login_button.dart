import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_tor_web/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:simple_tor_web/ui/general_widgets/pickers/pick_phone_number.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/limitations.dart';
import '../../../../providers/login_provider.dart';
import '../../../../utlis/general_utlis.dart';

class LoginButton extends StatefulWidget {
  final AnimationController phoneController;
  final AnimationController optController;
  static bool isActive = true;
  static Timer? timer; // timer to calculate the seconds for re-sent opt
  static int secondsRemaining = 0; // time left to resend opt code
  static bool enableResend = true; // the delay time for re-send is 0
  LoginButton(
      {Key? key, required this.phoneController, required this.optController})
      : super(key: key);

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  late LogginProvider loggin; // connection ti loggin provider
  bool isPhoneState = true; // in 'phone' or 'opt' stage
  bool phoneIsValid = false; // wehether user phone is valid or not
  bool duringBuild =
      false; /* this is lock for setState (there are more then 1 thread calling 
      'setState' and its impossible to call it untill build is done) */
  bool stateAlive = true;
  @override
  initState() {
    super.initState();
    // listiner on the phone field for changing tn color
    context.read<LogginProvider>().phoneController.addListener(() {
      if (PickPhoneNumber.validPhone != phoneIsValid && !duringBuild)
        setState(() {
          duringBuild = true;
          phoneIsValid = PickPhoneNumber.validPhone;
        });
    });
    if (LoginButton.timer != null) LoginButton.timer!.cancel();
    // timer for re-send opt
    LoginButton.timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (LoginButton.secondsRemaining > 0) {
        LoginButton.secondsRemaining--;
        if (stateAlive && isPhoneState && !duringBuild)
          setState(() {
            duringBuild = true;
          });
      } else {
        if (!stateAlive) {
          LoginButton.timer!.cancel();
          LoginButton.timer = null;
          return;
        }
        LoginButton.enableResend = true;
        if (isPhoneState && !duringBuild)
          setState(() {
            duringBuild = true;
          });
      }
    });
  }

  @override
  dispose() {
    stateAlive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // in the end of the build realeseing the lock so other threads could call setState
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      duringBuild = false;
    });
    loggin = context.watch<LogginProvider>();
    return CustomContainer(
        alignment: Alignment.center,
        width: gWidth * .864,
        height: 54,
        raduis: 999,
        onTap: () async {
          if (!await isNetworkConnected()) {
            notNetworkConnectedToast(context);
            return;
          }
          isPhoneState ? goToOpt() : backToPhone();
        },
        color: Theme.of(context).colorScheme.secondary,
        opacity: phoneIsValid ? 1 : 0.5,
        child: isPhoneState
            ? phoneScreenContent()
            : Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSecondary,
              ));
  }

  Widget phoneScreenContent() {
    return LoginButton.enableResend
        ? Text(translate('loggin'),
            style:
                Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 17))
        : phoneIsValid
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${LoginButton.secondsRemaining}",
                      style: Theme.of(context).textTheme.bodyLarge),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ],
              )
            : Text(
                "${LoginButton.secondsRemaining}",
              );
  }

  void goToOpt() async {
    if (!LoginButton.enableResend) {
      if (phoneIsValid) {
        updateScreen(false);
        widget.phoneController.forward();
        widget.optController.forward();
      }
      return;
    }
    if (!phoneIsValid) {
      return;
    }
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    LoginButton.enableResend = false;
    LoginButton.secondsRemaining = resendOptTime;
    //FocusManager.instance.primaryFocus?.unfocus(); // remove the keybord
    loggin.sendSmsToPhone(context);
    updateScreen(false);
    widget.phoneController.forward();
    widget.optController.forward();
  }

  void backToPhone() {
    updateScreen(true);
    widget.optController.reverse();
    widget.phoneController.reverse();
  }

  void updateScreen(bool screenState) {
    this.isPhoneState = screenState;
    if (!duringBuild)
      setState(() {
        duringBuild = true;
      });
  }
}
