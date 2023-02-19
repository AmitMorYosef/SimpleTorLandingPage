import 'package:simple_tor_web/services/clients/p2p_transactions/make_request.dart';
import 'package:simple_tor_web/services/clients/p2p_transactions/models.dart/address.dart';
import 'package:simple_tor_web/services/clients/p2p_transactions/models.dart/beneficiary.dart';
import 'package:simple_tor_web/services/clients/p2p_transactions/models.dart/contact.dart';
import 'package:simple_tor_web/services/clients/p2p_transactions/models.dart/payout.dart';
import 'package:simple_tor_web/services/clients/p2p_transactions/models.dart/personal_wallet.dart';
import 'package:simple_tor_web/services/clients/p2p_transactions/models.dart/sender.dart';
import 'package:simple_tor_web/services/clients/p2p_transactions/models.dart/transfer.dart';
import 'package:uuid/uuid.dart';

class RapydClient {
  //final _baseURL = 'https://sandboxapi.rapyd.net';
  MakeRequest _makeRequest = MakeRequest();
  Uuid uuid = Uuid();

  Future<Transfer?> transferMoney({
    required String sourceWallet,
    required String destinationWallet,
    required int amount,
  }) async {
    /* 
    Using to request tranfer money between users' wallets 
    */
    Transfer? transferDetails;
    var method = "post";
    var transferEndpoint = '/v1/account/transfer';

    var body = {
      "source_ewallet": sourceWallet,
      "amount": amount,
      "currency": "EUR",
      "destination_ewallet": destinationWallet,
    };

    dynamic jsonBody = await _makeRequest.performRequst(
        endpoint: transferEndpoint, body: body, method: method);

    transferDetails = jsonBody == {} ? null : Transfer.fromJson(jsonBody);

    return transferDetails;
  }

  Future<Transfer?> transferResponse({
    required String id,
    required String response,
  }) async {
    /* 
    Using to confirm the transaction after requsting
    */
    Transfer? transferDetails;

    var method = "post";
    var responseEndpoint = '/v1/account/transfer/response';

    Map<String, dynamic> body = {
      "id": id,
      "status": response,
    };
    dynamic jsonBody = await _makeRequest.performRequst(
        endpoint: responseEndpoint, body: body, method: method);

    transferDetails = jsonBody == {} ? null : Transfer.fromJson(jsonBody);

    return transferDetails;
  }

  Future<Map<String, dynamic>> createWallet(
      {required String first_name,
      required String last_name,
      required String line_1,
      required String city,
      required String state,
      required String country,
      required String zip,
      required String phone_number,
      required String email,
      required String identification_type,
      required String identification_number,
      required String date_of_birth}) async {
    Address address = Address(
        name: "$first_name $last_name",
        line_1: line_1,
        city: city,
        state: state,
        country: country,
        zip: zip,
        phone_number: phone_number);

    Contact contact = Contact(
        phone_number: phone_number,
        email: email,
        first_name: first_name,
        last_name: last_name,
        identification_type: identification_type,
        identification_number: identification_number,
        date_of_birth: date_of_birth,
        country: country,
        address: address);

    PersonalWallet personalWallet = PersonalWallet(
        first_name: first_name,
        last_name: last_name,
        email: email,
        ewallet_reference_id: uuid.v1(),
        phone_number: phone_number,
        contact: contact);

    var method = "post";
    var responseEndpoint = '/v1/user';

    Map<String, dynamic> body = personalWallet.toJson();
    dynamic jsonBody = await _makeRequest.performRequst(
        endpoint: responseEndpoint, body: body, method: method);

    return jsonBody;
  }

  Future<Map<String, dynamic>> retriveWallet({required String ewallet}) async {
    var method = "get";
    var responseEndpoint = '/v1/user/$ewallet';

    dynamic jsonBody = await _makeRequest.performRequst(
        endpoint: responseEndpoint, body: {}, method: method);

    return jsonBody;
  }

  Future<Map> createCheckoutPage({
    required int amount,
    required String currency,
    required String country,
    required String ewallet,
  }) async {
    var method = "post";
    var responseEndpoint = '/v1/checkout';

    String cancel_url = "https://www.rapyd.net/cancel";
    Map<String, String> body = {
      "amount": amount.toString(),
      "currency": currency, // ILS
      "country": country, // IL
      "ewallet": ewallet,
      "complete_checkout_url": cancel_url,
      "cancel_checkout_url": cancel_url
    };

    //making post request with headers and body.
    Map<String, dynamic> jsonBody = await _makeRequest.performRequst(
        endpoint: responseEndpoint, method: method, body: body);

    //return data if request was successful
    if (jsonBody.containsKey("data")) {
      return jsonBody["data"] as Map;
    }
    return {};
  }

  Future<Map> getRequiredFields() async {
    String payout_method_type = 'us_general_bank';
    String beneficiary_country = 'US';
    String sender_country = 'US';
    String beneficiary_entity_type = 'individual';
    String sender_entity_type = 'individual';
    int payout_amount = 251;
    String payout_currency = 'USD';
    String sender_currency = 'USD';
    var method = "get";
    var responseEndpoint =
        '/v1/payouts/${payout_method_type}/details?beneficiary_country=${beneficiary_country}&beneficiary_entity_type=${beneficiary_entity_type}&payout_amount=${payout_amount}&payout_currency=${payout_currency}&sender_country=${sender_country}&sender_currency=${sender_currency}&sender_entity_type=${sender_entity_type}';
    Map<String, dynamic> body = {}; //payout.toJson();

    //making post request with headers and body.
    Map<String, dynamic> jsonBody = await _makeRequest.performRequst(
        endpoint: responseEndpoint, method: method, body: body);
    //return data if request was successful
    return jsonBody;
  }

  Future<Map> getListPayoutMethodTypes() async {
    String payoutCurrency = "USD"; //'ILS';
    var method = "get";
    var responseEndpoint =
        '/v1/payouts/supported_types?&payout_currency=${payoutCurrency}&limit=20';
    Map<String, dynamic> body = {}; //payout.toJson();

    //making post request with headers and body.
    Map<String, dynamic> jsonBody = await _makeRequest.performRequst(
        endpoint: responseEndpoint, method: method, body: body);
    //return data if request was successful
    return jsonBody;
  }

  Future<Map> payoutToBankAccount(
      {required String first_name,
      required String last_name,
      required String aba,
      required String address,
      required String postcode,
      required String city,
      required String state,
      required String country,
      required String phonenumber,
      required String email,
      required String identification_type,
      required String identification_value,
      required String date_of_birth,
      required String account_number,
      required String bank_name,
      required String bic_swift,
      required String ach_code,
      required String merchant_reference_id,
      required String ewallet,
      required String payout_amount,
      required String payout_currency,
      required String payout_method_type,
      required String sender_currency}) async {
    var method = "post";
    var responseEndpoint = '/v1/payouts';
    // create the sender object
    Sender sender = Sender(
        first_name: first_name,
        last_name: last_name,
        address: address,
        city: city,
        state: state,
        date_of_birth: date_of_birth,
        postcode: postcode,
        phonenumber: phonenumber,
        identification_type: identification_type,
        identification_value: identification_value,
        account_number: account_number);
    // create the beneficiary object
    Beneficiary beneficiary = Beneficiary(
        first_name: first_name,
        last_name: last_name,
        aba: aba,
        address: address,
        email: email,
        country: country,
        city: city,
        postcode: postcode,
        state: state,
        account_number: account_number,
        bank_name: bank_name,
        identification_type: identification_type,
        identification_value: identification_value,
        bic_swift: bic_swift,
        ach_code: ach_code);
    // create the payout object
    Payout payout = Payout(
        beneficiary_country: country,
        merchant_reference_id: merchant_reference_id,
        ewallet: ewallet,
        payout_amount: payout_amount,
        payout_currency: payout_currency,
        payout_method_type: payout_method_type,
        sender_country: country,
        sender_currency: sender_currency,
        beneficiary: beneficiary,
        sender: sender);

    //making post request with headers and body.
    Map<String, dynamic> jsonBody = await _makeRequest.performRequst(
        endpoint: responseEndpoint, method: method, body: payout.toJson());

    return jsonBody;
  }
}
