import 'package:flutter/material.dart';
import 'package:mynotes/services/local/auth/local_auth_exceptions.dart';
import 'package:mynotes/services/local/auth/local_auth_service.dart';
import 'package:mynotes/constants/local/local_routes.dart';
import 'package:mynotes/helpers/loading/loading_widget.dart';
import 'package:mynotes/utilities/menus/popup_menu.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';

class RegisterViewLocal extends StatefulWidget {
  const RegisterViewLocal({super.key});

  @override
  State<RegisterViewLocal> createState() => _RegisterViewLocalState();
}

class _RegisterViewLocalState extends State<RegisterViewLocal> {
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
          'Register',
        ),
        actions: [
          popupMenuItems(context),
        ],
      ),
      body: FutureBuilder(
        future: AuthServiceLocal.firebase().initialize(),
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
                                  await AuthServiceLocal.firebase().createUser(
                                    email: email,
                                    password: password,
                                  );
                                  await AuthServiceLocal.firebase()
                                      .sendEmailVerification();
                                  await Navigator.of(context)
                                      .pushNamed(verifyEmailRouteLocal);
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
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  loginRouteLocal,
                                  (route) => false,
                                );
                              },
                              child:
                                  const Text('Already registered? Login here.'),
                            )
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
