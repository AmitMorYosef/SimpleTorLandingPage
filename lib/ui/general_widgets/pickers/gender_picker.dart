import 'package:flutter/material.dart';
import 'package:simple_tor_web/ui/general_widgets/buttons/info_button.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';

import '../../../app_const/app_sizes.dart';
import '../../../app_const/gender.dart';
import '../../../app_const/resources.dart';

// ignore: must_be_immutable
class GenderPicker extends StatefulWidget {
  static Gender selectedGender = Gender.anonymous;
  double radius;
  GenderPicker({
    super.key,
    required,
    this.radius = 60,
  });

  @override
  State<GenderPicker> createState() => _GenderPickerState();
}

class _GenderPickerState extends State<GenderPicker> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(translate("gender")),
        SizedBox(
          height: gHeight * 0.01,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              genderItem(Gender.male),
              SizedBox(width: 40),
              genderItem(Gender.female),
              SizedBox(width: 40),
              genderItem(Gender.anonymous),
            ],
          ),
        ),
        infoButton(
            context: context,
            text: translate('genderInfo'),
            padding: EdgeInsets.only(top: gHeight * 0.01))
      ],
    );
  }

  Widget genderItem(Gender gender) {
    return Opacity(
      opacity: GenderPicker.selectedGender == gender ? 1 : 0.3,
      child: GestureDetector(
        onTap: () => setState(() {
          GenderPicker.selectedGender = gender;
        }),
        child: Column(
          children: [
            SizedBox(
              height: gender == Gender.female ? 10 : 0,
            ),
            Stack(alignment: Alignment.center, children: [
              Image.asset(
                gender != Gender.female ? defaultManImage : defaultWomanImage,
                width: gender != Gender.female
                    ? widget.radius
                    : widget.radius - 10,
                height: gender != Gender.female
                    ? widget.radius
                    : widget.radius - 10,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: gender == Gender.anonymous
                    ? Icon(
                        Icons.question_mark,
                        color: Colors.grey,
                      )
                    : SizedBox(),
              )
            ]),
            SizedBox(
              height: 10,
            ),
            gender == Gender.male
                ? Text(translate('male'))
                : gender == Gender.anonymous
                    ? Text(translate('anonymous'))
                    : Text(translate('female'))
          ],
        ),
      ),
    );
  }
}
