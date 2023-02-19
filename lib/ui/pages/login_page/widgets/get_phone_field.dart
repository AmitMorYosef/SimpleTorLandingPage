import 'package:flutter/material.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../providers/login_provider.dart';
import '../../../general_widgets/buttons/info_button.dart';
import '../../../general_widgets/pickers/pick_phone_number.dart';

class GetPhoneField extends StatefulWidget {
  final AnimationController controller;

  GetPhoneField({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<GetPhoneField> createState() => _GetPhoneFieldState();
}

class _GetPhoneFieldState extends State<GetPhoneField> {
  late LogginProvider loggin;
  bool validPhone = true;
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.2, 0.0),
  ).animate(CurvedAnimation(
    parent: widget.controller,
    curve: Curves.easeInCubic,
  ));

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    loggin = context.watch<LogginProvider>();
    return SlideTransition(
      position: _offsetAnimation,
      child: Container(
        //height: 60,
        padding: EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        width: gWidthOriginal,
        child: SizedBox(
          width: gWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: gWidth * 0.9,
                child: Text(translate("enterPhoneNumber"),
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: gHeight * 0.04,
              ),
              SizedBox(
                width: gWidth * 0.6,
                child: Text(translate("weSendYouCode"),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13)),
              ),
              SizedBox(
                height: gHeight * 0.04,
              ),
              PickPhoneNumber(
                controller: loggin.phoneController,
              ),
              SizedBox(
                  width: gWidth,
                  child: infoButton(
                      context: context, text: translate('phoneInfo')))
            ],
          ),
        ),
      ),
    );
  }
}
