import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app_statics.dart/general_data.dart';
import '../../../../server_variables.dart';
import '../pages/widgets/business_qr_widget.dart';

Future<dynamic> linksOptionsDialog(BuildContext context) async {
  String url = 'https://$SERVER_BASE_URL/$BUSINESS_LINK_END_POINT';
  dynamic resp = await genralDialog(
      animationType: DialogTransitionType.slideFromTopFade,
      context: context,
      backgroundOpacity: 1,
      title: translate('shareOptions'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const BusinessQr(
              size: 150,
            ),
            SizedBox(
              height: 10,
            ),
            BouncingWidget(
              scaleFactor: 0.5,
              onPressed: () {
                Share.share(
                    translate("inviteToOrderInSimpleTor") +
                        url.replaceAll(
                            "BUISNESS_ID", GeneralData.currentBusinesssId),
                    subject: translate("inviteToOrderInMyApp"));
              },
              child: textLink(context),
            )
          ],
        ),
      ));

  return resp;
}

Widget textLink(BuildContext context) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.link,
          color: Theme.of(context).colorScheme.secondary,
          size: 25,
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          translate("shareWithLink"),
          style: TextStyle(
              fontSize: 15, color: Theme.of(context).colorScheme.secondary),
        ),
      ],
    ),
  );
}
