import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_text_form_field.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../app_statics.dart/worker_data.dart';
import '../../../models/booking_model.dart';
import '../../../models/break_model.dart';
import '../../../providers/worker_provider.dart';

class NoteButton extends StatelessWidget {
  final Booking? booking;
  final BreakModel? breakModel;
  NoteButton({super.key, this.booking, this.breakModel});
  TextEditingController noteController = TextEditingController();
  CustomTextFormField? note;

  @override
  Widget build(BuildContext context) {
    context.watch<WorkerProvider>();
    final currentNote = breakModel != null ? breakModel!.note : booking!.note;
    noteController.text = currentNote;
    note = CustomTextFormField(
        context: context,
        contentController: noteController,
        typeInput: TextInputType.text);
    return BouncingWidget(
      onPressed: () async {
        final resp = await noteDialog(context, currentNote);
        if (resp == true) {
          if (booking != null) {
            await WorkerData.setBookingNote(
                booking: booking!, noteString: noteController.text);
          } else if (breakModel != null) {
            await WorkerData.setBreakNote(
                breakModel: breakModel!, noteString: noteController.text);
            /*break has no listening so update the screen manully*/
            UiManager.updateUi(context: context);
          }
        }
      },
      child: Icon(
        currentNote == "" ? Icons.note_add : Icons.note,
      ),
    );
  }

  Future<bool?> noteDialog(BuildContext context, String text) async {
    return await genralDialog(
        context: context,
        title: translate('note'),
        content: note,
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(translate('cancel'))),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(translate('save'))),
        ]);
  }
}
