import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/settings_provider.dart';
import '../../general_widgets/buttons/booking_button.dart';
import '../buisness_page/buisness.dart';

// ignore: must_be_immutable
class Home extends StatelessWidget {
  bool sreen = true;
  late SettingsProvider settingsProvider;
  final BookingButton bookingButton;
  final ScrollController? businessPageController;
  Home({super.key, required this.bookingButton, this.businessPageController});

  @override
  Widget build(BuildContext context) {
    settingsProvider = context.watch<SettingsProvider>();

    return Buisness(
      businessPageController: businessPageController,
      bookingButton: this.bookingButton,
    );
  }
}
