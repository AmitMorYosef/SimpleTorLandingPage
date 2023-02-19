import 'package:currency_picker/currency_picker.dart';

class CurrencyModel {
  ///The currency code
  final String code;

  ///The currency name in English
  final String name;

  ///The currency symbol
  final String symbol;

  CurrencyModel({
    required this.code,
    required this.name,
    required this.symbol,
  });

  CurrencyModel.from({required Map<String, dynamic> json})
      : code = json['code'],
        name = json['name'],
        symbol = json['symbol'];

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'symbol': symbol,
      };

  CurrencyModel.fromCurrency({required Currency currency})
      : code = currency.code,
        name = currency.name,
        symbol = currency.symbol;
}
