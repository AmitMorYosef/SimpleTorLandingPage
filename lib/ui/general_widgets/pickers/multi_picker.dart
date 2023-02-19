import 'package:flutter/material.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/ui/general_widgets/buttons/info_button.dart';
import 'package:management_system_app/utlis/string_utlis.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import '../../../app_const/app_sizes.dart';

class MultiplePicker {
  final Map<dynamic, String> items;
  final String infoText;
  final String title;
  List<dynamic> choosenItems;

  MultiplePicker(
      {required this.items,
      required this.choosenItems,
      required this.title,
      this.infoText = ""});

  Future<void> showPicker(BuildContext context) async {
    final _items = items.keys
        .map((itemValue) =>
            MultiSelectItem<dynamic>(itemValue, translate(items[itemValue]!)))
        .toList();

    await showModalBottomSheet(
      isScrollControlled: true, // required for min/max child size
      context: context,

      builder: (ctx) {
        return MultiSelectBottomSheet(
          items: _items,
          searchIcon: Icon(Icons.abc),
          title: Row(
            children: [
              SizedBox(
                width: gWidth * 0.05,
              ),
              Text(title),
              SizedBox(
                width: gWidth * 0.1,
              ),
              infoText != ""
                  ? infoButton(
                      context: context,
                      text: infoText,
                      padding: EdgeInsets.all(0))
                  : SizedBox()
            ],
          ),
          selectedColor: Theme.of(context).colorScheme.secondary,
          itemsTextStyle:
              Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 14),
          selectedItemsTextStyle: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(
                  fontSize: 14, color: Theme.of(context).colorScheme.secondary),
          cancelText: Text(translate("cancel")),
          confirmText: Text(translate("save")),
          initialValue: choosenItems,
          onConfirm: (values) {
            choosenItems = values;
          },
          maxChildSize: 0.4,
        );
      },
    );
  }
}
