import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services/clients/p2p_transactions/rapyd_client.dart';

class CheckOutScreen extends StatefulWidget {
  RapydClient _rapydClient = RapydClient();

  CheckOutScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _CheckOutScreenState();
  }
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  late Future<Map> createdCheckoutPage;
  @override
  void initState() {
    super.initState();
    createdCheckoutPage = widget._rapydClient.createCheckoutPage(
        amount: 200,
        country: 'IL',
        currency: 'ILS',
        ewallet: 'ewallet_4daf9924fe9f2d3206c0ffc5640e5add');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          //leading: CustomBackButton(),
          title: const Align(
            child: Text("Checkout",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          backgroundColor: Colors.white,
          actions: const [
            SizedBox(
              width: 55,
            ),
          ],
          elevation: 0,
        ),
        body: FutureBuilder(
          future: createdCheckoutPage,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError) {
                  return const Center(child: Text('Some error occurred!'));
                } else {
                  WebViewController controller = WebViewController()
                    ..setJavaScriptMode(JavaScriptMode.unrestricted)
                    ..loadRequest(
                        Uri.parse(snapshot.data["redirect_url"].toString()))
                    ..setNavigationDelegate(NavigationDelegate(
                      onPageStarted: (url) {
                        //Exit webview widget once the current url matches either checkout completed or canceled urls
                        if (url
                            .contains(snapshot.data["complete_checkout_url"])) {
                          Navigator.pop(context);
                        } else if (url
                            .contains(snapshot.data["cancel_checkout_url"])) {
                          Navigator.pop(context);
                        }
                      },
                    ));
                  return WebViewWidget(
                    controller: controller,
                  );
                }
            }
          },
        ));
  }
}
