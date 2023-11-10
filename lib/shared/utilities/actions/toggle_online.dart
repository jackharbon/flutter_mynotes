import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/routes.dart';
import '../../providers/theme_notifier.dart';

class ToggleOnline extends StatelessWidget {
  const ToggleOnline({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorThemeNotifier>(
        builder: (context, themeColorsNotifier, child) {
      return IconButton(
        isSelected: themeColorsNotifier.isOnline,
        icon: Icon(
          Icons.radio_button_off,
          color: Theme.of(context).colorScheme.outline,
        ),
        selectedIcon: Icon(
          Icons.radio_button_checked,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        onPressed: () async {
          themeColorsNotifier.isOnline = !themeColorsNotifier.isOnline;
          Provider.of<ColorThemeNotifier>(context, listen: false)
              .toggleOnlineStatus(themeColorsNotifier.isOnline);
          // ? --------------------------------------------
          devtools.log(
              ' ==> login_view() (local) | isOnline: : ${themeColorsNotifier.isOnline}');
          await Navigator.of(context).pushNamedAndRemoveUntil(
            loginRoute,
            (route) => false,
          );
        },
      );
    });
  }
}
