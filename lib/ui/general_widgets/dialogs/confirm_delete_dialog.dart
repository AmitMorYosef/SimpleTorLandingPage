import 'package:flutter/material.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';

import '../../../../../models/booking_model.dart';
import 'genral_dialog.dart';

class DeleteDialog {
  Booking myBooking;
  BuildContext context;
  DeleteDialog({required this.myBooking, required this.context});

  Future<dynamic> confirmBody() {
    return genralDialog(
      context: context,
      title: translate('deleteBooking'),
      content: Center(child: Text(translate('areYouSure') + " ?")),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop('Cancel'),
          child: Text(translate('no')),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop('OK');
          },
          child: Text(translate('yes')),
        ),
      ],
    );
  }
}
