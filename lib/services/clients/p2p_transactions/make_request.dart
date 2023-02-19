import 'dart:convert';
import 'dart:math';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:simple_tor_web/app_const/application_general.dart';
import 'package:simple_tor_web/secrets.dart';

class MakeRequest {
  static final MakeRequest _singleton = MakeRequest._internal();
  final _baseURL = 'https://sandboxapi.rapyd.net';
  final _accessKey = RAPYD_ACCESS_KEY;
  final _secretKey = RAPYD_SECRET_KEY;
  MakeRequest._internal();

  factory MakeRequest() {
    MakeRequest object = _singleton;
    return object;
  }

  String _generateSalt() {
    final _random = Random.secure();
    // Generate 16 characters for salt by generating 16 random bytes
    // and encoding it.
    final randomBytes = List<int>.generate(16, (index) => _random.nextInt(256));
    return base64UrlEncode(randomBytes);
  }

  Map<String, String> _generateHeader({
    required String method,
    required String endpoint,
    String body = '',
  }) {
    /* Generate the rapyd signature header */
    int unixTimetamp = DateTime.now().millisecondsSinceEpoch;
    String timestamp = (unixTimetamp / 1000).round().toString();

    var salt = _generateSalt();

    var toSign =
        method + endpoint + salt + timestamp + _accessKey + _secretKey + body;

    var keyEncoded = ascii.encode(_secretKey);
    var toSignEncoded = ascii.encode(toSign);

    var hmacSha256 = Hmac(sha256, keyEncoded); // HMAC-SHA256
    var digest = hmacSha256.convert(toSignEncoded);
    var ss = hex.encode(digest.bytes);
    var tt = ss.codeUnits;
    var signature = base64.encode(tt);

    var headers = {
      'Content-Type': 'application/json',
      'access_key': _accessKey,
      'salt': salt,
      'timestamp': timestamp,
      'signature': signature,
    };
    return headers;
  }

  Future<Map<String, dynamic>> performRequst(
      {required String endpoint,
      required String method,
      required Map<String, dynamic> body}) async {
    final url = Uri.parse(_baseURL + endpoint);

    // convert the body to str
    var data = jsonEncode(body);
    if (data == '{}') data = '';
    // get the header with the signature
    final headers = _generateHeader(
      method: method,
      endpoint: endpoint,
      body: data,
    );

    try {
      // sending the request
      var response =
          await _request(method, url: url, headers: headers, data: data);

      logger.d("P2p request resp body -->\n${response.body}");

      if (response.statusCode == 200) {
        // request succeded
        logger.i('P2p request status -- > Seccess!');
        return jsonDecode(response.body);
      }
    } catch (e) {
      logger.e('P2p request Failed --> $e');
    }
    return {};
  }

  Future<dynamic> _request(String method,
      {required Uri url, Map<String, String>? headers, Object? data}) async {
    switch (method) {
      case "post":
        return await http.post(
          url,
          headers: headers,
          body: data,
        );
      case "get":
        return await http.get(
          url,
          headers: headers,
        );
      default:
        return;
    }
  }
}
