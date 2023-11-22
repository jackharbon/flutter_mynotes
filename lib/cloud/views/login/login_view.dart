import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';

import '../../../shared/services/crud/notes_services.dart';
import '../../../shared/utilities/actions/online_status_icon.dart';
import '../../services/auth/auth_exceptions.dart';
import '../../services/auth/auth_service.dart';
import '../../../shared/constants/routes.dart';
import '../../../shared/helpers/loading/loading_widget.dart';
import '../../../shared/utilities/actions/popup_menu.dart';
import '../../../shared/utilities/dialogs/error_dialog.dart';

class CloudLoginView extends StatefulWidget {
  const CloudLoginView({super.key});

  @override
  State<CloudLoginView> createState() => _CloudLoginViewState();
}

class _CloudLoginViewState extends State<CloudLoginView> {
  late final LocalNotesService _notesService;
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _notesService = LocalNotesService();
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            OnlineStatusIcon(),
            Text(
              'Login(cloud)',
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
                          Icons.person,
                          size: 60.0,
                        ), //Text
                      ), //Circle
                      const SizedBox(
                        height: 50,
                      ),
                      const Text(
                        'Login to your account to see your notes.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      TextField(
                        controller: _email,
                        enableSuggestions: false,
                        autocorrect: false,
                        autofocus: false,
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
                              style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
                              onPressed: () async {
                                final email = _email.text;
                                final password = _password.text;
                                try {
                                  await AuthService.firebase().logIn(
                                    email: email,
                                    password: password,
                                  );
                                  final user = AuthService.firebase().currentUser;
                                  if (user != null) {
                                    if (user.isEmailVerified) {
                                      _notesService.updateLocalIsEmailVerified(email: email);
                                      await Navigator.of(context).pushNamedAndRemoveUntil(
                                        myNotesRoute,
                                        (route) => false,
                                      );
                                      // ? --------------------------------
                                      devtools.log(' ==> login_view (cloud) | login button | email verified: $email');
                                    } else {
                                      await Navigator.of(context).pushNamed(verifyEmailRoute);
                                    }
                                  } else {
                                    await Navigator.of(context).pushNamedAndRemoveUntil(
                                      registerRoute,
                                      (route) => false,
                                    );
                                  }
                                } on MissingDataAuthException {
                                  await showErrorDialog(
                                    context,
                                    'Missing credentials!\nPlease check the form fields.',
                                    'Login Failed!',
                                    Icon(
                                      Icons.text_fields,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                } on InvalidEmailAuthException {
                                  await showErrorDialog(
                                    context,
                                    'Invalid emai!\nPlease check your email address.',
                                    'Login Failed!',
                                    Icon(
                                      Icons.email,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                } on UserNotFoundAuthException {
                                  await showErrorDialog(
                                    context,
                                    'User not found!\nEnter correct email or register.',
                                    'Login Failed!',
                                    Icon(
                                      Icons.person_off_rounded,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                } on WrongPasswordAuthException {
                                  await showErrorDialog(
                                    context,
                                    'Wrong password!\nPlease type again.',
                                    'Login Failed!',
                                    Icon(
                                      Icons.password,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                } on UnknownAuthException {
                                  await showErrorDialog(
                                    context,
                                    'Authentication error!\nPlease try again later.',
                                    'Login Failed!',
                                    Icon(
                                      Icons.person_off_rounded,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                } on GenericAuthException {
                                  await showErrorDialog(
                                    context,
                                    'Authentication error!\nPlease try again later.',
                                    'Login Failed!',
                                    Icon(
                                      Icons.person_off_rounded,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                } catch (e) {
                                  await showErrorDialog(
                                    context,
                                    'Authentication error!\nPlease try again later.',
                                    'Login Failed!',
                                    Icon(
                                      Icons.person_off_rounded,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Not registered?",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.outline,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                      registerRoute,
                                      (route) => false,
                                    );
                                  },
                                  child: Text(
                                    "Register here.",
                                    style: TextStyle(
                                      shadows: [
                                        Shadow(
                                            color: Theme.of(context).colorScheme.primary, offset: const Offset(0, -2))
                                      ],
                                      fontSize: 16,
                                      color: Colors.transparent,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Theme.of(context).colorScheme.primary,
                                      decorationThickness: 2,
                                      decorationStyle: TextDecorationStyle.dashed,
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
  }
}
