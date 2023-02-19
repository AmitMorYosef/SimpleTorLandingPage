import 'package:flutter/material.dart';
import 'package:management_system_app/app_const/application_general.dart';

import '../services/clients/p2p_transactions/rapyd_client.dart';

class PaymentsProvider extends ChangeNotifier {
  RapydClient _rapydClient = RapydClient();

  Future<void> performTransaction(
      {required String sourceWalletId,
      required String destinationWalletId,
      required int amount}) async {
    /*
    Uses the RapidClient to perform money transfaration
    between 2 rapid wallets 
    */

    // Process the transaction
    var transactionInfo = await _rapydClient.transferMoney(
      amount: amount,
      sourceWallet: sourceWalletId,
      destinationWallet: destinationWalletId,
    );

    // Confirm the transaction
    var updatedInfo = await _rapydClient.transferResponse(
        id: transactionInfo!.data.id, response: 'accept');

    // Update the attachment
    logger.d("---------------\n$updatedInfo\n--------------");
  }

  Future<bool> createWallet() async {
    /* 
    Uses the RapidClient to create "Rapid Wallet" for user
    request the relevant fields for the account creation
    */
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
    logger.d(info);
    return true;
  }

  Future<bool> payoutMoeny() async {
    /*
    Uses the RapidClient to transfer Rapid's wallet money 
    to the user bank account
     */
    var info1 = await _rapydClient.getListPayoutMethodTypes();
    print(info1);
    var info = await _rapydClient.payoutToBankAccount(
      first_name: 'John',
      last_name: 'Doe',
      address: "123 Main Street",
      postcode: "123456",
      city: "Anytown",
      state: "", //"NY",
      country: "IL", //"US",
      phonenumber: "+14155551234",
      email: "johndoe1@rapyd.net",
      identification_type: "SSC",
      identification_value: "123456789",
      date_of_birth: "22/02/1980", //"11/22/2000",
      account_number: "006449956988", //"BL96611020345678",
      bank_name: "Bank Transfer to Israel", //"US General Bank",
      bic_swift: "", //"BUINBGSF",
      ach_code: "", //"123456789",
      merchant_reference_id: "96024440-8f50-11ed-982f-9f0be6376cd1",
      ewallet: "ewallet_4daf9924fe9f2d3206c0ffc5640e5add",
      payout_amount: "1",
      payout_currency: "ILS", //"USD",
      payout_method_type: "il_general_bank", //us_general_bank
      sender_currency: "ILS", //"USD",
      aba: "", //'123456789'
    );

    logger.d(info);
    return true;
  }

  /*
  Uses the RapidClient to get the payout page with the currect wallet to
  get payed
  */
  Future<void> createCheckoutPage({
    required int amount,
    required String currency,
    required String country,
    required String ewallet,
  }) async {
    //  "amount": 200.toString(),
    //   "currency": "USD", // ILS
    //   "country": "US", // IL
    //   "ewallet": "ewallet_4daf9924fe9f2d3206c0ffc5640e5add",
    await _rapydClient.createCheckoutPage(
        amount: amount, country: country, currency: currency, ewallet: ewallet);
  }

  void updateScreen() => notifyListeners();
}
