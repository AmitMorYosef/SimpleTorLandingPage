import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:management_system_app/app_const/application_general.dart';
import 'package:management_system_app/providers/links_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../app_const/app_sizes.dart';
import '../../app_const/platform.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result; // the result of the scanning
  QRViewController? controller;
  bool stateAlive = true;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (isWeb) {
      return;
    }
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
      width: gWidth * .7,
      height: gWidth * .7,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
              borderColor: Theme.of(context).colorScheme.secondary,
              borderRadius: 20,
              borderLength: 20,
              borderWidth: 10,
              cutOutSize: gWidth * .7),
        ),
      ),
    );
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                  borderColor: Theme.of(context).colorScheme.secondary,
                  borderRadius: 20,
                  borderLength: 20,
                  borderWidth: 10,
                  cutOutSize: gWidth * .7),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text(
                      'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                  : Text('Scan a code'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      String businessId =
          context.read<LinksProvider>().getBuisnessId(scanData.code ?? '');
      if (businessId != '' && stateAlive) {
        // detecten businessId
        stateAlive = false; // not pop twice
        Navigator.pop(context, businessId);
        return;
      }

      // setState(() {
      //   result = scanData;
      // });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
