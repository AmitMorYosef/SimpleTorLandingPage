// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class ScrollBackAndForth extends StatefulWidget {
  Widget child;
  ScrollBackAndForth({required this.child});
  @override
  _ScrollBackAndForthState createState() => _ScrollBackAndForthState();
}

class _ScrollBackAndForthState extends State<ScrollBackAndForth> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      double minScrollExtent = _scrollController.position.minScrollExtent;
      double maxScrollExtent = _scrollController.position.maxScrollExtent;

      //
      animateToMaxMin(maxScrollExtent, minScrollExtent, maxScrollExtent, 25,
          _scrollController);
    });
  }

  animateToMaxMin(double max, double min, double direction, int seconds,
      ScrollController scrollController) {
    scrollController
        .animateTo(direction,
            duration: Duration(seconds: seconds), curve: Curves.linear)
        .then((value) {
      direction = direction == max ? min : max;
      animateToMaxMin(max, min, direction, seconds, scrollController);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        controller: _scrollController, child: widget.child);
  }
}
