import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/helpers/loading/loading_screen.dart';
import '../../../shared/services/crud/notes_services.dart';
import '../../../shared/utilities/actions/online_status_icon.dart';
import '../../services/auth/auth_exceptions.dart';
import '../../services/auth/auth_service.dart';
import '../../../shared/utilities/dialogs/error_dialog.dart';
import '../../services/auth/bloc/auth_bloc.dart';
import '../../services/auth/bloc/auth_event.dart';
import '../../services/auth/bloc/auth_state.dart';

class CloudLoginView extends StatefulWidget {
  const CloudLoginView({super.key});

  @override
  State<CloudLoginView> createState() => _CloudLoginViewState();
}

class _CloudLoginViewState extends State<CloudLoginView> {
  late final LocalNotesService _notesService;
  late final TextEditingController _email;
  late final TextEditingController _password;
  DatabaseUser? localCurrentUser;

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is MissingDataAuthException) {
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
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
              context,
              'Invalid email!\nPlease check your email address.',
              'Login Failed!',
              Icon(
                Icons.email,
                size: 60,
                color: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state.exception is UserNotFoundAuthException) {
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
          } else if (state.exception is WrongPasswordAuthException) {
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
          } else if (state.exception is UnknownAuthException) {
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
          } else if (state.exception is GenericAuthException) {
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
        }
      },
      child: Scaffold(
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
          actions: const [],
        ),
        body: FutureBuilder(
            future: _notesService.open(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return FutureBuilder(
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
                                              context.read<AuthBloc>().add(
                                                    AuthEventLogIn(
                                                      email,
                                                      password,
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
                                              onPressed: () {
                                                context.read<AuthBloc>().add(
                                                      const AuthEventShouldRegister(),
                                                    );
                                              },
                                              child: Text(
                                                "Register here.",
                                                style: TextStyle(
                                                  shadows: [
                                                    Shadow(
                                                        color: Theme.of(context).colorScheme.primary,
                                                        offset: const Offset(0, -2))
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
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Forgot password?",
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.outline,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                context.read<AuthBloc>().add(
                                                      const AuthEventForgotPassword(),
                                                    );
                                              },
                                              child: Text(
                                                "Reset password here.",
                                                style: TextStyle(
                                                  shadows: [
                                                    Shadow(
                                                        color: Theme.of(context).colorScheme.primary,
                                                        offset: const Offset(0, -2))
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
                  );
                default:
                  return const LoadingStandardProgressBar();
              }
            }),
      ),
    );
  }
}
