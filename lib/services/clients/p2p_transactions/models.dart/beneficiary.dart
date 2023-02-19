/*
    "beneficiary": {
        "first_name": "Jane",
        "last_name": "Doe",
        "aba": "123456789",
        "payment_type": "regular",
        "address": "456 Second Street",
        "email": "janedoe@rapyd.net",
        "country": "US",
        "city": "Anytown",
        "postcode": "10101",
        "account_number": "BG96611020345678",
        "bank_name": "US General Bank",
        "state": "NY",
        "identification_type": "SSC",
        "identification_value": "123456789",
        "bic_swift": "BUINBGSF",
        "ach_code": "123456789"
       },
 */

class Beneficiary {
  String first_name,
      last_name,
      aba,
      address,
      email,
      country,
      city, //: "+14155551234",
      postcode,
      state, //: "johndoe1@rapyd.net",
      account_number,
      bank_name, //: "11/22/2000",
      identification_type, //: "PA", // type of legal id (passport, id, driver)
      identification_value, //": "1234567890", // the id (driver, passport..)
      bic_swift, //": "US",
      ach_code,
      payment_type; //"client"

  Beneficiary(
      {required this.first_name,
      required this.last_name,
      required this.aba,
      required this.address,
      required this.email,
      required this.country,
      required this.city,
      required this.postcode,
      required this.state,
      required this.account_number,
      required this.bank_name,
      required this.identification_type,
      required this.identification_value,
      required this.bic_swift,
      required this.ach_code,
      this.payment_type = "regular"});

  factory Beneficiary.fromJson(Map<String, dynamic> json) => Beneficiary(
      first_name: json["first_name"],
      last_name: json["last_name"],
      aba: json["aba"],
      address: json["address"],
      city: json["city"],
      state: json["state"],
      country: json["country"],
      postcode: json["postcode"],
      email: json["email"],
      identification_type: json["identification_type"],
      identification_value: json["identification_value"],
      account_number: json["account_number"],
      bank_name: json["bank_name"],
      bic_swift: json["bic_swift"],
      ach_code: json["ach_code"],
      payment_type: json["payment_type"]);

  Map<String, dynamic> toJson() => {
        "first_name": first_name,
        "last_name": last_name,
        "aba": aba,
        "address": address,
        "city": city,
        "state": state,
        "country": country,
        "postcode": postcode,
        "email": email,
        "identification_type": identification_type,
        "identification_value": identification_value,
        "account_number": account_number,
        "bank_name": bank_name,
        "bic_swift": bic_swift,
        "ach_code": ach_code,
        "payment_type": payment_type
      };
}
