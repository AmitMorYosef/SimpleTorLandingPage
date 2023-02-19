import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:management_system_app/models/update_model.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/updates_management_page/widgets/update_item.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../../app_const/app_sizes.dart';
import '../../../../../app_const/limitations.dart';
import '../../../../../app_statics.dart/settings_data.dart';
import '../../../../../providers/settings_provider.dart';
import '../../../../../utlis/validations_utlis.dart';
import '../../../../general_widgets/buttons/info_button.dart';
import '../../../../general_widgets/custom_widgets/custom_text_form_field.dart';
import '../../../../general_widgets/custom_widgets/custom_toast.dart';

// ignore: must_be_immutable
class AppUpdates extends StatelessWidget {
  AppUpdates({super.key});
  late SettingsProvider appSetting;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  CustomTextFormField? title, content;
  @override
  Widget build(BuildContext context) {
    appSetting = context.watch<SettingsProvider>();
    title = CustomTextFormField(
        context: context,
        contentController: titleController,
        isValid: updateTitleValidation,
        typeInput: TextInputType.text,
        hintText: translate('title'));
    content = CustomTextFormField(
        context: context,
        contentController: contentController,
        isValid: updateContentValidation,
        typeInput: TextInputType.multiline,
        hintText: translate('content'));
    return Scaffold(
      appBar: AppBar(
        actions: [
          infoButton(
              context: context, text: translate('hereYouCanManageYourUpdates'))
        ],
        elevation: 0,
        title: Text(translate('updates')),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          children: [
            SettingsData.settings.updates.length == 0
                ? Expanded(
                    child: Center(child: Text(translate('pressToAddUpdates'))),
                  )
                : Expanded(
                    child: SizedBox(
                      width: gWidth * .9,
                      child: ListView.builder(
                          itemCount: SettingsData.settings.updates.length,
                          itemBuilder: ((context, index) {
                            Update update =
                                SettingsData.settings.updates[index];
                            return UpdateItem(
                              basicHight: 130,
                              update: update,
                            ); //updateItem(update, context);
                          })),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                children: [
                  IconButton(
                    onPressed: () {
                      if (SettingsData.settings.updates.length > updatesLimit) {
                        CustomToast(
                                context: context,
                                msg: translate('toMuchUpdates'),
                                gravity: ToastGravity.BOTTOM)
                            .init();
                        return;
                      }
                      showUpdatesDialog(context, null);
                    },
                    icon: Icon(
                      Icons.add,
                    ),
                    iconSize: 50,
                  ),
                  Text(
                    translate('addUpdate'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(
                    height: 15,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget newUpdate(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title!,
          SizedBox(
            height: 15,
          ),
          content!
        ],
      ),
    );
  }

  void showUpdatesDialog(BuildContext context, Update? update) {
    if (update != null) {
      titleController.text = update.title;
      contentController.text = update.content;
    }
    if (update == null) {
      titleController.text = '';
      contentController.text = '';
    }
    genralDialog(
      context: context,
      title:
          update == null ? translate('updateAddtion') : translate('updateEdit'),
      content: newUpdate(context),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: Text(translate('cancel')),
        ),
        TextButton(
          onPressed: () {
            if (!title!.contentValid || !content!.contentValid) {
              if (titleController.text == "") title!.check!("");
              if (contentController.text == "") content!.check!("");
              return;
            }

            Update newUpdate = Update(
                title: titleController.text,
                content: contentController.text,
                lastModified: DateFormat('dd-MM-yyyy').format(DateTime.now()));
            if (update != null &&
                (update.content != newUpdate.content ||
                    update.title != newUpdate.title)) {
              UiManager.updateUi(
                  context: context,
                  perform:
                      appSetting.replaceUpdate(update, newUpdate, context));
            }
            if (update == null)
              UiManager.updateUi(
                  context: context,
                  perform: appSetting.addUpdate(newUpdate, context));
            Navigator.pop(context);
          },
          child: Text(translate('save')),
        ),
      ],
    );
  }
}
