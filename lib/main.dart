import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'cloud/services/auth/bloc/auth_bloc.dart';
import 'cloud/services/auth/bloc/auth_event.dart';
import 'cloud/services/auth/bloc/auth_state.dart';
import 'cloud/services/auth/firebase_auth_provider.dart';
import 'cloud/views/login/login_view.dart';
import 'shared/extensions/dependency_injection.dart';
import 'shared/helpers/loading/loading_widget.dart';
import 'shared/views/login/register_view.dart';
import 'shared/views/login/verify_email_view.dart';
import 'cloud/views/notes/create_update_note_view.dart';
import 'cloud/views/notes/notes_view.dart';
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
        debugPrint('|===> main | AppStateNotifierLayer() | StreamBuilder | snapshot.data: ${snapshot.data}');
        return Consumer<AppNotifier>(builder: (context, appStateNotifier, child) {
          switch (snapshot.data) {
            case null:
              Provider.of<AppNotifier>(context, listen: false).isOnlineAppState(false);
              Provider.of<AppNotifier>(context, listen: false).isCloudStorageAppState(false);
              // ? --------------------------------
              debugPrint('|===> main | AppStateNotifierLayer() | isCloudStorage: ${appStateNotifier.isCloudStorage}');
              debugPrint('|===> main | AppStateNotifierLayer() | isOnline: ${appStateNotifier.isOnline}');
            case ConnectivityResult.none:
              Provider.of<AppNotifier>(context, listen: false).isOnlineAppState(false);
              Provider.of<AppNotifier>(context, listen: false).isCloudStorageAppState(false);
              // ? --------------------------------
              debugPrint('|===> main | AppStateNotifierLayer() | isCloudStorage: ${appStateNotifier.isCloudStorage}');
              debugPrint('|===> main | AppStateNotifierLayer() | isOnline: ${appStateNotifier.isOnline}');
              return const MyNotesApp();
            default:
              Provider.of<AppNotifier>(context, listen: false).isOnlineAppState(true);
              Provider.of<AppNotifier>(context, listen: false).isCloudStorageAppState(true);
              // ? --------------------------------
              debugPrint('|===> main | AppStateNotifierLayer() | isCloudStorage: ${appStateNotifier.isCloudStorage}');
              debugPrint('|===> main | AppStateNotifierLayer() | isOnline: ${appStateNotifier.isOnline}');
              return const MyNotesApp();
          }
          return const MyNotesApp();
        });
      },
    );
  }
}

class MyNotesApp extends StatefulWidget {
  const MyNotesApp({
    super.key,
  });

  @override
  State<MyNotesApp> createState() => _MyNotesAppState();
}

class _MyNotesAppState extends State<MyNotesApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(builder: (context, appStateNotifier, child) {
      return GetMaterialApp(
        theme: FlexThemeData.light(
          scheme: appStateNotifier.flexScheme,
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
          scheme: appStateNotifier.flexScheme,
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
        themeMode: appStateNotifier.themeMode,
        title: 'Main Page',
        debugShowCheckedModeBanner: false,
        home: BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(FirebaseAuthProvider()),
          child: const HomePage(),
        ),
        routes: {
          loginRoute: (context) => (appStateNotifier.isOnline) ? const CloudLoginView() : const LocalLoginView(),
          registerRoute: (context) => const CloudRegisterView(),
          myNotesRoute: (context) => (appStateNotifier.isOnline) ? const CloudMyNotesView() : const LocalMyNotesView(),
          verifyEmailRoute: (context) => const CloudVerifyEmailView(),
          createOrUpdateNoteRoute: (context) =>
              (appStateNotifier.isOnline) ? const CloudCreateUpdateNoteView() : const LocalCreateUpdateNoteView(),
          // homePageRoute: (context) => const HomePage(),
        },
      );
    });
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return Consumer<AppNotifier>(builder: (context, appStateNotifier, child) {
      return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthStateLoggedIn) {
            return (appStateNotifier.isOnline) ? const CloudMyNotesView() : const LocalMyNotesView();
          } else if (state is AuthStateNeedsVerification) {
            return const CloudVerifyEmailView();
          } else if (state is AuthStateLoggedOut) {
            return (appStateNotifier.isOnline) ? const CloudLoginView() : const LocalLoginView();
          } else {
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Please wait...',
                ),
              ),
              body: const LoadingStandardProgressBar(),
            );
          }
        },
      );
    });
  }
}

// TODO: remove bloc example
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late final TextEditingController _controller;

//   @override
//   void initState() {
//     _controller = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => CounterBloc(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Counter'),
//         ),
//         body: BlocConsumer<CounterBloc, CounterState>(
//           listener: (context, state) {
//             _controller.clear();
//           },
//           builder: (context, state) {
//             final invalidValue = (state is CounterStateInvalidNumber) ? state.invalidValue : '';
//             return Column(children: [
//               Text(
//                 'Current value is ${state.value}',
//                 style: const TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Visibility(
//                 visible: state is CounterStateInvalidNumber,
//                 child: Text(
//                   'Invalid input: $invalidValue',
//                   style: const TextStyle(
//                     fontSize: 20,
//                   ),
//                 ),
//               ),
//               TextField(
//                 controller: _controller,
//                 decoration: const InputDecoration(
//                   hintText: 'Enter a number here',
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   TextButton(
//                     onPressed: () {
//                       context.read<CounterBloc>().add(DecrementEvent(_controller.text));
//                     },
//                     child: const Text(
//                       '-',
//                       style: TextStyle(
//                         fontSize: 40,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       context.read<CounterBloc>().add(IncrementEvent(_controller.text));
//                     },
//                     child: const Text(
//                       '+',
//                       style: TextStyle(
//                         fontSize: 40,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//             ]);
//           },
//         ),
//       ),
//     );
//   }
// }

// @immutable
// abstract class CounterState {
//   final int value;
//   const CounterState(this.value);
// }

// class CounterStateValid extends CounterState {
//   const CounterStateValid(super.value);
// }

// class CounterStateInvalidNumber extends CounterState {
//   final String invalidValue;
//   const CounterStateInvalidNumber({
//     required this.invalidValue,
//     required int previousValue,
//   }) : super(previousValue);
// }

// @immutable
// abstract class CounterEvent {
//   final String value;
//   const CounterEvent(this.value);
// }

// class IncrementEvent extends CounterEvent {
//   const IncrementEvent(super.value);
// }

// class DecrementEvent extends CounterEvent {
//   const DecrementEvent(super.value);
// }

// class CounterBloc extends Bloc<CounterEvent, CounterState> {
//   CounterBloc() : super(const CounterStateValid(0)) {
//     on<IncrementEvent>((event, emit) {
//       final integer = int.tryParse(event.value);
//       if (integer == null) {
//         emit(CounterStateInvalidNumber(
//           invalidValue: event.value,
//           previousValue: state.value,
//         ));
//       } else {
//         emit(CounterStateValid(
//           state.value + integer,
//         ));
//       }
//     });
//     on<DecrementEvent>((event, emit) {
//       final integer = int.tryParse(event.value);
//       if (integer == null) {
//         emit(CounterStateInvalidNumber(
//           invalidValue: event.value,
//           previousValue: state.value,
//         ));
//       } else {
//         emit(CounterStateValid(
//           state.value - integer,
//         ));
//       }
//     });
//   }
// }
