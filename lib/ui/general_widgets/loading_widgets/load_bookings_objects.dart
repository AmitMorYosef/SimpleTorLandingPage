// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';

import '../../../app_const/resources.dart';
import '../../../app_statics.dart/worker_data.dart';

class LoadBookingsObjects extends StatefulWidget {
  double size;
  String date;
  bool firstTime;

  final Widget Function(
    BuildContext context,
  ) childCreator;

  LoadBookingsObjects(
      {required this.childCreator,
      required this.firstTime,
      required this.size,
      required this.date});

  @override
  State<LoadBookingsObjects> createState() => _LoadBookingsObjectsState();
}

class _LoadBookingsObjectsState extends State<LoadBookingsObjects> {
  late Timer _timer;

  int _start = 10;

  void startTimer() {
    const onsec = Duration(seconds: 1);
    _timer = Timer.periodic(onsec, (timer) {
      if (WorkerData.worker.bookingObjects[widget.date] != null ||
          _start == 0) {
        setState(() {
          _timer.cancel();
        });
      } else {
        _start--;
      }
    });
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.firstTime == true) {
      startTimer();
      widget.firstTime == false;
    }
    if (WorkerData.worker.bookingObjects[widget.date] != null) {
      _timer.cancel();
    }
    return WorkerData.worker.bookingObjects[widget.date] != null
        ? widget.childCreator(context)
        : _start == 0
            ? CustomContainer(
                needImage: false,
                showBorder: false,
                alignment: Alignment.center,
                height: widget.size,
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ))
            : CustomContainer(
                showBorder: false,
                needImage: false,
                color: Theme.of(context).colorScheme.background,
                alignment: Alignment.center,
                height: widget.size,
                child: Lottie.asset(loadingAnimation, width: 150, height: 150));
  }
}
