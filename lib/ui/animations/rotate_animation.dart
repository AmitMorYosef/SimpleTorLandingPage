import 'dart:math' as math;

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RotateAnimation extends StatefulWidget {
  Widget child;
  Duration duration;
  RotateAnimation(
      {super.key,
      required this.child,
      this.duration = const Duration(seconds: 1)});

  @override
  State<RotateAnimation> createState() => _RotateAnimationState();
}

class _RotateAnimationState extends State<RotateAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: widget.duration);

    _animationController!.repeat();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController!,
        builder: (BuildContext context, _) {
          return Transform.rotate(
              angle: _animationController!.value * 2 * math.pi,
              child: widget.child);
        });
  }
}
