import 'package:flutter/material.dart';
import 'package:simple_tor_web/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:simple_tor_web/ui/pages/login_page/widgets/get_phone_field.dart';
import 'package:simple_tor_web/ui/pages/login_page/widgets/login_button.dart';
import 'package:simple_tor_web/ui/pages/login_page/widgets/opt_field.dart';
import 'package:provider/provider.dart';

import '../../../app_const/app_sizes.dart';
import '../../../providers/login_provider.dart';
import '../../../utlis/general_utlis.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late LogginProvider loggin;

  late final AnimationController phoneController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  late final AnimationController optController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  @override
  Widget build(BuildContext context) {
    loggin = context.watch<LogginProvider>();
    return GestureDetector(
      onTap: () {
        overLaysHandling();
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        // if ( ScreensData.sheetController != null) {
        //   print("ddddddddddd");
        //    ScreensData.sheetController!.hide();
        // }
      },
      child: SingleChildScrollView(
        child: CustomContainer(
          showBorder: false,
          alignment: Alignment.center,
          width: gWidthOriginal,
          padding: EdgeInsets.only(top: 10, bottom: 30),
          //height: gHeight * 0.5,
          image: null,
          child: Column(
            children: [
              Stack(alignment: Alignment.topCenter, children: [
                Center(
                  //top: gHeight * .03,
                  child: GetPhoneField(
                    controller: phoneController,
                  ),
                ),
                Center(
                  //top: gHeight * .03,
                  child: OptField(
                    controller: optController,
                  ),
                ),
              ]),
              LoginButton(
                  phoneController: phoneController,
                  optController: optController)
            ],
          ),
        ),
      ),
    );
  }
}
