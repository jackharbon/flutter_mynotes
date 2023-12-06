//  import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:provider/provider.dart';

import '../../constants/routes.dart';
import '../../../cloud/services/auth/auth_service.dart';
import '../../services/crud/notes_services.dart';
import '../../enums/menu_action.dart';
import '../../providers/app_notifier.dart';
import '../dialogs/delete_account_dialog.dart';
import '../dialogs/logout_dialog.dart';

PopupMenuButton<MenuAction> popupMenuItems(BuildContext context) {
  return PopupMenuButton<MenuAction>(
    onSelected: (value) async {
      // ? ----------------------------------------
      //  devtools.log(' ==> popup_menu | popupMenuItems() | value: ${value.toString()}');
      switch (value) {
        case MenuAction.logout:
          final shouldLogout = await showLogOutDialog(context);
          if (shouldLogout) {
            // await AuthService.firebase().logOut();
            Navigator.of(context).pushNamedAndRemoveUntil(
              loginRoute,
              (_) => false,
            );
          }
        case MenuAction.lightMode:
          Provider.of<AppNotifier>(context, listen: false).toggleLightDarkMode(ThemeMode.light);
        case MenuAction.systemMode:
          Provider.of<AppNotifier>(context, listen: false).toggleLightDarkMode(ThemeMode.system);
        case MenuAction.darkMode:
          Provider.of<AppNotifier>(context, listen: false).toggleLightDarkMode(ThemeMode.dark);
        case MenuAction.blueM3:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.blueM3);
        case MenuAction.hippieBlue:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.hippieBlue);
        case MenuAction.deepPurple:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.deepPurple);
        case MenuAction.purpleBrown:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.purpleBrown);
        case MenuAction.pinkM3:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.pinkM3);
        case MenuAction.gold:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.gold);
        case MenuAction.greenM3:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.greenM3);
        case MenuAction.bigStone:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.bigStone);
        case MenuAction.deleteAccount:
          final shouldDeleteAccount = await showDeleteAccountDialog(context);
          if (shouldDeleteAccount) {
            // ? ----------------------------------------
            //  devtools.log(' ==> popup_menu |  MenuAction.deleteAccount |  shouldDeleteAccount: $shouldDeleteAccount');
            final String email = AuthService.firebase().currentUser!.email;
            await LocalNotesService().deleteAllLocalNotes(email: email);
            await LocalNotesService().deleteLocalUser(email: email);
            Navigator.of(context).pushNamedAndRemoveUntil(
              registerRoute,
              (_) => false,
            );
            await AuthService.firebase().deleteUserAccount(email: email);
            // ? ----------------------------------------
            //  devtools.log(' ==> popup_menu |  MenuAction.deleteAccount | email: $email');
          }
      }
    },
    itemBuilder: (context) {
      return [
        PopupMenuItem<MenuAction>(
          value: MenuAction.logout,
          child: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.logout,
                  size: 26.0,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 18),
                const Text(
                  'Log Out',
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(height: 20),
        PopupMenuItem<MenuAction>(
          value: MenuAction.lightMode,
          child: SizedBox(
            width: 180,
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
            width: 180,
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
            width: 180,
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
          value: MenuAction.blueM3,
          child: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xff156DAA),
                ),
                SizedBox(width: 18),
                Text('Sea Blue'),
              ],
            ),
          ),
        ),
        const PopupMenuItem<MenuAction>(
          value: MenuAction.hippieBlue,
          child: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xff57A1BE),
                ),
                SizedBox(width: 18),
                Text('Hippie Blue'),
              ],
            ),
          ),
        ),
        const PopupMenuItem<MenuAction>(
          value: MenuAction.deepPurple,
          child: SizedBox(
            width: 180,
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
            width: 180,
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
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xffC00055),
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
            width: 180,
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
            width: 180,
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
            width: 180,
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
        const PopupMenuDivider(
          height: 20,
        ),
        PopupMenuItem<MenuAction>(
          value: MenuAction.deleteAccount,
          child: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.person_remove_alt_1,
                  size: 26.0,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 18),
                Text(
                  'Delete Account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    },
  );
}
