import 'package:flutter/material.dart';

class ChangeLangButton extends StatelessWidget {
  const ChangeLangButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();

    // BouncingWidget(
    //     onPressed: () async {
    //       dynamic lang = await changeLanguageDialog(context);
    //       logger.d("Selected language -> $lang");
    //       if (lang is String)
    //         UiManager.updateUi(
    //             perform: context.read<LanguageProvider>().changeLaguage(lang));
    //     },
    //     child: Icon(Icons.translate));
  }
}
