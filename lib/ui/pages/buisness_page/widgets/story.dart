import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_tor_web/ui/pages/buisness_page/widgets/stroy_card.dart';
import 'package:simple_tor_web/utlis/string_utlis.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/purchases.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../models/worker_model.dart';
import '../../../../providers/settings_provider.dart';
import '../../../helpers/fonts_helper.dart';

// ignore: must_be_immutable
class Story extends StatelessWidget {
  late SettingsProvider settingsProvider;
  final double ratio;
  final bool editMode;

  static Map<String, Map<String, String>> imagesToDelete = {};
  Story({
    super.key,
    required this.editMode,
    this.ratio = 1,
  });

  @override
  Widget build(BuildContext context) {
    settingsProvider = context.watch<SettingsProvider>();
    List<StoryCard> imageWidgets = [];

    final finalImages = SettingsData.storyCacheImages;
    Map<String, CachedNetworkImage> allImages = {};
    int index = 0;
    Map<int, WorkerModel> workerByIndex = {};
    finalImages.forEach(
      (workerPhone, ids) {
        ids.forEach((id, _) {
          if (!SettingsData.workers.containsKey(workerPhone)) {
            /*Skip on not exists workers */
            return;
          }
          final worker = SettingsData.workers[workerPhone]!;
          workerByIndex[index] = worker;
          allImages[id] = SettingsData.storyCacheImages[workerPhone]![id]!;
          index += 1;
        });
      },
    );
    index = 0;
    finalImages.forEach(
      (workerPhone, ids) {
        if (!SettingsData.workers.containsKey(workerPhone)) {
          /*Skip on not exists workers */
          return;
        }
        ids.forEach((id, _) {
          imageWidgets.add(StoryCard(
            images: allImages,
            workerPhone: workerPhone,
            workerByIndex: workerByIndex,
            imageId: id,
            index: index,
            editMode: editMode,
            ratio: ratio,
          ));
          index += 1;
        });
      },
    );
    if (UserData.getPermission() > 0) {
      imageWidgets.add(StoryCard(
          images: {},
          workerPhone: null,
          workerByIndex: {},
          imageId: null,
          index: index,
          editMode: editMode));
    }

    return Column(
      children: [
        Container(
          width: gWidth * ratio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                translate("myWorks"),
                style: FontsHelper().businessStyle(
                  currentStyle: TextStyle(
                      fontSize: 18 * ratio,
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10 * ratio,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [],
        ),
        UserData.getPermission() == 2 &&
                SettingsData.limitionPassed
                    .contains(BuisnessLimitations.storyPhotos)
            ? Container(
                margin: EdgeInsets.only(bottom: 20),
                width: gWidth * 0.7 * ratio,
                child: Text(
                  translate("youPassedStoryPhtotsLimit") +
                      (subsLevels[SettingsData.businessSubtype] == 1
                          ? ""
                          : " " + translate("orChangePlan")),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.red),
                ),
              )
            : SizedBox(),
        UserData.getPermission() == 2 &&
                SettingsData.limitionPassed
                    .contains(BuisnessLimitations.storyPhotos)
            ? Container(
                margin: EdgeInsets.only(bottom: 20),
                width: gWidth * 0.7 * ratio,
                child: Text(
                  translate("theLimit") +
                      ": " +
                      SettingsData
                          .settings.limits[BuisnessLimitations.storyPhotos]!
                          .toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.red),
                ),
              )
            : SizedBox(),
        SettingsData.storyImagesLength == 0 && !editMode
            ? UserData.getPermission() != 2
                ? SizedBox(
                    height: storyImagesHeigth * ratio,
                    child: Center(child: Text(translate("noAvaliableStory"))))
                : SizedBox(
                    height: storyImagesHeigth * ratio,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          translate("hereYouAndYourWorkersCanAddStories"),
                          style: FontsHelper().businessStyle(
                              currentStyle: TextStyle(fontSize: 14 * ratio)),
                        ),
                        Text(
                          translate("pressOnThePencilAboveToEdit"),
                          style: FontsHelper().businessStyle(
                              currentStyle: TextStyle(fontSize: 14 * ratio)),
                        ),
                      ],
                    ))
            : Container(
                alignment: Alignment.center,
                height: storyImagesHeigth * ratio,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  primary: false,
                  shrinkWrap: true,
                  itemCount: imageWidgets.length,
                  itemBuilder: (_, index) {
                    // index = ApplicationLocalizations.of(context)!.isRTL()
                    //     ? index
                    //     : imageWidgets.length - index - 1;

                    return imageWidgets[index];
                  },
                ),
              ),
      ],
    );
  }
}
