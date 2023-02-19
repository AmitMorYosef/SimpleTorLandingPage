import 'package:flutter/material.dart';

// ignore: must_be_immutable
class FadeWidget extends StatelessWidget {
  FadeWidget({Key? key, this.color}) : super(key: key);
  Color? color;

  @override
  Widget build(BuildContext context) {
    if (color == null) this.color = Theme.of(context).colorScheme.background;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            this.color!.withOpacity(0),
            this.color!.withOpacity(0),
            this.color!.withOpacity(0),
            this.color!.withOpacity(0),
            this.color!.withOpacity(0),
            this.color!.withOpacity(0),
            this.color!.withOpacity(0),
            this.color!.withOpacity(0),
            this.color!.withOpacity(0),
            this.color!.withOpacity(0),
            this.color!.withOpacity(0),
            this.color!.withOpacity(0),
            this.color!.withOpacity(0),
            this.color!.withOpacity(0),
            this.color!.withOpacity(0),
            this.color!.withOpacity(0),
            this.color!.withOpacity(0.3),
            this.color!.withOpacity(0.6),
            this.color!.withOpacity(0.8),
            this.color!.withOpacity(0.95),
            //x this.color!.withOpacity(0.99),
            // this.color!.withOpacity(0.99),
            this.color!.withOpacity(0.985),
            // this.color!.withOpacity(0.994),
            this.color!.withOpacity(0.993),
            //this.color!.withOpacity(0),
            this.color!.withOpacity(0.997),
            //
          ],
        ),
      ),
    );
  }
}
