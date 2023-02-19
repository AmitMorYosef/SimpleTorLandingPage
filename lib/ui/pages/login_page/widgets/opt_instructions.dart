import 'package:flutter/material.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

import '../../../../app_const/app_sizes.dart';

class OptInstructions extends StatelessWidget {
  const OptInstructions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: gHeight * 0.03, top: gHeight * 0.01),
      width: MediaQuery.of(context).size.width - 30,
      child: Column(
        children: [
          Text(
            translate("beforeStartWeNeewToConfirmPhone"),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: gHeight * 0.01,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: Theme.of(context).colorScheme.onBackground,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              Text(
                translate('pressOpt'),
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: Theme.of(context).colorScheme.onBackground,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
