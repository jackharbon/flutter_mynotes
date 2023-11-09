import 'package:flutter/material.dart';

import '../../services/auth/auth_exceptions.dart';
import '../../services/auth/auth_service.dart';
import '../../constants/routes.dart';
import '../../../shared/helpers/loading/loading_widget.dart';
import '../../../shared/utilities/menus/popup_menu.dart';
import '../../../shared/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
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
        title: const Text(
          'Register (Local)',
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
                                      decorationColor:
                                          Theme.of(context).colorScheme.primary,
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
  }
}
