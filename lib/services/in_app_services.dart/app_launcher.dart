import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

import '../../app_const/app_external_links.dart';
import '../../app_const/application_general.dart';
import '../../app_const/platform.dart';

class AppLauncher {
  void launchInstagram(String account) async {
    String nativeUrl = "instagram://user?username=$account";
    String webUrl = 'https://www.instagram.com/$account/';
    await launchApp(nativeUrl, webUrl);
  }

  void launchTikTok(String account) async {
    String nativeUrl = "tiktok://www.tiktok.com/@bnetanyahu";
    String webUrl = "tiktok://www.tiktok.com/@bnetanyahu";
    await launchApp(nativeUrl, webUrl);
  }

  void makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  void lunchStore() async {
    if (isAppleAcosystem) {
      await launchApp(iosPhoneDownloadLink, iosWebDownloadLink);
    } else {
      await launchApp(androidPhoneDownloadLink, androidWebDownloadLink);
    }
  }

  // static void tikTok() async {
  //   String nativeUrl = "tiktok://user?username=$account";
  //   String webUrl = 'https://www.instagram.com/$account/';
  //   await launchApp(nativeUrl, webUrl);
  // }

  void launchWhatsapp(String phoneNumber) async {
    /*By the whatsapp api the phone number need to "Omit any brackets, dashes, plus signs, and leading zeros"  */
    final fixedPhone = cleanPhoneNumber(phoneNumber);
    String nativeUrl = "whatsapp://send?phone=$fixedPhone";
    String webUrl = "https://wa.me/$fixedPhone";
    await launchApp(nativeUrl, webUrl);
  }

  String cleanPhoneNumber(String phoneNumber) {
    RegExp regExp = RegExp(r'[\s()+-]');
    String cleanedNumber = phoneNumber.replaceAll(regExp, '');

    while (cleanedNumber.startsWith('0')) {
      cleanedNumber = cleanedNumber.substring(1);
    }

    return cleanedNumber;
  }

  void launchPlatformAppMaps(String adress) async {
    try {
      final url = gnarateUri(adress);
      await launchUrl(url);
    } catch (e) {
      logger.e("Error while launch app --> $e");
    }
  }

  Uri gnarateUri(String adress) {
    try {
      Uri uri;
      if (isWeb) {
        uri = Uri.https(
            'www.google.com', '/maps/search/', {'api': '1', 'query': adress});
      } else if (Platform.isAndroid) {
        uri = Uri(scheme: 'geo', host: '0,0', queryParameters: {'q': adress});
      } else if (Platform.isIOS) {
        uri = Uri.https('maps.apple.com', '/', {'q': adress});
      } else {
        uri = Uri.https(
            'www.google.com', '/maps/search/', {'api': '1', 'query': adress});
      }
      return uri;
    } catch (e) {
      return Uri();
    }
  }

  void launchGoogleMaps(String adress) async {
    //orgnize waze url
    final url = Uri.https(
        'www.google.com', '/maps/search/', {'api': '1', 'query': adress});
    await launchUrl(url);
  }

  void launchWaze(String adress) async {
    //orgnize waze url
    final adressList = adress.split(" ");
    String link = 'waze://?q=';
    for (int i = 0; i <= adressList.length; i++) {
      if (i == adressList.length - 1) {
        link = link + adressList[i];
        break;
      }
      link = link + adressList[i] + '%20';
    }

    link = link + '&navigate=yes';
    final webUrl = link.replaceAll('waze://', 'https://waze.com/ul');
    final nativeurl = link.replaceAll('https://waze.com/ul', 'waze://');

    await launchApp(nativeurl, webUrl);
  }

  Future<void> launchApp(String nativeUrl, String webUrl,
      {bool needUseKeybord = false}) async {
    LaunchMode mode = LaunchMode.platformDefault;
    if (needUseKeybord) {
      mode = LaunchMode.externalApplication;
    }
    try {
      bool launched = await launchUrl(Uri.parse(nativeUrl), mode: mode);
      if (!launched) {
        await launchUrl(Uri.parse(webUrl), mode: mode);
      }
    } catch (e) {
      await launchUrl(Uri.parse(webUrl), mode: mode);
    }
  }
}
