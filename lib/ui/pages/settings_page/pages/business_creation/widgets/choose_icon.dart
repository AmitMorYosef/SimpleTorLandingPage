import 'package:flutter/material.dart';

import '../../../../../../utlis/string_utlis.dart';
import '../../../../../general_widgets/pickers/pick_circle_image.dart';

class ChooseIcon extends StatelessWidget {
  const ChooseIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(translate("icon"),
            style: Theme.of(context).textTheme.headlineMedium),
        SizedBox(
          height: 20,
        ),
        Text(
          translate("chooseIcon"),
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 20,
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
        ),
        SizedBox(
          height: 20,
        ),
        PickCircleImage(
          radius: 120,
          cleanLastImage: false,
        )
      ],
    );
  }
}
