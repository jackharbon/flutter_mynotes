import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'dart:developer' as devtools show log;
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/dialogs/show_logout.dart';
import 'package:mynotes/providers/theme_notifier.dart';
import 'package:provider/provider.dart';

PopupMenuButton<MenuAction> popupMenuItems(BuildContext context) {
  return PopupMenuButton<MenuAction>(
    onSelected: (value) async {
      // ? ----------------------------------------
      devtools.log(value.toString());
      switch (value) {
        case MenuAction.logout:
          final shouldLogout = await showLogOutDialog(context);
          if (shouldLogout) {
            await AuthService.firebase().logOut();
            Navigator.of(context).pushNamedAndRemoveUntil(
              loginRoute,
              (_) => false,
            );
          }
        case MenuAction.lightMode:
          Provider.of<ColorThemeNotifier>(context, listen: false)
              .toggleLightDarkMode(ThemeMode.light);
        case MenuAction.systemMode:
          Provider.of<ColorThemeNotifier>(context, listen: false)
              .toggleLightDarkMode(ThemeMode.system);
        case MenuAction.darkMode:
          Provider.of<ColorThemeNotifier>(context, listen: false)
              .toggleLightDarkMode(ThemeMode.dark);
        case MenuAction.blue:
          Provider.of<ColorThemeNotifier>(context, listen: false)
              .changeColorScheme(FlexScheme.blue);
        case MenuAction.deepPurple:
          Provider.of<ColorThemeNotifier>(context, listen: false)
              .changeColorScheme(FlexScheme.deepPurple);
        case MenuAction.purpleBrown:
          Provider.of<ColorThemeNotifier>(context, listen: false)
              .changeColorScheme(FlexScheme.purpleBrown);
        case MenuAction.pinkM3:
          Provider.of<ColorThemeNotifier>(context, listen: false)
              .changeColorScheme(FlexScheme.pinkM3);
        case MenuAction.gold:
          Provider.of<ColorThemeNotifier>(context, listen: false)
              .changeColorScheme(FlexScheme.gold);
        case MenuAction.greenM3:
          Provider.of<ColorThemeNotifier>(context, listen: false)
              .changeColorScheme(FlexScheme.greenM3);
        case MenuAction.bigStone:
          Provider.of<ColorThemeNotifier>(context, listen: false)
              .changeColorScheme(FlexScheme.bigStone);
      }
    },
    itemBuilder: (context) {
      return [
        PopupMenuItem<MenuAction>(
          value: MenuAction.logout,
          child: SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.logout,
                  size: 26.0,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 18),
                const Text('Log out'),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(height: 20),
        PopupMenuItem<MenuAction>(
          value: MenuAction.lightMode,
          child: SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.light_mode,
                  size: 26.0,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 18),
                const Text('Light Mode'),
              ],
            ),
          ),
        ),
        PopupMenuItem<MenuAction>(
          value: MenuAction.systemMode,
          child: SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.phone_android,
                  size: 26.0,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 18),
                const Text('System Mode'),
              ],
            ),
          ),
        ),
        PopupMenuItem<MenuAction>(
          value: MenuAction.darkMode,
          child: SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.dark_mode,
                  size: 26.0,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 18),
                const Text('Dark Mode'),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(height: 20),
        const PopupMenuItem<MenuAction>(
          value: MenuAction.blue,
          child: SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Colors.blue,
                ),
                SizedBox(width: 18),
                Text('Sea Blue'),
              ],
            ),
          ),
        ),
        const PopupMenuItem<MenuAction>(
          value: MenuAction.deepPurple,
          child: SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xff5035A5),
                ),
                SizedBox(width: 18),
                Text('Deep Purple'),
              ],
            ),
          ),
        ),
        const PopupMenuItem<MenuAction>(
          value: MenuAction.purpleBrown,
          child: SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xff4D171E),
                ),
                SizedBox(width: 18),
                Text('Purple Brown'),
              ],
            ),
          ),
        ),
        const PopupMenuItem<MenuAction>(
          value: MenuAction.pinkM3,
          child: SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xffE4A3AE),
                ),
                SizedBox(width: 18),
                Text('Pink'),
              ],
            ),
          ),
        ),
        const PopupMenuItem<MenuAction>(
          value: MenuAction.gold,
          child: SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xffBC7222),
                ),
                SizedBox(width: 18),
                Text('Gold'),
              ],
            ),
          ),
        ),
        const PopupMenuItem<MenuAction>(
          value: MenuAction.greenM3,
          child: SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xff77CE74),
                ),
                SizedBox(width: 18),
                Text('Forest Green'),
              ],
            ),
          ),
        ),
        const PopupMenuItem<MenuAction>(
          value: MenuAction.bigStone,
          child: SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xff26384C),
                ),
                SizedBox(width: 18),
                Text('Big Stone'),
              ],
            ),
          ),
        ),
      ];
    },
  );
}
