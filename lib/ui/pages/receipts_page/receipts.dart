import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

import '../../../app_const/app_sizes.dart';
import '../../general_widgets/dialogs/genral_dialog.dart';

class Receipts extends StatelessWidget {
  const Receipts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        title: Text("הקבלות שלי"),
      ),
      floatingActionButton: addReceipt(context),
      body: Container(),
    );
  }

  Widget addReceipt(BuildContext context) {
    return GestureDetector(
      onTap: () => addReceiptDialg(context),
      child: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
            color: Color(0xff4E4E61).withOpacity(0.2),
            border: GradientBoxBorder(
              gradient: LinearGradient(colors: [
                Color(0xffFFFFFF).withOpacity(0.15),
                Color(0x000000).withOpacity(0.1)
              ]),
              width: 1,
            ),
            shape: BoxShape.circle),
        child: Icon(
          Icons.add,
          size: 40,
        ),
      ),
    );
  }

  void addReceiptDialg(BuildContext context) {
    genralDialog(
      context: context,
      title: "הוסף קבלה",
      content: newReceiptContent(),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'Cancel');
          },
          child: const Text('לא'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'OK');
            // we want only that the page go to my booking only for clients
          },
          child: const Text('כן'),
        ),
      ],
    );
  }

  Widget newReceiptContent() {
    return Container(
      width: gWidth,
      child: Text(""),
    );
  }
}
