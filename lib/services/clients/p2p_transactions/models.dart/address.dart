// "address": {
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
class Address {
  String name,
      line_1,
      line_2,
      line_3,
      city,
      state,
      country,
      zip,
      phone_number,
      canton,
      district;
  Map<String, dynamic> metadata;

  Address({
    required this.name,
    required this.line_1,
    required this.city,
    required this.state,
    required this.country,
    required this.zip,
    required this.phone_number,
    this.line_2 = '',
    this.line_3 = '',
    this.canton = '',
    this.district = '',
    this.metadata = const {},
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        name: json["name"],
        line_1: json["line_1"],
        city: json["city"],
        state: json["state"],
        country: json["country"],
        zip: json["zip"],
        phone_number: json["phone_number"],
        line_2: json["line_2"],
        line_3: json["line_3"],
        canton: json["canton"],
        district: json["district"],
        metadata: json["metadata"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "line_1": line_1,
        "city": city,
        "state": state,
        "country": country,
        "zip": zip,
        "phone_number": phone_number,
        "line_2": line_2,
        "line_3": line_3,
        "canton": canton,
        "district": district,
        "metadata": metadata
      };
}
