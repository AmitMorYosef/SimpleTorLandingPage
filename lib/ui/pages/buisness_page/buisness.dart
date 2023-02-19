import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:management_system_app/ui/general_widgets/intro/lib/flutter_intro.dart';
import 'package:management_system_app/ui/general_widgets/pickers/pick_circle_image.dart';
import 'package:management_system_app/ui/pages/buisness_page/widgets/animated_images.dart';
import 'package:management_system_app/ui/pages/buisness_page/widgets/app_icons.dart';
import 'package:management_system_app/ui/pages/buisness_page/widgets/back_button.dart';
import 'package:management_system_app/ui/pages/buisness_page/widgets/business_name.dart';
import 'package:management_system_app/ui/pages/buisness_page/widgets/products.dart';
import 'package:management_system_app/ui/pages/buisness_page/widgets/reminder.dart';
import 'package:management_system_app/ui/pages/buisness_page/widgets/story.dart';
import 'package:management_system_app/ui/pages/buisness_page/widgets/subscribe_indicator.dart';
import 'package:management_system_app/ui/pages/buisness_page/widgets/updates.dart';
import 'package:management_system_app/utlis/general_utlis.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:provider/provider.dart';

import '../../../app_const/app_sizes.dart';
import '../../../app_const/booking.dart';
import '../../../app_const/purchases.dart';
import '../../../app_const/resources.dart';
import '../../../app_statics.dart/screens_data.dart';
import '../../../app_statics.dart/settings_data.dart';
import '../../../app_statics.dart/theme_data.dart';
import '../../../app_statics.dart/user_data.dart';
import '../../../models/booking_model.dart';
import '../../../models/update_model.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/enable_scroll_options.dart';
import '../../../services/in_app_services.dart/language.dart';
import '../../../utlis/image_utlis.dart';
import '../../../utlis/string_utlis.dart';
import '../../animations/enter_animation.dart';
import '../../general_widgets/buttons/booking_button.dart';
import '../../general_widgets/custom_widgets/custom_container.dart';
import '../../general_widgets/custom_widgets/sliding_bottom_sheet.dart';

// ignore: must_be_immutable
class Buisness extends StatefulWidget {
  static Booking? firstBooking;
  static Update? firstUpdate;
  static bool editMode = false;
  final BookingButton bookingButton;
  final ScrollController? businessPageController;

  const Buisness(
      {Key? key, required this.bookingButton, this.businessPageController})
      : super(key: key);
  @override
  State<Buisness> createState() => _BuisnessState();
}

class _BuisnessState extends State<Buisness> {
  late String name, time, text, workerName, date;

  Intro? intro = null;
  @override
  void initState() {
    super.initState();

    widget.businessPageController!.addListener(() {
      ScreensData.homeScrollControllerOffset =
          widget.businessPageController!.offset;
    });
  }

  @override
  void dispose() {
    ScreensData.buisnessInit = true;
    //widget.businessPageController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isNeedReminder();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      popReminder();
      await overLaysHandling();
      if (widget.businessPageController!.hasClients) {
        widget.businessPageController!
            .jumpTo(ScreensData.homeScrollControllerOffset);
      }
    });

    return GestureDetector(
      onLongPress: () {
        if (UserData.getPermission() < 1) {
          return;
        }
        if (!SettingsData.workers.containsKey(UserData.user.phoneNumber)) {
          return;
        }
        //vibrate(miliseconds: 3, amplitude: 256);
        setState(() {
          Buisness.editMode = !Buisness.editMode;
          if (!Buisness.editMode) {
            onExistEditMode();
          }
        });
      },
      child: Stack(children: [
        CustomScrollView(
            scrollBehavior: EnableScrollOptions(),
            key: const PageStorageKey<String>("BusinessPage"),
            controller: widget.businessPageController,
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: changingImagesHeight,
                toolbarHeight: changingImagesHeight * 0.32,
                stretchTriggerOffset: 150,
                onStretchTrigger: () async {
                  return;
                },
                stretch: true,
                actions: ApplicationLocalizations.of(context)!.isRTL()
                    ? [Spacer(), backButton(context)]
                    : [backButton(context), Spacer()],
                elevation: 0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(
                      bottom: 5), // remove default bottom padding
                  centerTitle: true,
                  stretchModes: [
                    StretchMode.zoomBackground,
                    //StretchMode.blurBackground,
                    StretchMode.fadeTitle
                  ],
                  background: PinchZoom(
                      resetDuration: const Duration(milliseconds: 100),
                      maxScale: 3,
                      onZoomStart: () {},
                      onZoomEnd: () {},
                      child: AnimatedImages(editMode: Buisness.editMode)),
                  title: shopIcon(),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  EnterAnimation(
                    paddingFromTop: 15,
                    animate: !ScreensData.buisnessInit,
                    childCreator: businessBody,
                  )
                ]),
              )
            ]),
        SettingsData.activeBusiness
            ? Positioned(
                right: 10,
                top: 20,
                child: SafeArea(
                    child: Column(
                  children: [
                    editbutton(),
                    Buisness.firstBooking != null &&
                            UserData.isConnected() &&
                            SettingsData.activeBusiness
                        ? reminderNavigator()
                        : SizedBox(),
                  ],
                )))
            : SizedBox(),
        Positioned(
            right: 0, bottom: gHeight * 0.1, child: widget.bookingButton),
      ]),
    );
  }

  void onExistEditMode() {
    //delete all story images that marked
    Story.imagesToDelete = {};
    if (BusinessName.nameField.contentValid &&
        BusinessName.nameField.contentController.text !=
            SettingsData.settings.shopName) {
      SettingsData.settings.shopName =
          BusinessName.nameField.contentController.text;
      context
          .read<SettingsProvider>()
          .updateShopName(BusinessName.nameField.contentController.text);
    }
  }

  Widget editbutton() {
    if (UserData.getPermission() < 1) {
      return SizedBox();
    }
    if (!SettingsData.workers.containsKey(UserData.user.phoneNumber)) {
      return SizedBox();
    }
    return Opacity(
      opacity: Buisness.editMode ? 1 : .5,
      child: GestureDetector(
        onTap: () async {
          setState(() {
            Buisness.editMode = !Buisness.editMode;
            if (!Buisness.editMode) {
              onExistEditMode();
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            alignment: Alignment.center,
            width: 35,
            height: 35,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.background),
            child: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.secondary,
              size: 25,
            ),
          ),
        ),
      ),
    );
  }

  Widget businessBody(BuildContext context) {
    return Column(children: [
      BusinessName(),
      expiredBusinessIndicator(),
      //CrewMembering(),
      SizedBox(
        height: 60,
      ),
      Updates(
        editMode: Buisness.editMode,
        intro: intro,
      ),
      SizedBox(
        height: 100,
      ),
      Story(
        editMode: Buisness.editMode,
        intro: intro,
      ),
      SizedBox(height: 30),
      Products(editMode: Buisness.editMode),
      AppIcons(
        editMode: Buisness.editMode,
        intro: intro,
      ),
      SizedBox(
        height: gHeight * .1,
      )
    ]);
  }

  Widget welcome(BuildContext context) {
    String userName = UserData.user.name;
    if (userName == "guest") userName = translate("guest");
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: RichText(
        text: TextSpan(
          text: translate('hey') + " ",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
                text: userName,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary)),
            TextSpan(text: ", " + translate('welcome')),
          ],
        ),
      ),
    );
  }

  Widget shopIcon() {
    return SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            SizedBox(
              height: gDiagnol * 0.07,
              width: gDiagnol * 0.07,
              child: PickCircleImage(
                  showDelete: false,
                  showEdit: false,
                  enableCircleEdit:
                      Buisness.editMode && UserData.getPermission() == 2,
                  needLoad: UserData.getPermission() == 2 &&
                      SettingsData.activeBusiness,
                  upload: uploadImage,
                  radius: gDiagnol * 0.07,
                  currentImage: showCircleCachedImage(
                      SettingsData.settings.shopIconUrl,
                      gDiagnol * 0.07,
                      SettingsData.businessIcon!)),
            ),
            SettingsData.activeBusiness &&
                    SettingsData.businessSubtype != SubType.basic
                ? SubscribeIndicator()
                : SizedBox(),
          ],
        ));
  }

  void isNeedReminder() {
    Buisness.firstBooking = null;
    final userBookings = UserData.user.bookings.values.toList();
    for (final booking in userBookings) {
      if (booking.buisnessId == SettingsData.appCollection &&
          booking.status == BookingStatuses.approved &&
          (Buisness.firstBooking == null ||
              booking.bookingDate
                  .isBefore(Buisness.firstBooking!.bookingDate))) {
        Buisness.firstBooking = booking;
      }
    }

    if (Buisness.firstBooking != null) {
      final todayDateKey = DateFormat('dd-MM-yyyy').format(DateTime.now());

      final bookingDate =
          DateFormat('dd-MM-yyyy').format(Buisness.firstBooking!.bookingDate);
      //only when ordder is today
      if (bookingDate != todayDateKey) Buisness.firstBooking = null;
    }
  }

  void popReminder() {
    if (!ScreensData.buisnessInit &&
        Buisness.firstBooking != null &&
        SettingsData.activeBusiness) {
      showReminderSheet();
      ScreensData.buisnessInit = true;
    }
    AppThemeData.themeCauseMainBuilt = false;
  }

  void showReminderSheet() {
    SlidingBottomSheet(
      context: context,
      sheet: Reminder(),
      size: 1,
    ).showSheet();
  }

  Widget reminderNavigator() {
    return GestureDetector(
      onTap: () => showReminderSheet(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: Container(
          child: Lottie.asset(attentionAnimation,
              height: gHeight * 0.06, width: gHeight * 0.06, repeat: false),
        ),
      ),
    );
  }

  Widget expiredBusinessIndicator() {
    return SettingsData.isPassedLimit() || !SettingsData.activeBusiness
        ? CustomContainer(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            margin: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Column(
              children: [
                !SettingsData.activeBusiness || SettingsData.isPassedLimit()
                    ? Text(
                        translate('unavailableBuisness'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      )
                    : SizedBox(),
                UserData.getPermission() != 0 &&
                        SettingsData.limitionPassed
                            .contains(BuisnessLimitations.workers)
                    ? UserData.getPermission() == 2
                        ? Text(
                            translate('passWorkerLimitForManager'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          )
                        : Text(
                            translate('passWorkerLimitForWorker'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          )
                    : SizedBox(),
                UserData.getPermission() != 0 &&
                        SettingsData.limitionPassed
                            .contains(BuisnessLimitations.products)
                    ? UserData.getPermission() == 2
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              translate('passProductLimitForManager'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              translate('passProductLimitForWorker'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          )
                    : SizedBox(),
                UserData.getPermission() != 0 &&
                        SettingsData.limitionPassed
                            .contains(BuisnessLimitations.storyPhotos)
                    ? UserData.getPermission() == 2
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              translate('passStoryLimitForManager'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              translate('passStoryLimitForWorker'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          )
                    : SizedBox(),
                UserData.getPermission() != 0 &&
                        SettingsData.limitionPassed
                            .contains(BuisnessLimitations.changingPhotos)
                    ? UserData.getPermission() == 2
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              translate('passChangingImagesLimitForManager'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              translate('passChangingImagesLimitForWorker'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          )
                    : SizedBox()
              ],
            ),
          )
        : SizedBox();
  }
}
