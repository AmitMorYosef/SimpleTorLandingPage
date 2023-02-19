import 'package:flutter/material.dart';
import 'package:management_system_app/app_statics.dart/user_data.dart';
import 'package:management_system_app/ui/pages/search_page/widgets/connected.dart';
import 'package:management_system_app/ui/pages/search_page/widgets/not_connected.dart';

// ignore: must_be_immutable
class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: false,
        child: !UserData.isConnected() ? NotConnectedPage() : ConnectedPage());
  }
}
