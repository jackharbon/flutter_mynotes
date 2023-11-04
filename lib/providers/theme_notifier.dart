import 'dart:developer' as devtools show log;
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/models/theme_colors.dart';

class ColorThemeNotifier extends ChangeNotifier {
  //
  ThemeMode colorMode = ThemeMode.system;
  FlexScheme themeScheme = ThemeColorsSchemes().schemeBlue;

  void toggleLightDarkMode(ThemeMode colorMode) {
    this.colorMode = colorMode;
    notifyListeners();
    // ? -------------------------
    devtools.log(
        ' ==> theme_notifier | ColorThemeNotifier() | toggleLightDarkMode() colorMode: $colorMode');
  }

  void changeColorScheme(FlexScheme themeScheme) {
    this.themeScheme = themeScheme;
    notifyListeners();
  }
}
