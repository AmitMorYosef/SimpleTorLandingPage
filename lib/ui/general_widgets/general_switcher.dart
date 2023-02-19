import 'package:flutter/material.dart';

class GeneralSwitcher extends StatefulWidget {
  final bool initVal;
  final Future<void> Function(bool) perform;
  const GeneralSwitcher(
      {super.key, required this.initVal, required this.perform});

  @override
  State<GeneralSwitcher> createState() => _GeneralSwitcherState();
}

class _GeneralSwitcherState extends State<GeneralSwitcher> {
  bool switchVal = false;
  @override
  void initState() {
    super.initState();
    switchVal = widget.initVal;
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
        value: switchVal,
        onChanged: (val) {
          // first set the
          setState(() {
            switchVal = val;
          });
          widget.perform(val);
        });
  }
}
