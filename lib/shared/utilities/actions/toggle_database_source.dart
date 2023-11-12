import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool isOnline = false;
  bool isOnlineDelayed = true;
  Color color = Colors.transparent;

  @override
  initState() {
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
  }

  @override
  dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
      // ? --------------------------------
      devtools.log(
          ' ==> toggle_database_source | initConnectivity() | result: $result');
    } on PlatformException catch (e) {
      // ? --------------------------------
      devtools.log(
          ' ==> toggle_database_source | initConnectivity() | Couldn\'t check connectivity status',
          error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isOnlineDelayed = isOnline;
        // ? --------------------------------
        devtools.log(
            ' ==> register_view | Future.delayed() | isOnlineDelayed: $isOnlineDelayed');
      });
    });
    setState(() {
      _connectionStatus = result;
    });

    switch (_connectionStatus) {
      // --- Phone is offline ---
      case ConnectivityResult.none:
        setState(() {
          isOnline = false;
          color = Theme.of(context).colorScheme.error;
          Provider.of<AppNotifier>(context, listen: false)
              .checkOnlineStatusToggle(false);
        });
      // --- Phone is online ---
      default:
        setState(() {
          isOnline = true;
          color = Theme.of(context).colorScheme.onPrimary;
          Provider.of<AppNotifier>(context, listen: false)
              .checkOnlineStatusToggle(true);
        });
    }
    (isOnlineDelayed != isOnline)
        ? (isOnline)
            ? ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Yuppie! Internet is back!")))
            : null
        : (!isOnline)
            ? ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No Internet connection!")))
            : null;
    // ? --------------------------------
    devtools.log(
        ' ==> toggle_database_source | _updateConnectionStatus() | isOnline: $isOnline, _connectionStatus: $_connectionStatus');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(builder: (context, appStateNotifier, child) {
      return IconButton(
          // ----- APP BAR STORAGE-SOURCE ICON: phone/local (online&offline) cloud/firestore (online&offline) -----
          icon: (appStateNotifier.isCloudStorage)
              // --- Phone is cloud storage mode ---
              ? (isOnline)
                  // --- Phone is online ---
                  ? Icon(
                      Icons.cloud_done_outlined,
                      color: color,
                    )
                  // --- Phone is offline ---
                  : Icon(
                      Icons.cloud_outlined,
                      color: color,
                    )
              // --- Phone is local storage mode ---
              : (isOnline)
                  // --- Phone is online ---
                  ? Icon(
                      Icons.mobile_friendly,
                      color: color,
                    )
                  // --- Phone is offline ---
                  : Icon(
                      Icons.phone_iphone_sharp,
                      color: color,
                    ),
          onPressed: () async {
            // ----- SWITCH THE STORAGE-SOURCE: phone/local (online&offline) cloud/firestore (online&offline) -----
            switch (isOnline) {
              // --- Phone is online ---
              case true:
                switch (appStateNotifier.isCloudStorage) {
                  // --- Switch storage to local ---
                  case true:
                    const title = 'Switch to\nLocal Storage';
                    const content = 'Do you want switch to the phone storage?';
                    final toggleDatabaseSource =
                        await toggleDatabaseSourceDialog(
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
                        appStateNotifier.isCloudStorage =
                            !appStateNotifier.isCloudStorage;
                      });
                      Provider.of<AppNotifier>(context, listen: false)
                          .toggleDatabaseLocation(
                              appStateNotifier.isCloudStorage);
                      final routeArgs = (ModalRoute.of(context) as dynamic)
                          .settings
                          .arguments;
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        routeArgs,
                        (_) => false,
                      );
                    }
                  // --- Switch storage to cloud ---
                  case false:
                    const title = 'Switch to\nCloud Storage';
                    const content =
                        'Do you want and switch to the online storage?';
                    final toggleDatabaseSource =
                        await toggleDatabaseSourceDialog(
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
                        appStateNotifier.isCloudStorage =
                            !appStateNotifier.isCloudStorage;
                      });
                      Provider.of<AppNotifier>(context, listen: false)
                          .toggleDatabaseLocation(
                              appStateNotifier.isCloudStorage);
                      final routeArgs = (ModalRoute.of(context) as dynamic)
                          .settings
                          .arguments;
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        routeArgs,
                        (_) => false,
                      );
                    }
                }
              // --- Phone is offline ---
              case false:
                switch (appStateNotifier.isCloudStorage) {
                  // --- Switch storage to local ---
                  case true:
                    const title = 'No Internet Connection!';
                    const content =
                        "There isn't internet connection!\nPlease logout and switch to the local storage.";
                    final toggleDatabaseSource =
                        await toggleDatabaseSourceDialog(
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
                        appStateNotifier.isCloudStorage =
                            !appStateNotifier.isCloudStorage;
                      });
                      Provider.of<AppNotifier>(context, listen: false)
                          .toggleDatabaseLocation(
                              appStateNotifier.isCloudStorage);
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (_) => false,
                      );
                    }
                  // --- Switch storage to cloud: error ---
                  case false:
                    const title = 'No Internet Connection!';
                    const content =
                        "You can't switch to the cloud storage without internet connection.";
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
