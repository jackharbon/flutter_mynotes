import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import '../models/theme_colors.dart';

class AppNotifier extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  FlexScheme flexScheme = ThemeColorsSchemes().schemeBlue;
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

  void toggleLightDarkMode(ThemeMode themeMode) {
    this.themeMode = themeMode;
    notifyListeners();
    // ? -------------------------------------
    // debugPrint('|===> app_notifier | toggleLightDarkMode() themeMode: $themeMode');
  }

  void changeColorScheme(FlexScheme flexScheme) {
    this.flexScheme = flexScheme;
    notifyListeners();
  }

  // --------------- Storage Location ---------------

  void isCloudStorageAppState(bool isCloudStorage) {
    this.isCloudStorage = isCloudStorage;
    // ? -------------------------------------
    // debugPrint('|===> app_notifier | isCloudStorageAppState() | isCloudStorage: $isCloudStorage');
    notifyListeners();
  }

  void isOnlineAppState(bool isOnline) {
    this.isOnline = isOnline;
    // ? -------------------------------------
    // debugPrint('|===> app_notifier | isOnlineAppState() | isOnline: $isOnline');
    notifyListeners();
  }

  // --------------- User Auth ---------------

  // void storeUserEmail(String userEmail) {
  //   this.userEmail = userEmail;
  //   // ? -------------------------------------
  //   // debugPrint('|===> app_notifier | storeUserEmail() | userEmail: $userEmail');
  //   notifyListeners();
  // }

  // --------------- Notes View State ---------------

  void isSubtitleVisibleState(bool isSubtitleVisible) {
    this.isSubtitleVisible = isSubtitleVisible;
    // ? -------------------------------------
    // debugPrint('|===> app_notifier | isSubtitleVisibleState() | isSubtitleVisible: $isSubtitleVisible');
    notifyListeners();
  }

  void isNumberVisibleState(bool isNumberVisible) {
    this.isNumberVisible = isNumberVisible;
    // ? -------------------------------------
    // debugPrint('|===> app_notifier | isNumberVisibleState() | isNumberVisible: $isNumberVisible');
    notifyListeners();
  }

  void itemsCheckedToDeleteState(bool itemsCheckedToDelete) {
    this.itemsCheckedToDelete = itemsCheckedToDelete;
    // ? -------------------------------------
    // debugPrint('|===> app_notifier | itemsCheckedToDeleteState() | itemsCheckedToDelete: $itemsCheckedToDelete');
    notifyListeners();
  }

  void isDeletingModeState(bool isDeletingMode) {
    this.isDeletingMode = isDeletingMode;
    // ? -------------------------------------
    // debugPrint('|===> app_notifier | isDeletingModeState() | isDeletingMode: $isDeletingMode');
    notifyListeners();
  }

  void isDateVisibleState(bool isDateVisible) {
    this.isDateVisible = isDateVisible;
    // ? -------------------------------------
    // debugPrint('|===> app_notifier | isDateVisibleState() | isDateVisible: $isDateVisible');
    notifyListeners();
  }

  void selectedItemsForDelete(List<String> selectedItems) {
    this.selectedItems = selectedItems;
    // ? -------------------------------------
    // debugPrint('|===> app_notifier | selectedItemsForDelete() | selectedItems: $selectedItems');
    notifyListeners();
  }
}
