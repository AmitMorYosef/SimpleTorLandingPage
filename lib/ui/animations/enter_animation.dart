import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EnterAnimation extends StatefulWidget {
  final Widget? child;
  final double paddingFromTop;
  final bool animate;
  final Duration? animationDuration;
  final Widget Function(BuildContext context)? childCreator;
  EnterAnimation(
      {super.key,
      this.animate = true,
      this.child = null,
      this.animationDuration,
      this.paddingFromTop = 0,
      this.childCreator = null});

  @override
  // ignore: no_logic_in_create_state
  State<EnterAnimation> createState() => _EnterAnimationState(child: child);
}

class _EnterAnimationState extends State<EnterAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? opacityAnimation;
  Widget? child;

  _EnterAnimationState({required this.child});
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this,
        duration: widget.animationDuration != null
            ? widget.animationDuration
            : Duration(milliseconds: 800));

    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return widget.childCreator == null
          ? Padding(
              padding: EdgeInsets.only(top: widget.paddingFromTop),
              child: child!,
            )
          : Padding(
              padding: EdgeInsets.only(top: widget.paddingFromTop),
              child: widget.childCreator!(context),
            );
    }
    final widgetChild =
        widget.childCreator == null ? child : widget.childCreator!(context);
    return AnimatedBuilder(
        animation: _animationController!,
        builder: (BuildContext context, _) {
          return Padding(
            padding: EdgeInsets.only(top: valToAnimate()),
            child: Opacity(opacity: valToAnimateOpacity(1), child: widgetChild),
          );
        });
  }

  double valToAnimate() {
    if (widget.paddingFromTop > 0) {
      return widget.paddingFromTop * _animationController!.value;
    }
    return 15 * (1 - _animationController!.value);
  }

  double valToAnimateOpacity(double val) {
    return val * (_animationController!.value);
  }
}
