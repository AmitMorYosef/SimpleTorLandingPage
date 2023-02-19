import 'dart:math';

import 'package:flutter/material.dart';
import 'package:management_system_app/models/preview_model.dart';
import 'package:management_system_app/ui/pages/search_page/widgets/suggestion_item.dart';

import '../../../../app_const/limitations.dart';
import '../../../../app_statics.dart/settings_data.dart';

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return Hero(
      tag: Key("kkk"),
      child: Material(
        child: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            close(context, null);
          },
        ),
      ),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        //elevation: 10,
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.iconTheme,
      ),
      inputDecorationTheme: searchFieldDecorationTheme ??
          InputDecorationTheme(
            hintStyle: searchFieldStyle ?? theme.inputDecorationTheme.hintStyle,
            border: InputBorder.none,
          ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.background,
        width: double.infinity,
        height: double.infinity,
        child: itemsList(query, context));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return Container(
        color: Theme.of(context).colorScheme.background,
        width: double.infinity,
        height: double.infinity,
        child: itemsList(query, context));
  }

  Widget itemsList(String query, BuildContext context) {
    Map<String, Preview> buisnesses = SettingsData.buisnessesPreview.buisnesses;
    List<Preview> values = [];
    int max_in_search = max_search_items;
    if (query == "") {
      values = buisnesses.values.toList();
    } else {
      buisnesses.forEach((key, value) {
        if (value.name.toLowerCase().contains(query.toLowerCase()))
          values.add(value);
      });
      max_in_search = values.length;
    }
    return ListView.builder(
        itemCount: min(values.length, max_in_search),
        itemBuilder: ((context, index) {
          Preview value = values[index];
          return SuggestionItem(
            preview: value,
          );
        }));
  }
}
