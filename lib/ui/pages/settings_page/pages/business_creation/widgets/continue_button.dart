import 'package:flutter/material.dart';

import '../../../../../general_widgets/custom_widgets/custom_container.dart';
import '../make_new_buisness.dart';

class ContinueButton extends StatefulWidget {
  final double height, width;
  final int pagesLength;
  final PageController? controller;

  final void Function()? onTap;

  ContinueButton(
      {super.key,
      this.pagesLength = 0,
      this.controller,
      this.height = 50,
      this.width = 100,
      this.onTap = null});

  @override
  State<ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<ContinueButton> {
  @override
  void initState() {
    if (widget.controller != null) {
      widget.controller!.addListener(() {
        setState(() {});
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
        height: widget.height,
        width: widget.width,
        padding: EdgeInsets.all(5),
        onTap: widget.onTap,
        alignment: Alignment.center,
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
        raduis: 17,
        image: null,
        child: MakeNewBuisness.currentIndex == widget.pagesLength - 1
            ? Icon(
                Icons.save,
                color: Theme.of(context).colorScheme.onSecondary,
                size: 30,
              )
            : Icon(
                Icons.arrow_back_rounded,
                color: Theme.of(context).colorScheme.onSecondary,
                size: 30,
              )

        // Text(
        //   text,
        //   style:
        //       Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 15),
        // ),
        );
  }
}
