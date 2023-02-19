import 'package:flutter/material.dart';

import '../../../../../../../../app_const/app_sizes.dart';
import '../../../../../../../general_widgets/custom_widgets/custom_container.dart';

// not used currently
class VacationRange extends StatefulWidget {
  const VacationRange({super.key});

  @override
  State<VacationRange> createState() => _VacationRangeState();
}

class _VacationRangeState extends State<VacationRange> {
  @override
  Widget build(BuildContext context) {
    String day = "23-5-22";
    return CustomContainer(
      image: null,
      width: gWidth * .95,
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(value: true, onChanged: (_) {}),
              Container(
                width: gWidth * .7,
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25)),
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontSize: 18),
                    ),
                    Text(' - '),
                    Text(
                      day,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
          toolBar(day)
        ],
      ),
    );
  }

  Widget toolBar(String day) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () => {}, //makeSureDeleteDialog(context, day),
            icon: Icon(
              Icons.edit,
              color: Colors.orange,
            )),
        IconButton(
            onPressed: () => {}, //makeSureDeleteDialog(context, day),
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            )),
      ],
    );
  }
}
