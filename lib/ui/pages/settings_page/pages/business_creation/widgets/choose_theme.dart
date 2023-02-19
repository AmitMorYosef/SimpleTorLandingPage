import 'package:flutter/material.dart';

import '../../../../../../utlis/string_utlis.dart';
import '../../../../../general_widgets/pickers/choose_theme.dart';

class ChooseThemePage extends StatelessWidget {
  ChooseThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(translate("theme"),
              style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(
            height: 20,
          ),
          ChooseTheme(
            changeThemeInDb: false,
          )
        ],
      ),
    );
  }
}
