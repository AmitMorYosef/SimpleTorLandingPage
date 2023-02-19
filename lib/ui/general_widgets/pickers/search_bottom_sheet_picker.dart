import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../../../utlis/string_utlis.dart';

class SearchBotttomSheetPicker extends StatelessWidget {
  Function(String?)? onChanged;
  List<String> items;
  String title;
  String? choosenItem;
  Widget Function(BuildContext, String, bool)? itemBuilder;

  SearchBotttomSheetPicker(
      {super.key,
      this.onChanged,
      this.itemBuilder,
      this.choosenItem,
      required this.title,
      required this.items});

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      items: items,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: title,
        ),
      ),
      selectedItem: choosenItem,
      popupProps: PopupProps.modalBottomSheet(
          title: Padding(
            padding: const EdgeInsets.all(0),
            child: Center(
                child: Text(
              title,
              style: TextStyle(fontSize: 22),
            )),
          ),
          showSearchBox: true,
          showSelectedItems: true,
          listViewProps:
              ListViewProps(padding: EdgeInsets.only(bottom: 25, top: 14)),
          searchDelay: Duration(microseconds: 0),
          itemBuilder: itemBuilder,
          searchFieldProps: TextFieldProps(
              decoration: InputDecoration(hintText: translate("search"))),
          modalBottomSheetProps: ModalBottomSheetProps(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface)),
      onChanged: onChanged,
    );
  }
}
