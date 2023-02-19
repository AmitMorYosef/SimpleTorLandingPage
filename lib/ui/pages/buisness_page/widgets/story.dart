import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/make_sure_dialog.dart';
import 'package:management_system_app/ui/pages/buisness_page/widgets/stroy_card.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/purchases.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../models/worker_model.dart';
import '../../../../providers/settings_provider.dart';
import '../../../general_widgets/intro/lib/flutter_intro.dart';
import '../../../general_widgets/loading_widgets/loading_dialog.dart';
import '../../../helpers/fonts_helper.dart';

// ignore: must_be_immutable
class Story extends StatelessWidget {
  late SettingsProvider settingsProvider;
  final double ratio;
  final bool editMode;
  final Intro? intro;
  static Map<String, Map<String, String>> imagesToDelete = {};
  Story({super.key, required this.editMode, this.ratio = 1, this.intro});

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
      key: intro == null ? null : intro!.keys[1],
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
              Positioned(left: 10, child: StoryDeleteButton())
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

class StoryDeleteButton extends StatefulWidget {
  static Function? onChanged;
  StoryDeleteButton({super.key});

  @override
  State<StoryDeleteButton> createState() => _StoryDeleteButtonState();
}

class _StoryDeleteButtonState extends State<StoryDeleteButton> {
  late SettingsProvider settingsProvider;
  @override
  void initState() {
    super.initState();
    StoryDeleteButton.onChanged = onChanged;
  }

  @override
  Widget build(BuildContext context) {
    settingsProvider = context.read<SettingsProvider>();
    return Story.imagesToDelete.isEmpty
        ? SizedBox()
        : Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: BouncingWidget(
                child: Icon(Icons.delete),
                onPressed: () async {
                  if (await makeSureDialog(
                          context, translate("deletePickedImages")) ==
                      true) {
                    await Loading(
                            context: context,
                            navigator: Navigator.of(context),
                            future: deleteAllImages(context),
                            animation: deleteAnimation,
                            msg: Story.imagesToDelete.length > 1
                                ? translate("imagesDeletion")
                                : translate("deletedImage"))
                        .dialog();
                  }
                }),
          );
  }

  Future<bool> deleteAllImages(BuildContext context) async {
    bool resp = true;
    await Future.forEach(Story.imagesToDelete.keys, (imageId) async {
      resp = resp &&
          await settingsProvider.deleteStoryImage(
            context,
            Story.imagesToDelete[imageId]!["workerPhone"]!,
            imageId,
            Story.imagesToDelete[imageId]!["imageUrl"]!,
          );
    });
    Story.imagesToDelete = {};
    return resp;
  }

  void onChanged() {
    setState(() {});
  }
}
