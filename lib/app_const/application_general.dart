/// This file is saving the const that can be used in any app flie
/// Example: save the logger that used to logg data out

import 'package:logger/logger.dart';

final logger =
    Logger(printer: PrettyPrinter(methodCount: 0), level: Level.error);

enum Providers {
  theme,
  loading,
  login,
  user,
  worker,
  manager,
  settings,
  booking,
  links,
  device,
  language,
  purchase,
  payments
}
