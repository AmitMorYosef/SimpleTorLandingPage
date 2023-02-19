/*
      "beneficiary_country": "US",
      "beneficiary_entity_type": "individual",
      "description": "Payout - Bank Transfer: Beneficiary/Sender objects",
      "merchant_reference_id": "96024440-8f50-11ed-982f-9f0be6376cd1",
      "ewallet": "ewallet_4daf9924fe9f2d3206c0ffc5640e5add",
      "payout_amount": "1",
      "payout_currency": "USD",
      "payout_method_type": "us_general_bank",
      "sender_country": "US",
      "sender_currency": "USD",
      "sender_entity_type": "individual",
      "statement_descriptor": "GHY* Limited Access 800-123-4567",
      "metadata": {"merchant_defined": true}
 */

class BankDetails {
  String first_name,
      last_name,
      aba,
      address,
      postcode,
      city,
      state,
      country,
      phonenumber,
      email,
      identification_type,
      identification_value,
      date_of_birth,
      account_number,
      bank_name,
      bic_swift,
      ach_code,
      merchant_reference_id,
      //payout_currency,
      payout_method_type,
      sender_currency;
  BankDetails({
    required this.first_name,
    required this.last_name,
    required this.aba,
    required this.address,
    required this.postcode,
    required this.city,
    required this.state,
    required this.country,
    required this.phonenumber,
    required this.email,
    required this.identification_type,
    required this.identification_value,
    required this.date_of_birth,
    required this.account_number,
    required this.bank_name,
    required this.bic_swift,
    required this.ach_code,
    required this.merchant_reference_id,
    required this.payout_method_type,
    required this.sender_currency,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) => BankDetails(
        first_name: json["first_name"],
        last_name: json["last_name"],
        aba: json["aba"],
        address: json["address"],
        postcode: json["postcode"],
        city: json["city"],
        state: json["state"],
        country: json["country"],
        phonenumber: json["phonenumber"],
        email: json["email"],
        identification_type: json["identification_type"],
        identification_value: json["identification_value"],
        date_of_birth: json["date_of_birth"],
        account_number: json["account_number"],
        bank_name: json["bank_name"],
        bic_swift: json["bic_swift"],
        ach_code: json["ach_code"],
        merchant_reference_id: json["merchant_reference_id"],
        payout_method_type: json["payout_method_type"],
        sender_currency: json["sender_currency"],
      );

  Map<String, dynamic> toJson() => {
        "first_name": first_name,
        "last_name": last_name,
        "aba": aba,
        "address": address,
        "postcode": postcode,
        "city": city,
        "state": state,
        "country": country,
        "phonenumber": phonenumber,
        "email": email,
        "identification_type": identification_type,
        "identification_value": identification_value,
        "date_of_birth": date_of_birth,
        "account_number": account_number,
        "bank_name": bank_name,
        "bic_swift": bic_swift,
        "ach_code": ach_code,
        "merchant_reference_id": merchant_reference_id,
        "payout_method_type": payout_method_type,
        "sender_currency   ": sender_currency,
      };
}