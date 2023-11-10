import 'dart:developer' as devtools show log;

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'cloud/views/home_view.dart';
import 'cloud/views/login/login_view.dart';
import 'shared/views/login/register_view.dart';
import 'shared/views/login/verify_email_view.dart';
import 'cloud/views/notes/create_update_note_view.dart';
import 'cloud/views/notes/notes_view.dart';
import 'local/views/home_view.dart';
import 'local/views/login/login_view.dart';
import 'local/views/notes/create_update_note_view.dart';
import 'local/views/notes/notes_view.dart';
import 'shared/constants/routes.dart';
import 'shared/providers/theme_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    ChangeNotifierProvider<ColorThemeNotifier>(
        create: (BuildContext context) {
          return ColorThemeNotifier();
        },
        child: const ColorThemeNotifierLayer()),
  );
  FlutterNativeSplash.remove();
}

class ColorThemeNotifierLayer extends StatefulWidget {
  const ColorThemeNotifierLayer({super.key});

  @override
  State<ColorThemeNotifierLayer> createState() =>
      _ColorThemeNotifierLayerState();
}

class _ColorThemeNotifierLayerState extends State<ColorThemeNotifierLayer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ColorThemeNotifier>(
      builder: (context, themeColorsNotifier, child) {
        devtools.log(
            ' ==> main | Consumer isOnline: ${themeColorsNotifier.isOnline}');
        return MaterialApp(
          theme: FlexThemeData.light(
            scheme: themeColorsNotifier.themeScheme,
            surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
            blendLevel: 10,
            appBarStyle: FlexAppBarStyle.primary,
            appBarOpacity: 0.92,
            appBarElevation: 2.5,
            transparentStatusBar: true,
            tabBarStyle: FlexTabBarStyle.universal,
            tooltipsMatchBackground: true,
            swapColors: false,
            lightIsWhite: false,
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            fontFamily: 'TitilliumWeb',
            subThemesData: const FlexSubThemesData(
              blendOnLevel: 20,
              blendOnColors: false,
              useTextTheme: true,
              useM2StyleDividerInM3: true,
              alignedDropdown: true,
              useInputDecoratorThemeInDialogs: true,
              fabUseShape: true,
              interactionEffects: true,
              bottomNavigationBarElevation: 0,
              bottomNavigationBarOpacity: 0.95,
              navigationBarOpacity: 0.95,
              navigationBarMutedUnselectedIcon: true,
              inputDecoratorIsFilled: true,
              inputDecoratorBorderType: FlexInputBorderType.outline,
              inputDecoratorUnfocusedHasBorder: true,
              blendTextTheme: true,
              popupMenuOpacity: 0.95,
            ),
          ),
          darkTheme: FlexThemeData.dark(
            scheme: themeColorsNotifier.themeScheme,
            surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
            blendLevel: 10,
            appBarStyle: FlexAppBarStyle.primary,
            appBarOpacity: 0.92,
            appBarElevation: 2.5,
            transparentStatusBar: true,
            tabBarStyle: FlexTabBarStyle.forAppBar,
            tooltipsMatchBackground: true,
            swapColors: false,
            darkIsTrueBlack: false,
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            fontFamily: 'TitilliumWeb',
            subThemesData: const FlexSubThemesData(
              blendOnLevel: 20,
              blendOnColors: false,
              useTextTheme: true,
              useM2StyleDividerInM3: true,
              alignedDropdown: true,
              useInputDecoratorThemeInDialogs: true,
              fabUseShape: true,
              interactionEffects: true,
              bottomNavigationBarElevation: 0,
              bottomNavigationBarOpacity: 0.95,
              navigationBarOpacity: 0.95,
              navigationBarMutedUnselectedIcon: true,
              inputDecoratorIsFilled: true,
              inputDecoratorBorderType: FlexInputBorderType.outline,
              inputDecoratorUnfocusedHasBorder: true,
              blendTextTheme: true,
              popupMenuOpacity: 0.95,
            ),
          ),
          themeMode: themeColorsNotifier.colorMode,
          title: 'My Notes',
          debugShowCheckedModeBanner: false,
          home: (themeColorsNotifier.isOnline)
              ? const CloudHomePage()
              : const LocalHomePage(),
          routes: {
            homePageRoute: (context) => (themeColorsNotifier.isOnline)
                ? const CloudHomePage()
                : const LocalHomePage(),
            registerRoute: (context) => const CloudRegisterView(),
            verifyEmailRoute: (context) => const CloudVerifyEmailView(),
            loginRoute: (context) => (themeColorsNotifier.isOnline)
                ? const CloudLoginView()
                : const LocalLoginView(),
            myNotesRoute: (context) => (themeColorsNotifier.isOnline)
                ? const CloudMyNotesView()
                : const LocalMyNotesView(),
            createOrUpdateNoteRoute: (context) => (themeColorsNotifier.isOnline)
                ? const CloudCreateUpdateNoteView()
                : const LocalCreateUpdateNoteView(),
          },
        );
      },
    );
  }
}
