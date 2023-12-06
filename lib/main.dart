//  import 'dart:developer' as devtools show log;

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
        // ? --------------------------------
        //  devtools.log(' ==> main | StreamBuilder() | snapshot.data: ${snapshot.data}');
        return Consumer<AppNotifier>(builder: (context, appStateNotifier, child) {
          switch (snapshot.data) {
            case null:
              Provider.of<AppNotifier>(context, listen: false).isOnlineAppState(false);
              Provider.of<AppNotifier>(context, listen: false).isCloudStorageAppState(false);
            // ? --------------------------------
            //  devtools.log(' ==> main | GetOnlineMaterialApp() | isCloudStorage: ${appStateNotifier.isCloudStorage}');
            //  devtools.log(' ==> main | GetOnlineMaterialApp() | isOnline: ${appStateNotifier.isOnline}');
            // return const LoadingStandardProgressBar();
            case ConnectivityResult.none:
              Provider.of<AppNotifier>(context, listen: false).isOnlineAppState(false);
              Provider.of<AppNotifier>(context, listen: false).isCloudStorageAppState(false);
              // ? --------------------------------
              //  devtools.log(' ==> main | GetOnlineMaterialApp() | isCloudStorage: ${appStateNotifier.isCloudStorage}');
              //  devtools.log(' ==> main | GetOnlineMaterialApp() | isOnline: ${appStateNotifier.isOnline}');
              return const GetOnlineMaterialApp();
            default:
              Provider.of<AppNotifier>(context, listen: false).isOnlineAppState(true);
              Provider.of<AppNotifier>(context, listen: false).isCloudStorageAppState(true);
              // ? --------------------------------
              //  devtools.log(' ==> main | GetOnlineMaterialApp() | isCloudStorage: ${appStateNotifier.isCloudStorage}');
              //  devtools.log(' ==> main | GetOnlineMaterialApp() | isOnline: ${appStateNotifier.isOnline}');
              return const GetOnlineMaterialApp();
          }
          return const GetOnlineMaterialApp();
        });
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
        title: 'Main Page (cloud)',
        debugShowCheckedModeBanner: false,
        home: (appStateNotifier.isOnline) ? const CloudHomePage() : const LocalHomePage(),
        routes: {
          homePageRoute: (context) => (appStateNotifier.isOnline) ? const CloudHomePage() : const LocalHomePage(),
          registerRoute: (context) => const CloudRegisterView(),
          verifyEmailRoute: (context) => const CloudVerifyEmailView(),
          loginRoute: (context) => (appStateNotifier.isOnline) ? const CloudLoginView() : const LocalLoginView(),
          myNotesRoute: (context) => (appStateNotifier.isOnline) ? const CloudMyNotesView() : const LocalMyNotesView(),
          createOrUpdateNoteRoute: (context) =>
              (appStateNotifier.isOnline) ? const CloudCreateUpdateNoteView() : const LocalCreateUpdateNoteView(),
        },
      );
    });
  }
}
