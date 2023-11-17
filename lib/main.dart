import 'dart:developer' as devtools show log;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'cloud/views/home_view.dart';
import 'cloud/views/login/login_view.dart';
import 'shared/extensions/dependency_injection.dart';
import 'shared/views/login/register_view.dart';
import 'shared/views/login/verify_email_view.dart';
import 'cloud/views/notes/create_update_note_view.dart';
import 'cloud/views/notes/notes_view.dart';
import 'local/views/home_view.dart';
import 'local/views/login/login_view.dart';
import 'local/views/notes/create_update_note_view.dart';
import 'local/views/notes/notes_view.dart';
import 'shared/constants/routes.dart';
import 'shared/providers/app_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    ChangeNotifierProvider<AppNotifier>(
        create: (BuildContext context) {
          return AppNotifier();
        },
        child: const AppStateNotifierLayer()),
  );
  FlutterNativeSplash.remove();
  DependencyInjection.init();
}

class AppStateNotifierLayer extends StatefulWidget {
  const AppStateNotifierLayer({super.key});

  @override
  State<AppStateNotifierLayer> createState() => _AppStateNotifierLayerState();
}

class _AppStateNotifierLayerState extends State<AppStateNotifierLayer> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, AsyncSnapshot<ConnectivityResult> snapshot) {
        return snapshot.data == ConnectivityResult.mobile || snapshot.data == ConnectivityResult.wifi
            ? const GetOnlineMaterialApp()
            : const GetOfflineMaterialApp();
      },
    );
  }
}

class GetOnlineMaterialApp extends StatelessWidget {
  const GetOnlineMaterialApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(builder: (context, appStateNotifier, child) {
      Provider.of<AppNotifier>(context, listen: false).isOnlineAppState(true);
      devtools.log(
          ' ==> main | GetOnlineMaterialApp() | Consumer isCloudStorage: ${appStateNotifier.isCloudStorage}, isOnline: ${appStateNotifier.isOnline}');
      return GetMaterialApp(
        theme: FlexThemeData.light(
          scheme: appStateNotifier.themeScheme,
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
          scheme: appStateNotifier.themeScheme,
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
        themeMode: appStateNotifier.colorMode,
        title: 'My Notes',
        debugShowCheckedModeBanner: false,
        home: (appStateNotifier.isOnline)
            ? (appStateNotifier.isCloudStorage)
                ? const CloudHomePage()
                : const LocalHomePage()
            : const LocalHomePage(),
        routes: {
          homePageRoute: (context) => (appStateNotifier.isOnline)
              ? (appStateNotifier.isCloudStorage)
                  ? const CloudHomePage()
                  : const LocalHomePage()
              : const LocalHomePage(),
          registerRoute: (context) => const CloudRegisterView(),
          verifyEmailRoute: (context) => const CloudVerifyEmailView(),
          loginRoute: (context) => (appStateNotifier.isOnline)
              ? (appStateNotifier.isCloudStorage)
                  ? const CloudLoginView()
                  : const LocalLoginView()
              : const LocalLoginView(),
          myNotesRoute: (context) => (appStateNotifier.isOnline)
              ? (appStateNotifier.isCloudStorage)
                  ? const CloudMyNotesView()
                  : const LocalMyNotesView()
              : const LocalMyNotesView(),
          createOrUpdateNoteRoute: (context) => (appStateNotifier.isOnline)
              ? (appStateNotifier.isCloudStorage)
                  ? const CloudCreateUpdateNoteView()
                  : const LocalCreateUpdateNoteView()
              : const LocalCreateUpdateNoteView(),
        },
      );
    });
  }
}

class GetOfflineMaterialApp extends StatelessWidget {
  const GetOfflineMaterialApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(builder: (context, appStateNotifier, child) {
      Provider.of<AppNotifier>(context, listen: false).isOnlineAppState(false);
      devtools.log(
          ' ==> main | GetOnlineMaterialApp() | Consumer isCloudStorage: ${appStateNotifier.isCloudStorage}, isOnline: ${appStateNotifier.isOnline}');
      return GetMaterialApp(
        theme: FlexThemeData.light(
          scheme: appStateNotifier.themeScheme,
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
          scheme: appStateNotifier.themeScheme,
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
        themeMode: appStateNotifier.colorMode,
        title: 'My Notes',
        debugShowCheckedModeBanner: false,
        home: const LocalHomePage(),
        routes: {
          homePageRoute: (context) => const LocalHomePage(),
          registerRoute: (context) => const CloudRegisterView(),
          verifyEmailRoute: (context) => const CloudVerifyEmailView(),
          loginRoute: (context) => const LocalLoginView(),
          myNotesRoute: (context) => const LocalMyNotesView(),
          createOrUpdateNoteRoute: (context) => const LocalCreateUpdateNoteView(),
        },
      );
    });
  }
}
