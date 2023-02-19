/// This file is saving the const of the current platforn the app is running on
/// Example: is it web, or the platform the web is runing from
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

// is web platform
const isWeb = kIsWeb;
// the ancestor platforn (web runing from ios / android)
final bool isAppleAcosystem = appleAcosystem.contains(defaultTargetPlatform);
// the apple systems
const appleAcosystem = const [TargetPlatform.iOS, TargetPlatform.macOS];
