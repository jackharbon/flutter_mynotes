import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:provider/provider.dart';

import '../../../cloud/services/auth/bloc/auth_bloc.dart';
import '../../../cloud/services/auth/bloc/auth_event.dart';
import '../../../cloud/services/auth/auth_service.dart';
import '../../extensions/buildcontext/loc.dart';
import '../../services/crud/notes_services.dart';
import '../../enums/menu_action.dart';
import '../../providers/app_notifier.dart';
import '../dialogs/delete_account_dialog.dart';
import '../dialogs/logout_dialog.dart';

PopupMenuButton<MenuAction> popupMenuItems(BuildContext context) {
  return PopupMenuButton<MenuAction>(
    onSelected: (value) async {
      final String email = AuthService.firebase().currentUser!.email;
      // ? ----------------------------------------
      // debugPrint('|===> popup_menu | popupMenuItems() | value: ${value.toString()}');
      switch (value) {
        case MenuAction.logout:
          final shouldLogout = await showLogOutDialog(context);
          if (shouldLogout) {
            // await LocalNotesService().logOut;
            context.read<AuthBloc>().add(
                  const AuthEventLogOut(),
                );
          }
        case MenuAction.lightMode:
          Provider.of<AppNotifier>(context, listen: false).toggleLightDarkMode(ThemeMode.light);
          await LocalNotesService().updateLocalUserThemeMode(
            themeMode: ThemeMode.light.toString(),
            email: email,
          );
        case MenuAction.systemMode:
          Provider.of<AppNotifier>(context, listen: false).toggleLightDarkMode(ThemeMode.system);
          await LocalNotesService().updateLocalUserThemeMode(
            themeMode: ThemeMode.system.toString(),
            email: email,
          );
        case MenuAction.darkMode:
          Provider.of<AppNotifier>(context, listen: false).toggleLightDarkMode(ThemeMode.dark);
          await LocalNotesService().updateLocalUserThemeMode(
            themeMode: ThemeMode.dark.toString(),
            email: email,
          );
        case MenuAction.blueM3:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.blueM3);
          await LocalNotesService().updateLocalUserFlexScheme(
            flexScheme: FlexScheme.blueM3.toString(),
            email: email,
          );
        case MenuAction.hippieBlue:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.hippieBlue);
          await LocalNotesService().updateLocalUserFlexScheme(
            flexScheme: FlexScheme.hippieBlue.toString(),
            email: email,
          );
        case MenuAction.deepPurple:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.deepPurple);
          await LocalNotesService().updateLocalUserFlexScheme(
            flexScheme: FlexScheme.deepPurple.toString(),
            email: email,
          );
        case MenuAction.barossa:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.barossa);
          await LocalNotesService().updateLocalUserFlexScheme(
            flexScheme: FlexScheme.barossa.toString(),
            email: email,
          );
        case MenuAction.purpleBrown:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.purpleBrown);
          await LocalNotesService().updateLocalUserFlexScheme(
            flexScheme: FlexScheme.purpleBrown.toString(),
            email: email,
          );
        case MenuAction.espresso:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.espresso);
          await LocalNotesService().updateLocalUserFlexScheme(
            flexScheme: FlexScheme.espresso.toString(),
            email: email,
          );
        case MenuAction.redM3:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.redM3);
          await LocalNotesService().updateLocalUserFlexScheme(
            flexScheme: FlexScheme.redM3.toString(),
            email: email,
          );
        case MenuAction.pinkM3:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.pinkM3);
          await LocalNotesService().updateLocalUserFlexScheme(
            flexScheme: FlexScheme.pinkM3.toString(),
            email: email,
          );
        case MenuAction.damask:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.damask);
          await LocalNotesService().updateLocalUserFlexScheme(
            flexScheme: FlexScheme.damask.toString(),
            email: email,
          );
        case MenuAction.gold:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.gold);
          await LocalNotesService().updateLocalUserFlexScheme(
            flexScheme: FlexScheme.gold.toString(),
            email: email,
          );
        case MenuAction.greenM3:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.greenM3);
          await LocalNotesService().updateLocalUserFlexScheme(
            flexScheme: FlexScheme.greenM3.toString(),
            email: email,
          );
        case MenuAction.jungle:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.jungle);
          await LocalNotesService().updateLocalUserFlexScheme(
            flexScheme: FlexScheme.jungle.toString(),
            email: email,
          );
        case MenuAction.bigStone:
          Provider.of<AppNotifier>(context, listen: false).changeColorScheme(FlexScheme.bigStone);
          await LocalNotesService().updateLocalUserFlexScheme(
            flexScheme: FlexScheme.bigStone.toString(),
            email: email,
          );
        case MenuAction.deleteAccount:
          final shouldDeleteAccount = await showDeleteAccountDialog(context);
          if (shouldDeleteAccount) {
            // ? ----------------------------------------
            // debugPrint('|===> popup_menu |  MenuAction.deleteAccount |  shouldDeleteAccount: $shouldDeleteAccount');
            await LocalNotesService().deleteAllLocalNotes(email: email);
            await LocalNotesService().deleteLocalUser(email: email);
            await AuthService.firebase().deleteUserAccount(email: email);
            context.read<AuthBloc>().add(
                  const AuthEventShouldRegister(),
                );
            // ? ----------------------------------------
            // debugPrint('|===> popup_menu |  MenuAction.deleteAccount | email: $email');
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
                Text(
                  context.loc.popup_menu_logout,
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
                Text(context.loc.popup_menu_light_mode),
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
                Text(context.loc.popup_menu_system_mode),
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
                Text(context.loc.popup_menu_dark_mode),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(height: 20),
        PopupMenuItem<MenuAction>(
          value: MenuAction.blueM3,
          child: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xff156DAA),
                ),
                const SizedBox(width: 18),
                Text(context.loc.popup_menu_sea_blue),
              ],
            ),
          ),
        ),
        PopupMenuItem<MenuAction>(
          value: MenuAction.hippieBlue,
          child: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xff57A1BE),
                ),
                const SizedBox(width: 18),
                Text(context.loc.popup_menu_hippie_blue),
              ],
            ),
          ),
        ),
        PopupMenuItem<MenuAction>(
          value: MenuAction.deepPurple,
          child: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xff5035A5),
                ),
                const SizedBox(width: 18),
                Text(context.loc.popup_menu_deep_purple),
              ],
            ),
          ),
        ),
        PopupMenuItem<MenuAction>(
          value: MenuAction.barossa,
          child: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xff571538),
                ),
                const SizedBox(width: 18),
                Text(context.loc.popup_menu_barossa),
              ],
            ),
          ),
        ),
        PopupMenuItem<MenuAction>(
          value: MenuAction.purpleBrown,
          child: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xff4D171E),
                ),
                const SizedBox(width: 18),
                Text(context.loc.popup_menu_purple_brown),
              ],
            ),
          ),
        ),
        PopupMenuItem<MenuAction>(
          value: MenuAction.espresso,
          child: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xff503D38),
                ),
                const SizedBox(width: 18),
                Text(context.loc.popup_menu_espresso),
              ],
            ),
          ),
        ),
        PopupMenuItem<MenuAction>(
          value: MenuAction.redM3,
          child: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xffBC2722),
                ),
                const SizedBox(width: 18),
                Text(context.loc.popup_menu_red),
              ],
            ),
          ),
        ),
        PopupMenuItem<MenuAction>(
          value: MenuAction.pinkM3,
          child: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xffC00055),
                ),
                const SizedBox(width: 18),
                Text(context.loc.popup_menu_pink),
              ],
            ),
          ),
        ),
        PopupMenuItem<MenuAction>(
          value: MenuAction.damask,
          child: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xffF6820B),
                ),
                const SizedBox(width: 18),
                Text(context.loc.popup_menu_damask),
              ],
            ),
          ),
        ),
        PopupMenuItem<MenuAction>(
          value: MenuAction.gold,
          child: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xffBC7222),
                ),
                const SizedBox(width: 18),
                Text(context.loc.popup_menu_gold),
              ],
            ),
          ),
        ),
        PopupMenuItem<MenuAction>(
          value: MenuAction.greenM3,
          child: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xff77CE74),
                ),
                const SizedBox(width: 18),
                Text(context.loc.popup_menu_green),
              ],
            ),
          ),
        ),
        PopupMenuItem<MenuAction>(
          value: MenuAction.jungle,
          child: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xff155922),
                ),
                const SizedBox(width: 18),
                Text(context.loc.popup_menu_jungle),
              ],
            ),
          ),
        ),
        PopupMenuItem<MenuAction>(
          value: MenuAction.bigStone,
          child: SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  size: 26.0,
                  color: Color(0xff26384C),
                ),
                const SizedBox(width: 18),
                Text(context.loc.popup_menu_big_stone),
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
                  context.loc.popup_menu_delete_account,
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
