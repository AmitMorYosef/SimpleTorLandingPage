import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../app_statics.dart/general_data.dart';
import '../../../../../server_variables.dart';

class BusinessQr extends StatelessWidget {
  final double? size;
  const BusinessQr({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    String url = 'https://$SERVER_BASE_URL/$BUSINESS_LINK_END_POINT';
    return SizedBox(
      height: 150,
      width: 150,
      child: QrImage(
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        backgroundColor: Theme.of(context).colorScheme.background,
        data: url.replaceAll("BUISNESS_ID", GeneralData.currentBusinesssId),
        version: QrVersions.auto,
        size: size ?? 200.0,
      ),
    );
  }
}
