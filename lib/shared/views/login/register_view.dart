import 'dart:developer' as devtools show log;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../cloud/services/auth/auth_exceptions.dart';
import '../../../cloud/services/auth/auth_service.dart';
import '../../constants/routes.dart';
import '../../helpers/loading/loading_widget.dart';
import '../../providers/app_notifier.dart';
import '../../utilities/actions/popup_menu.dart';
import '../../utilities/dialogs/error_dialog.dart';

class CloudRegisterView extends StatefulWidget {
  const CloudRegisterView({super.key});

  @override
  State<CloudRegisterView> createState() => _CloudRegisterViewState();
}

class _CloudRegisterViewState extends State<CloudRegisterView> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool isOnline = true;
  bool isOnlineDelayed = true;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
      // ? --------------------------------
      // devtools.log(' ==> register_view | initConnectivity() | result: $result');
    } on PlatformException catch (e) {
      // ? --------------------------------
      devtools.log(
          ' ==> register_view | initConnectivity() | Couldn\'t check connectivity status',
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
    setState(() {
      _connectionStatus = result;
    });
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isOnlineDelayed = isOnline;
        // ? --------------------------------
        devtools.log(
            ' ==> register_view | Future.delayed() | isOnlineDelayed: $isOnlineDelayed');
      });
    });

    switch (_connectionStatus) {
      // --- Phone is offline ---
      case ConnectivityResult.none:
        setState(() {
          isOnline = false;
        });
        Provider.of<AppNotifier>(context, listen: false)
            .checkOnlineStatusToggle(false);
        const title = 'No Internet Connection!';
        const content = "Please switch on the internet connection to register.";
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
      // --- Phone is online ---
      default:
        setState(() {
          isOnline = true;
        });
        Provider.of<AppNotifier>(context, listen: false)
            .checkOnlineStatusToggle(true);
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
        ' ==> register_view | _updateConnectionStatus() | isOnline: $isOnline');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(builder: (context, appStateNotifier, child) {
      return Scaffold(
        backgroundColor: (isOnline)
            ? Theme.of(context).colorScheme.background
            : Theme.of(context).colorScheme.errorContainer,
        appBar: AppBar(
          backgroundColor: (isOnline)
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: (isOnline)
                    ? const Icon(Icons.cloud_done_outlined)
                    : const Icon(Icons.cloud_outlined),
                color: (isOnline)
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onError,
                onPressed: () {},
              ),
              const Text(
                'Register',
              ),
            ],
          ),
          actions: [
            popupMenuItems(context),
          ],
        ),
        body: FutureBuilder(
          future: AuthService.firebase().initialize(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 60,
                          child: Icon(
                            Icons.person_add,
                            size: 60.0,
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        const Text(
                          'Please register create your notes!',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        TextField(
                          enabled: (isOnline) ? true : false,
                          controller: _email,
                          enableSuggestions: false,
                          autocorrect: false,
                          autofocus: true,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          enabled: (isOnline) ? true : false,
                          controller: _password,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                          ),
                        ),
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    textStyle: const TextStyle(fontSize: 20)),
                                onPressed: () async {
                                  final email = _email.text;
                                  final password = _password.text;
                                  try {
                                    await AuthService.firebase().createUser(
                                      email: email,
                                      password: password,
                                    );
                                    await AuthService.firebase()
                                        .sendEmailVerification();
                                    await Navigator.of(context)
                                        .pushNamed(verifyEmailRoute);
                                  } on MissingDataAuthException {
                                    await showErrorDialog(
                                      context,
                                      'Missing credentials!\nPlease check the form fields.',
                                      'Register failed!',
                                      Icon(
                                        Icons.text_fields,
                                        size: 60,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    );
                                  } on InvalidEmailAuthException {
                                    await showErrorDialog(
                                      context,
                                      'Invalid email!\nPlease check your input.',
                                      'Register failed!',
                                      Icon(
                                        Icons.email,
                                        size: 60,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    );
                                  } on EmailAlreadyInUseAuthException {
                                    await showErrorDialog(
                                      context,
                                      'Email is already registered!\nPlease login.',
                                      'Register failed!',
                                      Icon(
                                        Icons.email,
                                        size: 60,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    );
                                  } on WeakPasswordAuthException {
                                    await showErrorDialog(
                                      context,
                                      'Weak password!\nPlease enter a stronger password.',
                                      'Register failed!',
                                      Icon(
                                        Icons.password,
                                        size: 60,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    );
                                  } on UnknownAuthException {
                                    await showErrorDialog(
                                      context,
                                      'Failed to register!\nPlease try again later.',
                                      'Register failed!',
                                      Icon(
                                        Icons.person_add_disabled,
                                        size: 60,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    );
                                  } on GenericAuthException {
                                    await showErrorDialog(
                                      context,
                                      'Failed to register!\n Please try again later.',
                                      'Register failed!',
                                      Icon(
                                        Icons.person_add_disabled,
                                        size: 60,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    );
                                  } catch (e) {
                                    await showErrorDialog(
                                      context,
                                      'Failed to register.n Please try again later.',
                                      'Register failed!',
                                      Icon(
                                        Icons.person_add_disabled,
                                        size: 60,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Register',
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already registered?",
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                        loginRoute,
                                        (route) => false,
                                      );
                                    },
                                    child: Text(
                                      "Login here.",
                                      style: TextStyle(
                                        shadows: [
                                          Shadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              offset: const Offset(0, -2))
                                        ],
                                        fontSize: 16,
                                        color: Colors.transparent,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        decorationThickness: 2,
                                        decorationStyle:
                                            TextDecorationStyle.dashed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              default:
                return const LoadingStandardProgressBar();
            }
          },
        ),
      );
    });
  }
}
