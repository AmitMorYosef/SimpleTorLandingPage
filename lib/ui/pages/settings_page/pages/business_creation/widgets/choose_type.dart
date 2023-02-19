import 'package:flutter/material.dart';
import 'package:management_system_app/ui/general_widgets/pickers/search_bottom_sheet_picker.dart';
import 'package:management_system_app/ui/pages/settings_page/pages/business_creation/make_new_buisness.dart';

import '../../../../../../app_const/app_sizes.dart';
import '../../../../../../app_const/business_types.dart';
import '../../../../../../utlis/string_utlis.dart';

class ChooseType extends StatefulWidget {
  ChooseType({super.key});

  @override
  State<ChooseType> createState() => _ChooseTypeState();
}

class _ChooseTypeState extends State<ChooseType> {
  Map<String, BusinessesTypes> businessTypeInterpter = {};
  late SearchBotttomSheetPicker businessTypePicker;
  @override
  void initState() {
    super.initState();
    businessTypeInterpter = loadBusinessesTypesIntepeter();
    final businessesList = businessTypeInterpter.keys.toList();
    businessesList.sort();
    businessTypePicker = SearchBotttomSheetPicker(
        choosenItem:
            translate(businessTypeToStr[MakeNewBuisness.businessType]!),
        items: businessesList,
        title: translate("chooseBusinessType"));
    businessTypePicker.onChanged = setType;
    businessTypePicker.itemBuilder = singleItem;
  }

  void setType(String? type) {
    setState(() {
      if (type != null) {
        MakeNewBuisness.businessType = businessTypeInterpter[type]!;
      }
    });
  }

  Widget singleItem(BuildContext context, String item, bool isSelected) {
    final businessType = businessTypeInterpter[item];
    return Opacity(
      opacity: isSelected ? 0.5 : 1,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 10,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                item,
              ),
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn),
                child: Image.asset(
                  businessTypesToIcon[businessType]!,
                  width: 30,
                  height: 30,
                ),
              ),
            ]),
            Divider()
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn),
                child: Image.asset(
                  businessTypesToIcon[MakeNewBuisness.businessType]!,
                  width: gWidth * 0.34,
                  height: gWidth * 0.34,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                translate(businessTypeToStr[MakeNewBuisness.businessType]!),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 23),
              ),
              Container(
                alignment: Alignment.center,
                height: gHeight * 0.14,
                child: Text(
                  translate("typesExplain"),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.7)),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              businessTypePicker,
            ],
          ),
        ),
      ),
    );
  }
}
