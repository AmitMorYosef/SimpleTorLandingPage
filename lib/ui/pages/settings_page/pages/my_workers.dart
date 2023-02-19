import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:management_system_app/app_statics.dart/subscription_data.dart';
import 'package:management_system_app/models/worker_model.dart';
import 'package:management_system_app/providers/settings_provider.dart';
import 'package:management_system_app/ui/general_widgets/custom_widgets/custom_toast.dart';
import 'package:management_system_app/ui/general_widgets/dialogs/genral_dialog.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/load_products_widget.dart';
import 'package:management_system_app/ui/general_widgets/loading_widgets/loading_dialog.dart';
import 'package:management_system_app/ui/general_widgets/pickers/pick_phone_number.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:provider/provider.dart';

import '../../../../app_const/app_sizes.dart';
import '../../../../app_const/gender.dart';
import '../../../../app_const/purchases.dart';
import '../../../../app_const/resources.dart';
import '../../../../app_statics.dart/settings_data.dart';
import '../../../../app_statics.dart/user_data.dart';
import '../../../../models/purchase_offering.dart';
import '../../../../providers/manager_provider.dart';
import '../../../../utlis/image_utlis.dart';
import '../../../general_widgets/buttons/info_button.dart';
import '../../../general_widgets/custom_widgets/custom_container.dart';
import '../../../general_widgets/custom_widgets/sliding_bottom_sheet.dart';
import '../../../general_widgets/dialogs/general_delete_dialog.dart';
import '../../../general_widgets/pickers/subscription_picker.dart/choose_purchase_plan.dart';

// ignore: must_be_immutable
class MyWorkers extends StatelessWidget {
  MyWorkers({super.key});
  TextEditingController titleController = TextEditingController();
  ManagerProvider managerProvider = ManagerProvider();
  @override
  Widget build(BuildContext context) {
    managerProvider = context.read<ManagerProvider>();
    context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        actions: [
          infoButton(
              context: context, text: translate("hereYouEditYoursWorkers")),
          changePlans(context)
        ],
        elevation: 0,
        title: Text(translate("myWorkers")),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          children: [
            SettingsData.workers.length == 1
                ? Expanded(
                    child: Center(child: Text(translate("pressToAddWorkers"))))
                : Expanded(
                    child: SizedBox(
                      width: gWidth * .9,
                      child: ListView.builder(
                          itemCount: SettingsData.workers.length,
                          itemBuilder: ((context, index) {
                            final worker =
                                SettingsData.workers.values.elementAt(index);
                            return worker != null
                                ? workerItem(worker, context)
                                : SizedBox();
                          })),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SettingsData.settings.workersProductsId == "" ||
                          SettingsData.eligibleWorkerAmount >
                              SettingsData.workers.length - 1
                      ? IconButton(
                          onPressed: () async {
                            if (!SettingsData.isBusinessPublish()) {
                              SubscriptionData.init();

                              SlidingBottomSheet(
                                      context: context,
                                      sheet: LoadProductsWidget(
                                        childCreator: publishPlanSheet,
                                        isWorker: false,
                                      ),
                                      size: 1)
                                  .showSheet();
                              return;
                            }

                            if (SettingsData.eligibleWorkerAmount <=
                                SettingsData.workers.length - 1) {
                              SubscriptionData.init();

                              await SlidingBottomSheet(
                                      context: context,
                                      sheet: LoadProductsWidget(
                                        childCreator: purchasePlanSheet,
                                        isWorker: true,
                                      ),
                                      size: 1)
                                  .showSheet();
                              return;
                            }
                            dynamic resp = await showWorkerDialog(context);
                            if (resp == 'OK') {
                              Loading(
                                      navigator: Navigator.of(context),
                                      context: context,
                                      future: managerProvider.makeUserToWorker(
                                          PickPhoneNumber.completePhone,
                                          context),
                                      msg: translate("workerSuccessfullyAdded"),
                                      animation: successAnimation)
                                  .dialog();
                            }
                          },
                          icon: Icon(
                            Icons.add,
                          ),
                          iconSize: 40,
                        )
                      : SizedBox(),
                  SettingsData.settings.workersProductsId == "" ||
                          SettingsData.eligibleWorkerAmount >
                              SettingsData.workers.length - 1
                      ? Text(
                          SettingsData.eligibleWorkerAmount >
                                  SettingsData.workers.length - 1
                              ? translate("addWorker")
                              : translate("purchaseWorker"),
                          style: Theme.of(context).textTheme.titleLarge,
                        )
                      : SizedBox(),
                  Text(
                    translate("maxWorkers") +
                        ": " +
                        SettingsData.eligibleWorkerAmount.toString(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SettingsData.limitionPassed
                          .contains(BuisnessLimitations.workers)
                      ? SizedBox(
                          width: gWidth * 0.7,
                          child: Text(
                            translate("youPassedWorkerLimit"),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: Colors.red),
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 15,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget publishPlanSheet(BuildContext context) {
    final availableProducts =
        SubscriptionData.getAvailableProducts(type: "business");
    return CustomContainer(
        needImage: false,
        showBorder: false,
        geometryRadius: BorderRadius.all(Radius.circular(0)),
        boxBorder: Border.all(width: 0),
        color: Theme.of(context).colorScheme.surface,
        child: ChoosePurchasePlan(
          availableProducts: availableProducts,
          offerings: SubscriptionData.subTypeOfferings,
        ));
  }

  Widget changePlans(BuildContext context) {
    if (SettingsData.settings.workersProductsId == "") return SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 9),
      child: GestureDetector(
        onTap: () async {
          if (SettingsData.settings.pendingWorkersProductsId != "") {
            CustomToast(
                    context: context, msg: translate("alreadyHasSubPending"))
                .init();
            return;
          }

          SubscriptionData.init();

          await SlidingBottomSheet(
                  context: context,
                  sheet: LoadProductsWidget(
                    childCreator: changePlansSheet,
                    isWorker: true,
                  ),
                  size: 1)
              .showSheet();
          return;
        },
        child: Icon(
          Icons.change_circle,
          size: 30,
        ),
      ),
    );
  }

  Widget purchasePlanSheet(BuildContext context) {
    final availableProducts =
        SubscriptionData.getAvailableProducts(type: "worker");
    return CustomContainer(
        needImage: false,
        geometryRadius: BorderRadius.all(Radius.circular(0)),
        boxBorder: Border.all(width: 0),
        showBorder: false,
        color: Theme.of(context).colorScheme.surface,
        child: ChoosePurchasePlan(
          availableProducts: availableProducts,
          workerSubscription: true,
          offerings: SubscriptionData.workersOfferings,
        ));
  }

  Widget changePlansSheet(BuildContext context) {
    Map<String, PurchaseOffering> offeringForUse = {};
    SubscriptionData.workersOfferings.forEach((offeringId, offering) {
      if (offering.products
          .containsKey(SettingsData.settings.workersProductsId)) {
        offeringForUse = {offeringId: offering};
      }
    });
    return Container(
        color: Theme.of(context).colorScheme.surface,
        child: ChoosePurchasePlan(
          availableProducts: [],
          changePlan: true,
          productsToNotShow: SubscriptionData.alreadyPurchasedSubs,
          workerSubscription: true,
          offerings: offeringForUse,
        ));
  }

  Widget workerItem(WorkerModel worker, BuildContext context) {
    int bookinForToday = 0;
    final day = DateFormat('dd-MM-yyyy').format(DateTime.now());
    if (worker.bookingsTime.keys.contains(day))
      bookinForToday = worker.bookingsTime[day]!.length;
    return worker.phone == UserData.user.phoneNumber
        ? SizedBox()
        : CustomContainer(
            image: null,
            margin: EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                title(worker, context),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "${worker.phone}",
                  textDirection: TextDirection.ltr,
                  style: TextStyle(fontSize: 17),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(translate("todayBookings") +
                    ": " +
                    bookinForToday.toString()),
                IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      dynamic resp = await showMkeSureDialog(context, worker);
                      if (resp == true) {
                        if (worker.phone != PickPhoneNumber.completePhone) {
                          return;
                        }
                        await Loading(
                                context: context,
                                navigator: Navigator.of(context),
                                future: managerProvider.deleteWorker(
                                    PickPhoneNumber.completePhone,
                                    SettingsData.appCollection,
                                    context),
                                msg: translate("WorkerSuccessfullyDeleted"))
                            .dialog();
                      }
                    })
              ],
            ),
          );
  }

  Widget title(WorkerModel worker, BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomContainer(
        boxBorder: Border.all(color: Theme.of(context).colorScheme.tertiary),
        constraints: BoxConstraints(minWidth: gWidth * .5),
        image: null,
        color: Theme.of(context).colorScheme.tertiary,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        geometryRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${worker.name}",
              style: TextStyle(fontSize: 17),
            ),
            SizedBox(
              width: 10,
            ),
            showCircleCachedImage(
                worker.profileImg,
                gHeight * 0.04,
                worker.gender == Gender.female
                    ? defaultWomanImage
                    : defaultManImage)
          ],
        ),
      ),
    );
  }

  Widget getWorkerPhone(WorkerModel? worker, BuildContext context) {
    return SizedBox(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            worker != null
                ? Column(
                    children: [
                      Text(
                        translate("forMakeSureWorkerPhone"),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        worker.phone.toString(),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Text(
                    translate("toEnsurePutWorkerPhone"),
                    textAlign: TextAlign.center,
                  ),
            SizedBox(
              height: 10,
            ),
            PickPhoneNumber(
              showFlag: false,
              validate: () {
                if (PickPhoneNumber.completePhone != worker!.phone) {
                  return translate("noMatchPhoneNumbers");
                }
                return '';
              },
            )
          ],
        ),
      ),
    );
  }

  Future<dynamic> showWorkerDialog(BuildContext context) {
    return genralDialog(
      context: context,
      title: translate("addingWorker"),
      content: SizedBox(
          width: gWidth,
          child: PickPhoneNumber(
              showFlag: false)), //getWorkerPhone(null, context),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: Text(translate("cancel")),
        ),
        TextButton(
          onPressed: () {
            if (!PickPhoneNumber.validPhone) return;
            Navigator.pop(context, "OK");
          },
          child: Text(translate("save")),
        ),
      ],
    );
  }

  Future<dynamic> showMkeSureDialog(
      BuildContext context, WorkerModel worker) async {
    return await genralDeleteDialog(
      context: context,
      title: translate("deleteWorker"),
      content: getWorkerPhone(worker, context),
      onCancel: () => Navigator.pop(context, false),
      onDelete: () {
        if (worker.phone != PickPhoneNumber.completePhone) {
          return;
        }
        Navigator.pop(context, true);
      },
    );
  }
}
