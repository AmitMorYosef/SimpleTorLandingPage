//  "first_name": "John",
//     "last_name": "Doe",
//     "email": "",
//     "ewallet_reference_id": "John-Doe-02152020",
//     "metadata": {
//         "merchant_defined": True
//     },
//     "phone_number": "",
//     "type": "person",

import 'package:simple_tor_web/services/clients/p2p_transactions/models.dart/contact.dart';

class PersonalWallet {
  String first_name, //: "John",
      last_name, //: "Doe",
      email, //: "Jane Smith",
      ewallet_reference_id, //: "personal",
      phone_number, //: "PA",
      type; //": "1234567890",
  Map<String, dynamic> metadata; //{"merchant_defined": true};
  Contact contact;

  PersonalWallet({
    required this.first_name,
    required this.last_name,
    required this.email,
    required this.ewallet_reference_id,
    required this.phone_number,
    required this.contact,
    this.metadata = const {},
    this.type = "person",
  });

  factory PersonalWallet.fromJson(Map<String, dynamic> json) => PersonalWallet(
      first_name: json["first_name"],
      last_name: json["last_name"],
      email: json["email"],
      ewallet_reference_id: json["ewallet_reference_id"],
      phone_number: json["phone_number"],
      type: json["type"],
      metadata: json["metadata"],
      contact: Contact.fromJson(json["contact"]));

  Map<String, dynamic> toJson() => {
        "first_name": first_name,
        "last_name": last_name,
        "email": email,
        "ewallet_reference_id": ewallet_reference_id,
        "phone_number": phone_number,
        "type": type,
        "metadata": metadata,
        "contact": contact.toJson()
      };
}
