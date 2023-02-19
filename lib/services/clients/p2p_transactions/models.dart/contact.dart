//         "address": {
//             "name": "John Doe",
//             "line_1": "123 Main Street",
//             "line_2": "",
//             "line_3": "",
//             "city": "Anytown",
//             "state": "NY",
//             "country": "US",
//             "zip": "12345",
//             "phone_number": "+14155551234",
//             "metadata": {},
//             "canton": "",
//             "district": ""
//  },
//
//
//     }

import 'package:simple_tor_web/services/clients/p2p_transactions/models.dart/address.dart';

class Contact {
  String phone_number, //: "+14155551234",
      email, //: "johndoe1@rapyd.net",
      first_name, //: "John",
      last_name, //: "Doe",
      mothers_name, //: "Jane Smith",
      contact_type, //: "personal",
      identification_type, //: "PA", // type of legal id (passport, id, driver)
      identification_number, //": "1234567890", // the id (driver, passport..)
      date_of_birth, //: "11/22/2000",
      country; //": "US",
  Address address;
  Map<String, dynamic> metadata; //{"merchant_defined": true};

  Contact({
    required this.phone_number,
    required this.email,
    required this.first_name,
    required this.last_name,
    required this.identification_type,
    required this.identification_number,
    required this.date_of_birth,
    required this.country,
    required this.address,
    this.mothers_name = '',
    this.contact_type = 'personal',
    this.metadata = const {},
  });

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        phone_number: json["phone_number"],
        email: json["email"],
        first_name: json["first_name"],
        last_name: json["last_name"],
        identification_type: json["identification_type"],
        identification_number: json["identification_number"],
        date_of_birth: json["date_of_birth"],
        country: json["country"],
        mothers_name: json["mothers_name"],
        contact_type: json["contact_type"],
        metadata: json["metadata"],
        address: Address.fromJson(json["address"]),
      );

  Map<String, dynamic> toJson() => {
        "phone_number": phone_number,
        "email": email,
        "first_name": first_name,
        "last_name": last_name,
        "mothers_name": mothers_name,
        "identification_type": identification_type,
        "identification_number": identification_number,
        "date_of_birth": date_of_birth,
        "country": country,
        "contact_type": contact_type,
        "metadata": metadata,
        "address": address.toJson()
      };
}
