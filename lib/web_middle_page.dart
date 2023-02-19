import 'package:flutter/material.dart';
import 'package:simple_tor_web/ui/load_app.dart' deferred as appLoader;

class MiddlePage extends StatelessWidget {
  const MiddlePage({super.key});
  static bool appIsLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder(
      future: appLoader.loadLibrary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting ||
            appIsLoaded) {
          appIsLoaded = true;
          return appLoader.LoadApp();
        }
        return Container(color: Colors.blue);
      },
    )
        //  ElevatedButton(
        //     onPressed: () async {
        //       await appLoader.loadLibrary();
        //       Navigator.push(context,
        //           MaterialPageRoute(builder: (_) => appLoader.LoadApp()));
        //     },
        //     child: Text("push")),
        );
  }
}
