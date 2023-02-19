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

import 'package:management_system_app/services/clients/p2p_transactions/models.dart/beneficiary.dart';
import 'package:management_system_app/services/clients/p2p_transactions/models.dart/sender.dart';

class Payout {
  String beneficiary_country,
      merchant_reference_id,
      ewallet,
      payout_amount,
      payout_currency,
      payout_method_type,
      sender_country,
      sender_currency,
      beneficiary_entity_type,
      sender_entity_type,
      statement_descriptor,
      description;
  bool confirm_automatically;
  Map metadata;
  Beneficiary beneficiary;
  Sender sender;

  Payout(
      {required this.beneficiary_country,
      required this.merchant_reference_id,
      required this.ewallet,
      required this.payout_amount,
      required this.payout_currency,
      required this.payout_method_type,
      required this.sender_country,
      required this.sender_currency,
      required this.beneficiary,
      required this.sender,
      this.confirm_automatically = true,
      this.beneficiary_entity_type = 'individual',
      this.sender_entity_type = 'individual',
      this.statement_descriptor = "GHY* Limited Access 800-123-4567",
      this.description = "Payout - Bank Transfer: Beneficiary/Sender objects",
      this.metadata = const {"merchant_defined": true}});

  factory Payout.fromJson(Map<String, dynamic> json) => Payout(
        beneficiary_country: json["beneficiary_country"],
        statement_descriptor: json["statement_descriptor"],
        description: json["description"],
        merchant_reference_id: json["merchant_reference_id"],
        ewallet: json["ewallet"],
        payout_amount: json["payout_amount"],
        payout_currency: json["payout_currency"],
        payout_method_type: json["payout_method_type"],
        sender_country: json["sender_country"],
        sender_currency: json["sender_currency"],
        confirm_automatically: json["confirm_automatically"],
        beneficiary_entity_type: json["beneficiary_entity_type"],
        sender_entity_type: json["sender_entity_type"],
        metadata: json["metadata"],
        beneficiary: Beneficiary.fromJson(json["beneficiary"]),
        sender: Sender.fromJson(json["sender"]),
      );

  Map<String, dynamic> toJson() => {
        "beneficiary_country": beneficiary_country,
        "statement_descriptor": statement_descriptor,
        "description": description,
        "merchant_reference_id": merchant_reference_id,
        "ewallet": ewallet,
        "payout_amount": payout_amount,
        "payout_currency": payout_currency,
        "payout_method_type": payout_method_type,
        "sender_country": sender_country,
        "sender_currency": sender_currency,
        "confirm_automatically": confirm_automatically,
        "beneficiary_entity_type": beneficiary_entity_type,
        "sender_entity_type": sender_entity_type,
        "metadata": metadata,
        "beneficiary": beneficiary.toJson(),
        "sender": sender.toJson(),
      };
}
