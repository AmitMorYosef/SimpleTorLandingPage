import 'package:flutter/material.dart';
import 'package:management_system_app/providers/user_provider.dart';
import 'package:management_system_app/utlis/general_utlis.dart';
import 'package:provider/provider.dart';

import '../../app_const/db.dart';
import '../../app_const/purchases.dart';
import '../../app_statics.dart/settings_data.dart';
import '../../app_statics.dart/user_data.dart';

// ignore: must_be_immutable
class LikeAniamtion extends StatefulWidget {
  String imageId;
  String workerPhone;
  bool alreadyLiked;
  int likesAmount;
  LikeAniamtion(
      {super.key,
      required this.workerPhone,
      required this.imageId,
      required this.alreadyLiked,
      required this.likesAmount});

  Function()? clickLike;

  @override
  State<LikeAniamtion> createState() => _LikeAniamtionState();
}

class _LikeAniamtionState extends State<LikeAniamtion>
    with SingleTickerProviderStateMixin {
  late bool like;
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _sizeAnimation;
  bool isFav = false;
  @override
  void initState() {
    super.initState();
    widget.clickLike = updateLikeStatus;
    this.like = widget.alreadyLiked;
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    if (this.like)
      _colorAnimation =
          ColorTween(begin: Colors.red, end: Colors.grey).animate(_controller);
    else
      _colorAnimation =
          ColorTween(begin: Colors.grey, end: Colors.red).animate(_controller);
    _sizeAnimation = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 30, end: 40), weight: 40),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 40, end: 30), weight: 40),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {});
      }
      if (status == AnimationStatus.dismissed) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: Row(
              children: [
                GestureDetector(
                    onTap: updateLikeStatus,
                    child: Icon(
                      Icons.favorite,
                      size: _sizeAnimation.value,
                      color: _colorAnimation.value,
                    )),
                Text(
                  "${this.widget.likesAmount}",
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ));
      },
    );
  }

  void updateLikeStatus() {
    if (!UserData.isConnected()) {
      notConnectedToast(context);
      return;
    }
    if (SettingsData.businessSubtype == SubType.basic) {
      UserData.getPermission() == 2
          ? funcNotAvailableManagerToast(context)
          : funcNotAvailableClientToast(context);
      return;
    }

    context.read<UserProvider>().addOrRemoveLikeForStoryImage(
        widget.imageId,
        widget.workerPhone,
        UserData.user.phoneNumber,
        widget.alreadyLiked ? ArrayCommands.remove : ArrayCommands.add);
    if (widget.alreadyLiked) {
      widget.likesAmount--;
      widget.alreadyLiked = !widget.alreadyLiked;
      if (this.like)
        _controller.forward();
      else
        _controller.reverse();
    } else {
      widget.likesAmount++;
      widget.alreadyLiked = !widget.alreadyLiked;
      if (this.like)
        _controller.reverse();
      else
        _controller.forward();
    }
  }
}
