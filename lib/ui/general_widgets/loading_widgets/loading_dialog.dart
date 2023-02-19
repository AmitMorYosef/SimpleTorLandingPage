import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/services/errors_service/app_errors.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

import '../../../app_const/limitations.dart';
import '../../../app_const/resources.dart';
import '../../../services/errors_service/messages.dart';

class Loading {
  Future<bool> future;
  BuildContext context;
  String msg;
  String animation;
  bool? isBoolCondition;
  bool playSound;
  Duration timeOutDuration;
  Duration displayErrorDuration;
  NavigatorState navigator;
  /*for cases when the listener update the ui before the loading dialog */
  bool needUiUpdate;
  bool desplayErrorDetails;
  final double size = 150;
  final double dialogWidth = 200;
  Loading(
      {required this.context,
      this.timeOutDuration = const Duration(seconds: 6),
      required this.navigator,
      required this.future,
      this.animation = successAnimation,
      this.isBoolCondition,
      required this.msg,
      this.needUiUpdate = true,
      this.playSound = false,
      this.desplayErrorDetails = false,
      this.displayErrorDuration = const Duration(milliseconds: 1300)});

  Future<dynamic> dialog() async {
    bool resp = await genralDialog(
      context: context,
      dismissible: false,
      content: FutureBuilder<bool>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!) {
              Timer(Duration(milliseconds: successDialogMiliseconds), () {
                navigator.pop(snapshot.data);
              });
              return successWidget();
            } else {
              Timer(displayErrorDuration, () {
                navigator.pop(snapshot.data);
              });
              return AppErrors.displayError(details: desplayErrorDetails);
            }
          }
          if (snapshot.hasError) {
            Timer(displayErrorDuration, () {
              navigator.pop(snapshot.hasError);
            });
            logger.e("Loading error: ${snapshot.error}");
            AppErrors.error = Errors.unknown;
            return AppErrors.displayError(details: desplayErrorDetails);
          } else {
            logger.d("Inside loading widget");
            return CircleLoadingAnimation(
              timeout: this.timeOutDuration,
            );
          }
          // return Container(color: Colors.blue, width: 100,height: 100,)
        },
      ),
    );
    if (this.needUiUpdate && resp != false) {
      UiManager.updateUi(context: context);
    }
    return resp;
  }

  Widget successWidget() {
    return SizedBox(
      width: dialogWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(animation, width: size, height: size, repeat: false),
          SizedBox(
            height: 5,
          ),
          Text(
            this.msg,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        ],
      ),
    );
  }
}

class CircleLoadingAnimation extends StatefulWidget {
  final Duration timeout;
  const CircleLoadingAnimation({super.key, required this.timeout});

  @override
  State<CircleLoadingAnimation> createState() => _CircleLoadingAnimationState();
}

class _CircleLoadingAnimationState extends State<CircleLoadingAnimation> {
  bool isTimeOut = false;
  bool stateAvilable = true;
  @override
  void dispose() {
    stateAvilable = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isTimeOut)
      Future.delayed(widget.timeout).then((_) {
        if (stateAvilable)
          setState(() {
            isTimeOut = true;
          });
      });
    return Column(
      children: [
        SizedBox(
            width: 200,
            child: Lottie.asset(loadingAnimation, width: 150, height: 150)),
        isTimeOut
            ? GestureDetector(
                onTap: () {
                  Navigator.pop(context, false);
                },
                child: CustomContainer(
                    width: 80,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(translate('cancel'))),
              )
            : SizedBox(),
      ],
    );
  }
}
