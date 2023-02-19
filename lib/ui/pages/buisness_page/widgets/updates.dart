import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_tor_web/ui/general_widgets/custom_widgets/custom_container.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/purchases.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../models/update_model.dart';
import '../../../../providers/settings_provider.dart';
import '../../../helpers/fonts_helper.dart';

class Updates extends StatefulWidget {
  final bool editMode;
  final double ratio;

  Updates({
    required this.editMode,
    this.ratio = 1,
  });
  @override
  State<StatefulWidget> createState() {
    return _UpdatesState();
  }
}

class _UpdatesState extends State<Updates> {
  late SettingsProvider settingsProvider;
  int _current = 0;
  final width = gWidth * 0.8;
  final indicatorSize = 9.0;
  final indicatorMargin = 4.0;

  @override
  Widget build(BuildContext context) {
    settingsProvider = context.watch<SettingsProvider>();
    List<Update> updates = [];
    if (SettingsData.businessSubtype == SubType.advanced ||
        UserData.isDevloper()) {
      updates = List.from(SettingsData.settings.updates);
    }
    if (updates.length == 0) {
      updates = [
        Update(
            title: translate("updates"),
            content: translate("noUpdates"),
            lastModified: "")
      ];
    }

    return CustomContainer(
      width: gWidth * 0.9 * widget.ratio,
      image: null,
      borderWidth: 2,
      raduis: 30 * widget.ratio,
      color: Theme.of(context).colorScheme.background,
      child: Stack(
        children: [
          Column(children: [
            CarouselSlider(
              options: CarouselOptions(
                  aspectRatio: (16 / 9),
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 20),
                  viewportFraction: 1,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  }),
              items: updates.map((update) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: gWidth * .7 * widget.ratio,
                      padding:
                          EdgeInsets.symmetric(vertical: 10 * widget.ratio),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${update.title}",
                            style: FontsHelper().businessStyle(
                              currentStyle: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                      fontSize: Theme.of(context)
                                              .textTheme
                                              .headlineMedium!
                                              .fontSize!
                                              .toDouble() *
                                          widget.ratio),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: gHeight * 0.1 * widget.ratio,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("${update.content}",
                                      textAlign: TextAlign.center,
                                      style: FontsHelper().businessStyle(
                                          currentStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  fontSize: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .fontSize!
                                                          .toDouble() *
                                                      widget.ratio))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            updates.length > _current && updates[_current].lastModified != ""
                ? Column(
                    children: [
                      Text(
                        "${translate('lastChange')} ${updates[_current].lastModified}",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontSize: 12 * widget.ratio),
                      ),
                    ],
                  )
                : SizedBox(
                    height: 10 * widget.ratio,
                  ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0 * widget.ratio),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: SettingsData.settings.updates
                      .asMap()
                      .entries
                      .map((entry) {
                    return Container(
                      width: indicatorSize * widget.ratio,
                      height: indicatorSize * widget.ratio,
                      margin: EdgeInsets.symmetric(horizontal: indicatorMargin),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Colors.white)
                              .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                    );
                  }).toList(),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
