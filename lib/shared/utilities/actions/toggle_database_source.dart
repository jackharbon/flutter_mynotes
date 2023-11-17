// import 'dart:developer' as devtools show log;

// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/routes.dart';
import '../../providers/app_notifier.dart';
import '../dialogs/error_dialog.dart';
import '../dialogs/toggle_database_dialog.dart';

class ToggleDatabaseSource extends StatefulWidget {
  const ToggleDatabaseSource({super.key});

  @override
  State<ToggleDatabaseSource> createState() => _ToggleDatabaseSourceState();
}

class _ToggleDatabaseSourceState extends State<ToggleDatabaseSource> {
  // final Connectivity _connectivity = Connectivity();
  // late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  initState() {
    // _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) async {
    // ? --------------------------------
    // devtools.log(' ==> toggle_database_source | initState() | isDeviceConnected: $isDeviceConnected');
    super.initState();
  }

  @override
  dispose() {
    // _connectivitySubscription.cancel();
    super.dispose();
  }

  // Future<void> initConnectivity() async {
  //   late ConnectivityResult result;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     result = await _connectivity.checkConnectivity();
  //     // ? --------------------------------
  //     devtools.log(' ==> toggle_database_source | initConnectivity() | result: $result');
  //   } on PlatformException catch (e) {
  //     // ? --------------------------------
  //     devtools.log(' ==> toggle_database_source | initConnectivity() | Couldn\'t check connectivity status', error: e);
  //     return;
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) {
  //     return Future.value(null);
  //   }

  //   return _updateConnectionStatus(result);
  // }

  // Future<void> _updateConnectionStatus(ConnectivityResult result) async {
  //   setState(() {
  //     _connectionStatus = result;
  //   });
  //   Future.delayed(const Duration(seconds: 5), () {
  //     setState(() {
  //       isOldValueEqual = isOnline;
  //       // ? --------------------------------
  //       devtools.log(' ==> toggle_database_source | _updateConnectionStatus() | isOldValueEqual: $isOldValueEqual');
  //     });
  //   });

  //   switch (_connectionStatus) {
  //     // --- Phone is offline ---
  //     case ConnectivityResult.none:
  //       setState(() {
  //         isOnline = false;
  //       });
  //       color = Theme.of(context).colorScheme.error;
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No Internet connection!")));
  //       Provider.of<AppNotifier>(context, listen: false).isOnlineAppState(false);
  //       Provider.of<AppNotifier>(context, listen: false).isCloudStorageAppState(false);
  //       // ? --------------------------------
  //       devtools.log(' ==> toggle_database_source | _updateConnectionStatus() | ifOffline - isOnline: $isOnline');
  //       const title = 'No Internet Connection!';
  //       const content = "Please switch on the internet connection to register.";
  //       await showErrorDialog(
  //         context,
  //         content,
  //         title,
  //         Icon(
  //           Icons.cloud_off_outlined,
  //           size: 60,
  //           color: Theme.of(context).colorScheme.error,
  //         ),
  //       );
  //     // --- Phone is online ---
  //     default:
  //       setState(() {
  //         isOnline = true;
  //         color = Theme.of(context).colorScheme.onPrimary;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Yuppie! Internet is back!")));
  //       Provider.of<AppNotifier>(context, listen: false).isOnlineAppState(true);
  //       // ? --------------------------------
  //       devtools.log(' ==> toggle_database_source | _updateConnectionStatus() | ifOnline - isOnline: $isOnline');
  //   }
  //   (isOldValueEqual != isOnline)
  //       ? (isOnline)
  //           ? ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Yuppie! Internet is back!")))
  //           : null
  //       : (!isOnline)
  //           ? ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No Internet connection!")))
  //           : null;
  //   // ? --------------------------------
  //   devtools.log(' ==> register_view | _updateConnectionStatus() | isOnline: $isOnline');
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(builder: (context, appStateNotifier, child) {
      return IconButton(
          // ----- APP BAR STORAGE-SOURCE ICON: phone/local (online&offline) cloud/firestore (online&offline) -----
          icon: (appStateNotifier.isCloudStorage)
              // --- Phone is cloud storage mode ---
              ? (appStateNotifier.isOnline)
                  // --- Phone is online ---
                  ? Icon(
                      Icons.cloud_done_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  // --- Phone is offline ---
                  : Icon(
                      Icons.cloud_outlined,
                      color: Theme.of(context).colorScheme.error,
                    )
              // --- Phone is local storage mode ---
              : (appStateNotifier.isOnline)
                  // --- Phone is online ---
                  ? Icon(
                      Icons.mobile_friendly,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  // --- Phone is offline ---
                  : Icon(
                      Icons.phone_iphone_sharp,
                      color: Theme.of(context).colorScheme.error,
                    ),
          onPressed: () async {
            // ----- SWITCH THE STORAGE-SOURCE: phone/local (online&offline) cloud/firestore (online&offline) -----
            switch (appStateNotifier.isOnline) {
              // --- Phone is online ---
              case true:
                switch (appStateNotifier.isCloudStorage) {
                  // --- Switch storage to local ---
                  case true:
                    const title = 'Switch to\nLocal Storage';
                    const content = 'Do you want switch to the phone storage?';
                    final toggleDatabaseSource = await toggleDatabaseSourceDialog(
                      context,
                      title,
                      content,
                      Icon(
                        Icons.mobile_friendly,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                    if (toggleDatabaseSource) {
                      setState(() {
                        appStateNotifier.isCloudStorage = !appStateNotifier.isCloudStorage;
                      });
                      Provider.of<AppNotifier>(context, listen: false)
                          .isCloudStorageAppState(appStateNotifier.isCloudStorage);
                      final routeArgs = (ModalRoute.of(context) as dynamic).settings.arguments;
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        routeArgs,
                        (_) => false,
                      );
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("You are in Local Storage mode!")));
                    }
                  // --- Switch storage to cloud ---
                  case false:
                    const title = 'Switch to\nCloud Storage';
                    const content = 'Do you want and switch to the online storage?';
                    final toggleDatabaseSource = await toggleDatabaseSourceDialog(
                      context,
                      title,
                      content,
                      Icon(
                        Icons.cloud_done_outlined,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                    if (toggleDatabaseSource) {
                      setState(() {
                        appStateNotifier.isCloudStorage = !appStateNotifier.isCloudStorage;
                      });
                      Provider.of<AppNotifier>(context, listen: false)
                          .isCloudStorageAppState(appStateNotifier.isCloudStorage);
                      final routeArgs = (ModalRoute.of(context) as dynamic).settings.arguments;
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        routeArgs,
                        (_) => false,
                      );
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("You are in Cloud Storage mode!")));
                    }
                }
              // --- Phone is offline ---
              case false:
                switch (appStateNotifier.isCloudStorage) {
                  // --- Switch storage to local ---
                  case true:
                    const title = 'No Internet Connection!';
                    const content = "There isn't internet connection!\nPlease logout and switch to the local storage.";
                    final toggleDatabaseSource = await toggleDatabaseSourceDialog(
                      context,
                      title,
                      content,
                      Icon(
                        Icons.phone_iphone_sharp,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                    if (toggleDatabaseSource) {
                      setState(() {
                        appStateNotifier.isCloudStorage = !appStateNotifier.isCloudStorage;
                      });
                      Provider.of<AppNotifier>(context, listen: false)
                          .isCloudStorageAppState(appStateNotifier.isCloudStorage);
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (_) => false,
                      );
                    }
                  // --- Switch storage to cloud: error ---
                  case false:
                    const title = 'No Internet Connection!';
                    const content = "You can't switch to the cloud storage without internet connection.";
                    await showErrorDialog(
                      context,
                      content,
                      title,
                      Icon(
                        Icons.cloud_off_outlined,
                        size: 60,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    );
                }
            }
          });
    });
  }
}
