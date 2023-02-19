import 'package:flutter/material.dart';
import 'package:management_system_app/app_const/application_general.dart';

import '../../../app_const/app_sizes.dart';

// ignore: must_be_immutable
class CheckBoxOption extends StatefulWidget {
  final String option;
  static bool selection = false;
  Future<bool> Function()? onTrue;

  CheckBoxOption({super.key, required this.option, this.onTrue = null});

  @override
  State<CheckBoxOption> createState() => _CheckBoxOptionState();
}

class _CheckBoxOptionState extends State<CheckBoxOption> {
  @override
  void initState() {
    logger.d("CheckBox Object - init");
    CheckBoxOption.selection = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: gWidth * 0.6,
          child: Text(
            widget.option,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Checkbox(
            value: CheckBoxOption.selection,
            onChanged: ((value) async {
              if (widget.onTrue != null && !await widget.onTrue!()) return;
              setState(() {
                CheckBoxOption.selection = value ?? CheckBoxOption.selection;
              });
            })),
      ],
    );
  }
}
