import 'package:flutter/material.dart';
import 'package:management_system_app/providers/user_provider.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/confirm_save_dialog.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/ui/general_widgets/pickers/pick_phone_number.dart';
import 'package:management_system_app/ui/ui_manager.dart';
import 'package:provider/provider.dart';

import '/../utlis/string_utlis.dart';
import '../../../../app_const/resources.dart';
import '../../../../providers/booking_provider.dart';
import '../../../../providers/device_provider.dart';
import '../../../../utlis/general_utlis.dart';
import '../../../../utlis/validations_utlis.dart';
import '../../../general_widgets/custom_widgets/custom_text_form_field.dart';

// ignore: must_be_immutable
class GetUserDetails {
  TextEditingController nameController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  late BookingProvider bookingProvider;
  CustomTextFormField? nameField, noteField;

  Future<void> addUserFields(BuildContext context) async {
    bookingProvider = context.read<BookingProvider>();
    nameField = CustomTextFormField(
        context: context,
        contentController: nameController,
        typeInput: TextInputType.text,
        isValid: nameValidation,
        hintText: translate('customerName'));

    noteField = CustomTextFormField(
        context: context,
        contentController: noteController,
        typeInput: TextInputType.text,
        isValid: noteValidation,
        hintText: translate('note') + " (" + translate("optional") + ")");

    bool? resp = await _getCustomerDetailsDialog(context);

    overLaysHandling();

    if (resp == true) {
      BookingProvider.booking.customerName = nameController.text;
      BookingProvider.booking.note = noteController.text;
      BookingProvider.booking.customerPhone = PickPhoneNumber.completePhone;
      dynamic dialogResp = await SaveDialog(
              navigator: Navigator.of(context),
              context: context,
              workerAction: true,
              needHoldOn: false)
          .confirmBody();
      if (dialogResp is String && dialogResp.contains("OK")) {
        await _loadRequest(
            translate('bookingCopleted'),
            context,
            context.read<UserProvider>().addBooking(
                  context,
                  BookingProvider.booking,
                  BookingProvider.getWorker!,
                  context.read<DeviceProvider>().isAllowedNotification,
                  context.read<DeviceProvider>().minutesBeforeNotify,
                  addTocalendar: false,
                  workerAction: true,
                ));
      }
      Navigator.pop(context);
    } else {
      UiManager.updateUi(
          context: context,
          perform: Future(
            () => BookingProvider.setTreatmentName(""),
          ));
    }
  }

  Future<bool?> _getCustomerDetailsDialog(BuildContext context) async {
    return await genralDialog(
      context: context,
      title: translate('pressCustomerDetails'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 10,
          ),
          nameField!,
          SizedBox(
            height: 20,
          ),
          noteField!,
          SizedBox(
            height: 20,
          ),
          PickPhoneNumber(
              showFlag: false,
              hintText: translate('customerPhone') +
                  " (" +
                  translate("optional") +
                  ")"),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text(translate('cancel')),
        ),
        TextButton(
          onPressed: () {
            if (!nameField!.contentValid || !noteField!.contentValid) {
              //if (phoneController.text == "") phoneField!.check!("");
              if (nameController.text == "") nameField!.check!("");
              return;
            }
            Navigator.pop(context, true);
          },
          child: Text(translate('save')),
        ),
      ],
    );
  }

  Future<void> _loadRequest(
      String msg, BuildContext context, Future<bool> future) async {
    await Loading(
            playSound: true,
            navigator: Navigator.of(context),
            context: context,
            animation: successAnimation,
            msg: msg,
            future: future)
        .dialog();
    BookingProvider.setup();
  }
}
