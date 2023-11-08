import 'package:flutter/material.dart' show BuildContext, ModalRoute;

extension GetArgument on BuildContext {
  T? getArgument<T>() {
    final modalRoute =
        ModalRoute.of(this); // 'this' is the current build context
    if (modalRoute != null) {
      // if we can get the argument of the type T, then return the argument
      final args = modalRoute.settings.arguments;
      if (args != null && args is T) {
        return args as T;
      }
    }
    return null;
  }
}
