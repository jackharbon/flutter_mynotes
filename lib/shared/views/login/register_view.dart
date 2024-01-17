import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../cloud/services/auth/auth_exceptions.dart';
import '../../../cloud/services/auth/auth_service.dart';
import '../../../cloud/services/auth/bloc/auth_bloc.dart';
import '../../../cloud/services/auth/bloc/auth_event.dart';
import '../../../cloud/services/auth/bloc/auth_state.dart';
// import '../../services/crud/notes_services.dart';
import '../../helpers/loading/loading_widget.dart';
import '../../providers/app_notifier.dart';
import '../../utilities/actions/online_status_icon.dart';
import '../../utilities/dialogs/error_dialog.dart';

class CloudRegisterView extends StatefulWidget {
  const CloudRegisterView({super.key});

  @override
  State<CloudRegisterView> createState() => _CloudRegisterViewState();
}

class _CloudRegisterViewState extends State<CloudRegisterView> {
  // late final LocalNotesService _notesService;
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    // _notesService = LocalNotesService();
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
    return Consumer<AppNotifier>(builder: (context, appStateNotifier, child) {
      return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateRegistering) {
            if (state.exception is MissingDataAuthException) {
              await showErrorDialog(
                context,
                'Missing credentials!\nPlease check the form fields.',
                'Register Failed!',
                Icon(
                  Icons.text_fields,
                  size: 60,
                  color: Theme.of(context).colorScheme.error,
                ),
              );
            } else if (state.exception is InvalidEmailAuthException) {
              await showErrorDialog(
                context,
                'Invalid email!\nPlease check your input.',
                'Register Failed!',
                Icon(
                  Icons.email,
                  size: 60,
                  color: Theme.of(context).colorScheme.error,
                ),
              );
            } else if (state.exception is EmailAlreadyInUseAuthException) {
              await showErrorDialog(
                context,
                'Email is already registered!\nPlease login.',
                'Register Failed!',
                Icon(
                  Icons.email,
                  size: 60,
                  color: Theme.of(context).colorScheme.error,
                ),
              );
            } else if (state.exception is WeakPasswordAuthException) {
              await showErrorDialog(
                context,
                'Weak password!\nPlease enter a stronger password.',
                'Register Failed!',
                Icon(
                  Icons.password,
                  size: 60,
                  color: Theme.of(context).colorScheme.error,
                ),
              );
            } else if (state.exception is UnknownAuthException) {
              await showErrorDialog(
                context,
                'Failed to register!\nPlease try again later.',
                'Register Failed!',
                Icon(
                  Icons.person_add_disabled,
                  size: 60,
                  color: Theme.of(context).colorScheme.error,
                ),
              );
            } else if (state.exception is GenericAuthException) {
              await showErrorDialog(
                context,
                'Failed to register!\n Please try again later.',
                'Register Failed!',
                Icon(
                  Icons.person_add_disabled,
                  size: 60,
                  color: Theme.of(context).colorScheme.error,
                ),
              );
            } else {
              return;
            }
          }
        },
        child: Scaffold(
          backgroundColor: (appStateNotifier.isOnline)
              ? Theme.of(context).colorScheme.background
              : Theme.of(context).colorScheme.errorContainer,
          appBar: AppBar(
            backgroundColor: (appStateNotifier.isOnline)
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                OnlineStatusIcon(),
                Text(
                  'Register',
                ),
              ],
            ),
            actions: const [],
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
                            height: 30,
                          ),
                          const Text(
                            'Please register create your notes!',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          (!appStateNotifier.isOnline)
                              ? Text(
                                  'Connect to the Internet to register!',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.error),
                                )
                              : const SizedBox(
                                  height: 25,
                                ),
                          const SizedBox(
                            height: 25,
                          ),
                          TextField(
                            enabled: (appStateNotifier.isOnline) ? true : false,
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
                            enabled: (appStateNotifier.isOnline) ? true : false,
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
                                    context.read<AuthBloc>().add(
                                          AuthEventRegister(
                                            email: email,
                                            password: password,
                                          ),
                                        );
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
                                        color: Theme.of(context).colorScheme.outline,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.read<AuthBloc>().add(
                                              const AuthEventLogOut(),
                                            );
                                      },
                                      child: Text(
                                        "Login here.",
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
          ),
        ),
      );
    });
  }
}
