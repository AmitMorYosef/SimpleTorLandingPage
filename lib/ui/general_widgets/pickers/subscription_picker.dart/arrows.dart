import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';

class Arrows extends StatefulWidget {
  final double itemWidth;
  final ScrollController scrollController;
  Arrows({super.key, required this.itemWidth, required this.scrollController});

  @override
  State<Arrows> createState() => _ArrowsState();
}

class _ArrowsState extends State<Arrows> {
  @override
  void initState() {
    widget.scrollController.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isFirst = true;
    bool isLast = false;

    if (widget.scrollController.hasClients) {
      isFirst = widget.scrollController.offset <= 0;
      isLast = widget.scrollController.offset >=
          widget.scrollController.position.maxScrollExtent;
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BouncingWidget(
                onPressed: () {
                  if (widget.scrollController.hasClients && !isFirst) {
                    setState(() {
                      widget.scrollController.jumpTo(
                        widget.scrollController.offset - widget.itemWidth,
                      );
                    });
                  }
                },
                child: Opacity(
                  opacity: isFirst ? 0.6 : 1,
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 17,
                  ),
                )),
            BouncingWidget(
                onPressed: () {
                  if (widget.scrollController.hasClients && !isLast) {
                    setState(() {
                      widget.scrollController.jumpTo(
                        widget.scrollController.offset + widget.itemWidth,
                      );
                    });
                  }
                },
                child: Opacity(
                    opacity: isLast ? 0.6 : 1,
                    child: Icon(Icons.arrow_forward_ios, size: 17))),
          ],
        ),
      ),
    );
  }
}
