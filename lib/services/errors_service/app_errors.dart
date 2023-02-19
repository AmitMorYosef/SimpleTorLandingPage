import 'package:flutter/material.dart';
import 'package:simple_tor_web/app_const/application_general.dart';
import 'package:simple_tor_web/services/errors_service/messages.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';

import '../../app_const/app_sizes.dart';

abstract class AppErrors {
  static int errorCode = 100;
  static Errors error = Errors.unknown;
  static String details = '';

  static addError({int? code, Errors? error, String? details}) {
    AppErrors.error = error ?? AppErrors.error;
    AppErrors.errorCode = code ?? AppErrors.errorCode;
    AppErrors.details = details ?? AppErrors.details;
  }

  static Widget displayError(
      {bool code = true,
      bool message = true,
      bool details = true,
      bool icon = true,
      String? title}) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(bottom: 5),
      child: Column(
        children: [
          icon
              ? const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                )
              : SizedBox(),
          title == null
              ? SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 20),
                  child: Text(title,
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center),
                ),
          displayItem(
              translate("errorCode") + ":", '${AppErrors.errorCode}', code),
          displayItem(translate("theError") + ":",
              "${translate(errorMessage[AppErrors.error]!)}", message),
          Container(
              alignment: Alignment.center,
              height: details ? gHeight * .17 : 0,
              child: SingleChildScrollView(
                  child: displayItem(
                      translate("errorDetails"), AppErrors.details, details))),
        ],
      ),
    );
  }

  static Widget displayItem(String title, String message, bool display) {
    return display
        ? Column(
            children: [
              Text(title),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
            ],
          )
        : SizedBox();
  }
}
