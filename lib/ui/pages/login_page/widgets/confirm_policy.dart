import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:management_system_app/providers/login_provider.dart';
import 'package:management_system_app/server_variables.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../general_widgets/custom_widgets/custom_toast.dart';

class ConfirmPolicyAndSignUp extends StatefulWidget {
  const ConfirmPolicyAndSignUp({super.key});

  @override
  State<ConfirmPolicyAndSignUp> createState() => _ConfirmPolicyAndSignUpState();
}

class _ConfirmPolicyAndSignUpState extends State<ConfirmPolicyAndSignUp> {
  late LogginProvider logginProvider;
  @override
  Widget build(BuildContext context) {
    logginProvider = context.read<LogginProvider>();
    return Container(
      //width: gWidth * .5,
      alignment: Alignment.center,
      // padding: EdgeInsets.only(left: 10, right: 1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                  checkColor: Theme.of(context).colorScheme.onSecondary,
                  value: logginProvider.confirmedPolicy,
                  onChanged: ((value) => setState(() {
                        if (value != null)
                          logginProvider.confirmedPolicy = value;
                      }))),
              TextButton(
                  onPressed: () async {
                    var url =
                        Uri.https(SERVER_BASE_URL, PRIVACY_POLICY_END_POINT);
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
                  child: Text(translate('confirmePolicy')))
            ],
          ),
          CustomContainer(
              alignment: Alignment.center,
              width: gWidth * .864,
              height: 54,
              raduis: 999,
              color: Theme.of(context).colorScheme.secondary,
              opacity: logginProvider.confirmedPolicy ? 1 : 0.5,
              child: Text(
                translate('signUp'),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontSize: 17),
              )),
        ],
      ),
    );
  }
}
