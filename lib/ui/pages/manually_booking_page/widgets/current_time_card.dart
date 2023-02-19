import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:intl/intl.dart';

class CurrentTimeCard extends StatelessWidget {
  final DateTime time;
  const CurrentTimeCard({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          border: GradientBoxBorder(
            gradient: LinearGradient(colors: [
              Color(0xffFFFFFF).withOpacity(0.15),
              Color(0x000000).withOpacity(0.1)
            ]),
            width: 1,
          ),
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        child: Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
          child: Text(
            DateFormat('HH:mm').format(time),
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        )),
      ),
    );
  }
}
