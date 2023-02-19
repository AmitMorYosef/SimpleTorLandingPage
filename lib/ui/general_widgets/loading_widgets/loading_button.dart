import 'dart:async';

import 'package:flutter/material.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/ui/ui_manager.dart';

// ignore: must_be_immutable
class LoadingButton extends StatefulWidget {
  Function({
    required Widget startState,
    required Widget endState,
    required Future<bool> Function() future,
  })? load;
  bool isNowLoading = false;
  Widget middleState;
  Widget startState;
  Widget? errorState;
  bool neewUiUpdate;

  LoadingButton(
      {required super.key,
      required this.startState,
      this.middleState = const SizedBox(),
      this.errorState,
      this.neewUiUpdate = false});

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool loading = false;
  Future<bool> Function()? future;
  Widget? endState;
  Widget? errorState;

  @override
  void initState() {
    super.initState();
    widget.load = setToLoading;
  }

  @override
  Widget build(BuildContext context) {
    widget.load = setToLoading;
    return loading ? loadFuture() : widget.startState;
  }

  Widget loadFuture() {
    return FutureBuilder<bool>(
        future: future!(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              widget.isNowLoading = true;
              return widget.middleState;
            case ConnectionState.done:
            default:
              if (snapshot.hasError) {
                widget.isNowLoading = false;
                logger.e(
                    "Error accurd while load the Loading Button --> ${snapshot.error}");
                return widget.errorState ?? widget.startState;
              } else if (snapshot.hasData) {
                widget.isNowLoading = false;
                if (snapshot.data == true) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (widget.neewUiUpdate)
                      UiManager.updateUi(context: context);
                  });
                  return AnimatedSwitcher(
                      duration: Duration(milliseconds: 800), child: endState!);
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (widget.neewUiUpdate)
                      UiManager.updateUi(context: context);
                  });
                  return widget.errorState ?? widget.startState;
                }
              } else {
                return widget.errorState ?? widget.startState;
              }
          }
        });
  }

  void setToLoading({
    required Widget startState,
    required Widget endState,
    required Future<bool> Function() future,
  }) {
    setState(() {
      loading = true;
      widget.startState = startState;
      this.endState = endState;
      this.future = future;
    });
  }
}
