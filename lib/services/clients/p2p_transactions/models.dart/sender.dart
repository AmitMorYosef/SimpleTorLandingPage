/* 
"sender": {
       "first_name": "John",
        "last_name": "Doe",
        "address": "123 First Street",
        "city": "Anytown",
        "state": "NY",
        "date_of_birth": "22/02/1980",
        "postcode": "12345",
        "phonenumber": "621212938122",
        "remitter_account_type": "Individual",
        "source_of_income": "salary",
        "identification_type": "License No",
        "identification_value": "123456789",
        "purpose_code": "ABCDEFGHI",
        "account_number": "123456789",
        "beneficiary_relationship": "client" 
    },
*/
class Sender {
  String first_name,
      last_name,
      address,
      city, //: "+14155551234",
      state, //: "johndoe1@rapyd.net",
      date_of_birth, //: "11/22/2000",
      postcode,
      phonenumber, //: "Doe",
      remitter_account_type, //: "Jane Smith",
      source_of_income, //: "personal",
      identification_type, //: "PA", // type of legal id (passport, id, driver)
      identification_value, //": "1234567890", // the id (driver, passport..)
      purpose_code, //": "US",
      account_number,
      beneficiary_relationship; //"client"

  Sender({
    required this.first_name,
    required this.last_name,
    required this.address,
    required this.city,
    required this.state,
    required this.date_of_birth,
    required this.postcode,
    required this.phonenumber,
    required this.identification_type,
    required this.identification_value,
    required this.account_number,
    this.purpose_code = 'ABCDEFGHI',
    this.beneficiary_relationship = 'account owner',
    this.source_of_income = 'salary',
    this.remitter_account_type = 'Individual',
  });

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
        first_name: json["first_name"],
        last_name: json["last_name"],
        address: json["address"],
        city: json["city"],
        state: json["state"],
        date_of_birth: json["date_of_birth"],
        postcode: json["postcode"],
        phonenumber: json["phonenumber"],
        identification_type: json["identification_type"],
        identification_value: json["identification_value"],
        account_number: json["account_number"],
        purpose_code: json["purpose_code"],
        beneficiary_relationship: json["beneficiary_relationship"],
        source_of_income: json["source_of_income"],
        remitter_account_type: json["remitter_account_type"],
      );

  Map<String, dynamic> toJson() => {
        "first_name": first_name,
        "last_name": last_name,
        "address": address,
        "city": city,
        "state": state,
        "date_of_birth": date_of_birth,
        "postcode": postcode,
        "phonenumber": phonenumber,
        "identification_type": identification_type,
        "identification_value": identification_value,
        "account_number": account_number,
        "purpose_code": purpose_code,
        "beneficiary_relationship": beneficiary_relationship,
        "source_of_income": source_of_income,
        "remitter_account_type": remitter_account_type,
      };
}
