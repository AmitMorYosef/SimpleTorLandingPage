import 'package:flutter/material.dart';
import 'package:simple_tor_web/ui/checkout_page.dart';

import '../app_const/app_sizes.dart';
import '../services/clients/p2p_transactions/rapyd_client.dart';
import 'general_widgets/custom_widgets/custom_container.dart';

class TransactionCard extends StatefulWidget {
  final String sourceWalletId;
  final String destinationWalletId;
  TransactionCard(
      {super.key,
      required this.destinationWalletId,
      required this.sourceWalletId});

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  RapydClient _rapydClient = RapydClient();
  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      width: gWidth * .8,
      height: 300,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(),
            Text("500"),
            ElevatedButton(
                onPressed: () => // getWallet() // payoutMoeny()
                    goToCheckOut() // createWallet() //_performTransaction()
                ,
                child: Text("Pay"))
          ]),
    );
  }

  Future<void> getWallet() async {
    _rapydClient.retriveWallet(
        ewallet: "ewallet_4daf9924fe9f2d3206c0ffc5640e5add");
  }

  Future<void> _performTransaction() async {
    // Retrieve the amount
    int amount = 1;

    // Process the transaction
    var transactionInfo = await _rapydClient.transferMoney(
      amount: amount,
      sourceWallet: widget.sourceWalletId,
      destinationWallet: widget.destinationWalletId,
    );

    // Confirm the transaction
    var updatedInfo = await _rapydClient.transferResponse(
        id: transactionInfo!.data.id, response: 'accept');

    // Update the attachment
  }

  void createWallet() async {
    var info = await _rapydClient.createWallet(
        first_name: 'John',
        last_name: 'Doe',
        line_1: "123 Main Street",
        city: "Anytown",
        state: "NY",
        country: "US",
        zip: "123456",
        phone_number: "+14155551234",
        email: "johndoe1@rapyd.net",
        identification_type: "PA",
        identification_number: "1234567890",
        date_of_birth: "11/22/2000");
    print(info);
  }

  void payoutMoeny() async {
    var info = await _rapydClient.payoutToBankAccount(
        first_name: 'John',
        last_name: 'Doe',
        address: "123 Main Street",
        postcode: "123456",
        city: "Anytown",
        state: "NY",
        country: "US",
        phonenumber: "+14155551234",
        email: "johndoe1@rapyd.net",
        identification_type: "SSC",
        identification_value: "123456789",
        date_of_birth: "22/02/1980", //"11/22/2000",
        account_number: "BG96611020345678",
        bank_name: "US General Bank",
        bic_swift: "BUINBGSF",
        ach_code: "123456789",
        merchant_reference_id: "96024440-8f50-11ed-982f-9f0be6376cd1",
        ewallet: "ewallet_4daf9924fe9f2d3206c0ffc5640e5add",
        payout_amount: "1",
        payout_currency: "USD",
        payout_method_type: "us_general_bank",
        sender_currency: "USD",
        aba: '123456789');

    print(info);
  }

  void goToCheckOut() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CheckOutScreen()));
  }
}
