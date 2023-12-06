//  import 'dart:developer' as devtools show log;

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import '../models/theme_colors.dart';

class AppNotifier extends ChangeNotifier {
  ThemeMode colorMode = ThemeMode.system;
  FlexScheme themeScheme = ThemeColorsSchemes().schemeBlue;
  bool isCloudStorage = true;
  bool isOnline = true;
  String userEmail = "";
  bool isSubtitleVisible = true;
  bool isNumberVisible = true;
  bool isDateVisible = true;
  bool itemsCheckedToDelete = false;
  bool isDeletingMode = false;
  List<String> selectedItems = [];

  // --------------- Color Theme ---------------

  void toggleLightDarkMode(ThemeMode colorMode) {
    this.colorMode = colorMode;
    notifyListeners();
    // ? -------------------------------------
    //  devtools.log(' ==> app_notifier | toggleLightDarkMode() colorMode: $colorMode');
  }

  void changeColorScheme(FlexScheme themeScheme) {
    this.themeScheme = themeScheme;
    notifyListeners();
  }

  // --------------- Storage Location ---------------

  void isCloudStorageAppState(bool isCloudStorage) {
    this.isCloudStorage = isCloudStorage;
    // ? -------------------------------------
    //  devtools.log(' ==> app_notifier | isCloudStorageAppState() | isCloudStorage: $isCloudStorage');
    notifyListeners();
  }

  void isOnlineAppState(bool isOnline) {
    this.isOnline = isOnline;
    // ? -------------------------------------
    //  devtools.log(' ==> app_notifier | isOnlineAppState() | isOnline: $isOnline');
    notifyListeners();
  }

  // --------------- User Auth ---------------

  void storeUserEmail(String userEmail) {
    this.userEmail = userEmail;
    // ? -------------------------------------
    //  devtools.log(' ==> app_notifier | storeUserEmail() | userEmail: $userEmail');
    notifyListeners();
  }

  // --------------- Notes View State ---------------

  void isSubtitleVisibleState(bool isSubtitleVisible) {
    this.isSubtitleVisible = isSubtitleVisible;
    // ? -------------------------------------
    //  devtools.log(' ==> app_notifier | isSubtitleVisibleState() | isSubtitleVisible: $isSubtitleVisible');
    notifyListeners();
  }

  void isNumberVisibleState(bool isNumberVisible) {
    this.isNumberVisible = isNumberVisible;
    // ? -------------------------------------
    //  devtools.log(' ==> app_notifier | isNumberVisibleState() | isNumberVisible: $isNumberVisible');
    notifyListeners();
  }

  void itemsCheckedToDeleteState(bool itemsCheckedToDelete) {
    this.itemsCheckedToDelete = itemsCheckedToDelete;
    // ? -------------------------------------
    //  devtools.log(' ==> app_notifier | itemsCheckedToDeleteState() | itemsCheckedToDelete: $itemsCheckedToDelete');
    notifyListeners();
  }

  void isDeletingModeState(bool isDeletingMode) {
    this.isDeletingMode = isDeletingMode;
    // ? -------------------------------------
    //  devtools.log(' ==> app_notifier | isDeletingModeState() | isDeletingMode: $isDeletingMode');
    notifyListeners();
  }

  void isDateVisibleState(bool isDateVisible) {
    this.isDateVisible = isDateVisible;
    // ? -------------------------------------
    //  devtools.log(' ==> app_notifier | isDateVisibleState() | isDateVisible: $isDateVisible');
    notifyListeners();
  }

  void selectedItemsForDelete(List<String> selectedItems) {
    this.selectedItems = selectedItems;
    // ? -------------------------------------
    //  devtools.log(' ==> app_notifier | selectedItemsForDelete() | selectedItems: $selectedItems');
    notifyListeners();
  }
}
