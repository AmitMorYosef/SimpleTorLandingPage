import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app_const/application_general.dart';
import '../../../providers/language_provider.dart';
import '../../pages/settings_page/dialogs/change_language_dialog.dart';
import '../../ui_manager.dart';

class ChangeLangButton extends StatelessWidget {
  const ChangeLangButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BouncingWidget(
        onPressed: () async {
          dynamic lang = await changeLanguageDialog(context);
          logger.d("Selected language -> $lang");
          if (lang is String)
            UiManager.updateUi(
                perform: context.read<LanguageProvider>().changeLaguage(lang));
        },
        child: Icon(Icons.translate));
  }
}
