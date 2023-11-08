import 'dart:developer' as devtools show log;

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mynotes/constants/local/local_routes.dart';
import 'package:mynotes/helpers/loading/loading_widget.dart';
import 'package:mynotes/services/local/auth/local_auth_service.dart';
import 'package:mynotes/providers/theme_notifier.dart';
import 'package:mynotes/views/local/login/local_login_view.dart';
import 'package:mynotes/views/local/notes/local_create_update_note_view.dart';
import 'package:mynotes/views/local/notes/local_notes_view.dart';
import 'package:mynotes/views/local/login/local_register_view.dart';
import 'package:mynotes/views/local/login/local_verify_email_view.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    ChangeNotifierProvider<ColorThemeNotifier>(
      create: (BuildContext context) {
        return ColorThemeNotifier();
      },
      child: const ColorThemeNotifierLayer(),
    ),
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
          home: const HomePage(),
          routes: {
            homePageRouteLocal: (context) => const RegisterViewLocal(),
            registerRouteLocal: (context) => const RegisterViewLocal(),
            verifyEmailRouteLocal: (context) => const VerifyEmailViewLocal(),
            loginRouteLocal: (context) => const LoginViewLocal(),
            myNotesRouteLocal: (context) => const MyNotesViewLocal(),
            createOrUpdateNoteRouteLocal: (context) =>
                const CreateUpdateNoteViewLocal(),
          },
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthServiceLocal.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthServiceLocal.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                // ? ----------------------------------------
                devtools.log(
                    ' ==> main | FutureBuilder | email verified: ${user.email.toString()}');
                return const LoginViewLocal();
              } else {
                devtools.log(
                    ' ==> main | FutureBuilder | email not verified: ${user.email.toString()}');
                return const VerifyEmailViewLocal();
              }
            } else {
              devtools.log(
                  ' ==> main | FutureBuilder | user is null: ${user.toString()}');
              return const RegisterViewLocal();
            }
          default:
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Please wait...',
                ),
              ),
              body: const Center(
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: LoadingStandardProgressBar(),
                ),
              ),
            );
        }
      },
    );
  }
}
