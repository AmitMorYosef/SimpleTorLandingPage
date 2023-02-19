import 'package:currency_picker/currency_picker.dart';
import 'package:intl/intl.dart';

class Price {
  double amount = 0.00;
  Currency? currency;
  Price({required String amount, required this.currency}) {
    this.amount = double.tryParse(amount) ?? 00.00;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data["amount"] = this.amount;
    data["currency"] = this.currency!.toJson();
    return data;
  }

  Price.fromJson(Map<String, dynamic> json) {
    amount =
        json["amount"] is double ? json["amount"] : json["amount"].toDouble();
    currency = Currency.from(json: json["currency"]);
  }

  void add(Price anotherPrice) {
    if (anotherPrice.currency!.code != this.currency!.code) return;
    this.amount += anotherPrice.amount;
  }

  String toString() {
    final oCcy = new NumberFormat("#,##0.00");

    return currency!.symbolOnLeft
        ? "${oCcy.format(amount)}${currency!.symbol}"
        : "${currency!.symbol}${oCcy.format(amount)}";
  }
}
