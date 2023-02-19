import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../server_variables.dart';
import '../../utlis/string_utlis.dart';
import 'custom_widgets/custom_toast.dart';

Widget policyAndTerms(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      TextButton(
          onPressed: () async {
            var url = Uri.https(SERVER_BASE_URL, PRIVACY_POLICY_END_POINT);
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else
              // can't launch url, there is some error
              CustomToast(
                context: context,
                toastLength: Duration(seconds: 3),
                msg:
                    "${translate('logginErrorWithDetails')} - https://$SERVER_BASE_URL/$PRIVACY_POLICY_END_POINT",
                gravity: ToastGravity.CENTER,
              ).init();
          },
          child: Text(translate('companyPolicy'))),
      Container(width: 1, height: 5, color: Colors.grey),
      TextButton(
          onPressed: () async {
            var url = Uri.https(
                "www.apple.com", "legal/internet-services/itunes/dev/stdeula");
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else
              // can't launch url, there is some error
              CustomToast(
                context: context,
                toastLength: Duration(seconds: 3),
                msg:
                    "${translate('logginErrorWithDetails')} - https://www.apple.com/legal/internet-services/itunes/dev/stdeula/",
                gravity: ToastGravity.CENTER,
              ).init();
          },
          child: Text(translate("termOfUse")))
    ],
  );
}
