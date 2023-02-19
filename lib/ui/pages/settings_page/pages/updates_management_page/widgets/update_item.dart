import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../../../app_const/app_sizes.dart';
import '../../../../../../models/update_model.dart';
import '../../../../../../providers/settings_provider.dart';
import '../../../../../../utlis/validations_utlis.dart';
import '../../../../../general_widgets/custom_widgets/custom_text_form_field.dart';

class UpdateItem extends StatelessWidget {
  final Update update;
  final double? basicHight;
  late SettingsProvider appSetting;
  UpdateItem({super.key, required this.update, this.basicHight});
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  CustomTextFormField? title, content;

  @override
  Widget build(BuildContext context) {
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
    double additionHeigth = (update.content.length / 2);
    appSetting = context.watch<SettingsProvider>();
    return GestureDetector(
      onTap: () => showUpdatesDialog(context, update),
      child: CustomContainer(
        height:
            this.basicHight != null ? this.basicHight! + additionHeigth : null,
        image: null,
        margin: EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            updateTitle(context),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                alignment: Alignment.center,
                height: this.basicHight == null
                    ? additionHeigth
                    : this.basicHight! / 6 + additionHeigth,
                child: SingleChildScrollView(
                  child: Text(
                    "${update.content}",
                    style: TextStyle(fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Spacer(),
            delete(context)
          ],
        ),
      ),
    );
  }

  Widget delete(BuildContext context) {
    return Center(
      child: IconButton(
        icon: Icon(
          Icons.delete,
          color: Colors.red,
        ),
        onPressed: () => makeSureDeleteDialog(context, update),
      ),
    );
  }

  Widget updateTitle(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomContainer(
        boxBorder: Border.all(color: Theme.of(context).colorScheme.tertiary),
        constraints:
            BoxConstraints(minWidth: gWidth * .5, maxWidth: gWidth * 0.7),
        image: null,
        color: Theme.of(context).colorScheme.tertiary,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        geometryRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit,
              size: 20,
            ),
            SizedBox(
              width: 5,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: gWidth * 0.5),
              child: Text(
                "${update.title}",
                //translate("treatmentType") + ": " + widget.treatmentName,
                style: TextStyle(fontSize: 22, overflow: TextOverflow.ellipsis),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<dynamic> makeSureDeleteDialog(BuildContext context, Update update) {
    return genralDialog(
      context: context,
      title: translate("deleting"),
      content: Text(
        translate("deleteUpdate?") + " " + update.title,
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: Text(translate('no')),
        ),
        TextButton(
          onPressed: () {
            UiManager.updateUi(
                context: context,
                perform: appSetting.deleteUpdate(update, context));
            Navigator.pop(context);
          },
          child: Text(translate('yes')),
        ),
      ],
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
}
