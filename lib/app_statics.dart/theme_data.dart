import '../app_const/display.dart';

class AppThemeData {
  static Themes defaultTheme = Themes.dark;
  static Themes? currentKeyTheme;
  static bool themeCauseMainBuilt = false; // main rebuild becuase theme changed
}
