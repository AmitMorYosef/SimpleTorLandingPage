import 'dart:async';

import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription s;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: () async {
            //w();
            //s.cancel();
            // String change =
            //     context.read<ThemeProvider>().currentKeyTheme == "בהיר"
            //         ? "כהה"
            //         : "בהיר";
            // context.read<ThemeProvider>().changeTheme(context, change);
            // var cancellableOperation = CancelableOperation.fromFuture(
            //   w(),
            //   onCancel: () => "onCancel",
            // );

            // cancellableOperation
            //     .cancel(); // uncomment this to test cancellation
            // setState(() {});

            // cancellableOperation.value.then((value) => {
            //       debugPrint('then: $value'),
            //     });
            // cancellableOperation.value.whenComplete(() => {
            //       debugPrint('onDone'),
            //     });

            // Future f = Future.delayed(Duration(seconds: 3))
            //     .then((value) => print("hey!!"));
            // f.timeout(
            //   Duration(seconds: 1),
            //   onTimeout: () => f.ignore(),
            // );
          },
          child: Text("push"),
        ),
        color: Colors.red,
      ),
    );
  }
}
