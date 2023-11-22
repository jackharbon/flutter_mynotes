import 'dart:developer' as devtools show log;
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import '../models/theme_colors.dart';

class AppNotifier extends ChangeNotifier {
  ThemeMode colorMode = ThemeMode.system;
  FlexScheme themeScheme = ThemeColorsSchemes().schemeBlue;
  bool isCloudStorage = true;
  bool isOnline = false;
  String userEmail = "";

  void toggleLightDarkMode(ThemeMode colorMode) {
    this.colorMode = colorMode;
    notifyListeners();
    // ? -------------------------------------
    devtools.log(' ==> app_notifier | toggleLightDarkMode() colorMode: $colorMode');
  }

  void changeColorScheme(FlexScheme themeScheme) {
    this.themeScheme = themeScheme;
    notifyListeners();
  }

  void isCloudStorageAppState(bool isCloudStorage) {
    this.isCloudStorage = isCloudStorage;
    // ? -------------------------------------
    devtools.log(' ==> app_notifier | isCloudStorageAppState() | isCloudStorage: $isCloudStorage');
    notifyListeners();
  }

  void isOnlineAppState(bool isOnline) {
    this.isOnline = isOnline;
    // ? -------------------------------------
    devtools.log(' ==> app_notifier | isOnlineAppState() | isOnline: $isOnline');
    notifyListeners();
  }

  void storeUserEmail(String userEmail) {
    this.userEmail = userEmail;
    // ? -------------------------------------
    devtools.log(' ==> app_notifier | storeUserEmail() | userEmail: $userEmail');
    notifyListeners();
  }
}
