import 'package:flutter/material.dart';

import '../../../app_const/app_sizes.dart';
import '../../../services/in_app_services.dart/language.dart';

class SettingItem extends StatelessWidget {
  final Icon icon;
  final Widget suffix;
  final String name;
  final Widget? trailing;
  final List<Widget>? children;
  final Widget? subtitle;

  final void Function() onClick;
  SettingItem({
    Key? key,
    this.trailing,
    this.subtitle,
    this.children,
    this.icon = const Icon(
      Icons.settings,
      color: Color(0xffA2A2B5),
    ),
    this.suffix = const Icon(Icons.tab, color: Color(0xffA2A2B5)),
    required this.name,
    required this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return children == null
        ? InkWell(
            onTap: () {
              onClick();
            },
            child: item(context))
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ExpansionTile(
              textColor: Theme.of(context).colorScheme.secondary,
              iconColor: Theme.of(context).colorScheme.secondary,
              title: Text(
                name,
                style: TextStyle(),
              ),
              subtitle: subtitle != null ? subtitle : SizedBox(),
              children: children!,
              leading: icon,
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          );
  }

  Widget item(BuildContext context) {
    return Container(
      padding: subtitle == null ? EdgeInsets.symmetric(vertical: 6) : null,
      width: gWidth * .765,
      child: SizedBox(
        width: gWidth * .7,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: gWidth * .5,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    icon,
                    SizedBox(
                      width: 10,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                          ),
                          subtitle != null ? subtitle! : SizedBox()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                trailing == null
                    ? SizedBox()
                    : Container(
                        width: gWidth * 0.17,
                        alignment: ApplicationLocalizations.of(context)!.isRTL()
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal, child: trailing!),
                      ),
                suffix,
              ],
            )
          ],
        ),
      ),
    );
  }
}
