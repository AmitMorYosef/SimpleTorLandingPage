import 'package:flutter/material.dart';
import 'package:management_system_app/utlis/string_utlis.dart';

import '../../../general_widgets/buttons/info_button.dart';
import '../../../general_widgets/pickers/choose_theme.dart';

class ChooseThemeScaffold extends StatelessWidget {
  const ChooseThemeScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            infoButton(context: context, text: translate('hereYouChangeTheme'))
          ],
          elevation: 0,
          title: Text(translate('themes')),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: ChooseTheme());
  }
}
