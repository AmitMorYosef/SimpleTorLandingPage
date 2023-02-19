import 'dart:async';

import 'package:flutter/material.dart';

class AnimatedLoadingText extends StatefulWidget {
  final List<String> textToLoad;
  final Duration duration;
  final bool stopEnd;
  final TextStyle? textStyle;
  const AnimatedLoadingText(
      {super.key,
      required this.textToLoad,
      this.textStyle,
      this.duration = const Duration(seconds: 3),
      this.stopEnd = false});

  @override
  State<AnimatedLoadingText> createState() => _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<AnimatedLoadingText> {
  late Timer? _everySecond;
  int textIndex = 0;
  Text? selectedText;

  @override
  void dispose() {
    super.dispose();
    try {
      _everySecond!.cancel();
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    if (widget.textToLoad.length < 1) return;
    selectedText = Text(
      widget.textToLoad[textIndex],
      style: widget.textStyle,
      textAlign: TextAlign.center,
      key: Key("$textIndex"),
    );
    _everySecond = Timer.periodic(widget.duration, (Timer t) {
      setState(() {
        if (textIndex >= widget.textToLoad.length - 1) {
          if (widget.stopEnd) {
            try {
              _everySecond!.cancel();
            } catch (e) {}
          } else {
            textIndex = 0;
          }
        } else {
          textIndex += 1;
        }
        selectedText = Text(
          widget.textToLoad[textIndex],
          key: Key("$textIndex"),
          textAlign: TextAlign.center,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.textToLoad.length < 1
        ? SizedBox()
        : AnimatedSwitcher(
            child: selectedText, duration: Duration(milliseconds: 500));
  }
}
