import 'dart:developer' as devtools show log;
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import '../models/theme_colors.dart';

class AppNotifier extends ChangeNotifier {
  //
  ThemeMode colorMode = ThemeMode.system;
  FlexScheme themeScheme = ThemeColorsSchemes().schemeBlue;
  bool isCloudStorage = true;
  bool isOnline = true;

  void toggleLightDarkMode(ThemeMode colorMode) {
    this.colorMode = colorMode;
    notifyListeners();
    // ? -------------------------------------
    devtools
        .log(' ==> app_notifier | toggleLightDarkMode() colorMode: $colorMode');
  }

  void changeColorScheme(FlexScheme themeScheme) {
    this.themeScheme = themeScheme;
    notifyListeners();
  }

  void toggleDatabaseLocation(bool isCloudStorage) {
    this.isCloudStorage = isCloudStorage;
    // ? -------------------------------------
    devtools.log(
        ' ==> app_notifier | toggleDatabaseLocation() | isCloudStorage: $isCloudStorage');
    notifyListeners();
  }

  void checkOnlineStatusToggle(bool isOnline) {
    this.isOnline = isOnline;
    // ? -------------------------------------
    devtools.log(
        ' ==> app_notifier | checkOnlineStatusToggle() | isOnline: $isOnline');
    notifyListeners();
  }
}
