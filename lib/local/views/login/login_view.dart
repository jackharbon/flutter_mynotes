import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../cloud/services/auth/bloc/auth_bloc.dart';
import '../../../cloud/services/auth/bloc/auth_event.dart';
import '../../../shared/extensions/buildcontext/loc.dart';
import '../../../shared/helpers/loading/loading_screen.dart';
import '../../../shared/services/crud/notes_services.dart';
import '../../../shared/providers/app_notifier.dart';
import '../../../shared/utilities/actions/online_status_icon.dart';
import '../../../shared/services/crud/crud_exceptions.dart';
import '../../../shared/utilities/dialogs/error_dialog.dart';

class LocalLoginView extends StatefulWidget {
  const LocalLoginView({super.key});

  @override
  State<LocalLoginView> createState() => _LocalLoginViewState();
}

class _LocalLoginViewState extends State<LocalLoginView> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            OnlineStatusIcon(),
            Text(
              'Login(local)',
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
                        height: 30,
                      ),
                      Text(
                        context.loc.login_view_prompt,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
                        decoration: InputDecoration(
                          labelText: context.loc.textField_email_labelText,
                          hintText: context.loc.textField_email_hintText,
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
                        decoration: InputDecoration(
                          labelText: context.loc.textField_password_labelText,
                          hintText: context.loc.textField_password_hintText,
                        ),
                      ),
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            ElevatedButton.icon(
                              icon: Icon(
                                Icons.person,
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                size: 28.0,
                              ),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                                textStyle: const TextStyle(
                                  fontSize: 22,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w400,
                                ),
                                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                              ),
                              onPressed: () async {
                                final email = _email.text;
                                final password = _password.text;
                                try {
                                  localCurrentUser =
                                      await _notesService.logInLocalUser(email: email, password: password);
                                  // ? --------------------------------
                                  // debugPrint('|===> login_view (local) | login button | localUser: $localCurrentUser');
                                  if (localCurrentUser != null) {
                                    Provider.of<AppNotifier>(context, listen: false).storeUserEmail(email);
                                    if (localCurrentUser!.isEmailVerified) {
                                      // debugPrint(
                                      // '|===> login_view (cloud) | myNotesRoute | localUser.isEmailVerified: ${localCurrentUser!.isEmailVerified}');
                                      context.read<AuthBloc>().add(
                                            const AuthEventLogOut(),
                                          );
                                    } else {
                                      // ? --------------------------------
                                      // debugPrint(
                                      // '|===> login_view (local) | verifyEmailRoute | user!.isEmailVerified: ${localCurrentUser!.isEmailVerified}');
                                      context.read<AuthBloc>().add(
                                            const AuthEventSendEmailVerification(),
                                          );
                                    }
                                  } else {
                                    context.read<AuthBloc>().add(
                                          const AuthEventShouldRegister(),
                                        );
                                  }
                                } on MissingDataAuthException {
                                  await showErrorDialog(
                                    context,
                                    context.loc.dialog_error_missing_credentials,
                                    context.loc.dialog_error_title_login_failed,
                                    Icon(
                                      Icons.text_fields,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                } on InvalidEmailAuthException {
                                  await showErrorDialog(
                                    context,
                                    context.loc.dialog_error_invalid_email,
                                    context.loc.dialog_error_title_login_failed,
                                    Icon(
                                      Icons.email,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                } on CouldNotFindUserException {
                                  await showErrorDialog(
                                    context,
                                    context.loc.dialog_error_user_not_found,
                                    context.loc.dialog_error_title_login_failed,
                                    Icon(
                                      Icons.person_off_rounded,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                } on WrongPasswordAuthException {
                                  await showErrorDialog(
                                    context,
                                    context.loc.dialog_error_wrong_password,
                                    context.loc.dialog_error_title_login_failed,
                                    Icon(
                                      Icons.password,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                } on UnknownAuthException {
                                  await showErrorDialog(
                                    context,
                                    context.loc.dialog_error_login_generic,
                                    context.loc.dialog_error_title_login_failed,
                                    Icon(
                                      Icons.person_off_rounded,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                } catch (e) {
                                  await showErrorDialog(
                                    context,
                                    context.loc.dialog_error_login_generic,
                                    context.loc.dialog_error_title_login_failed,
                                    Icon(
                                      Icons.person_off_rounded,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                }
                              },
                              label: Text(
                                context.loc.login_view_login_button,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  context.loc.login_view_not_registered_yet,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.outline,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    context.read<AuthBloc>().add(
                                          const AuthEventShouldRegister(),
                                        );
                                  },
                                  child: Text(
                                    context.loc.login_view_register_here,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  context.loc.login_view_forgot_password,
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
                                    context.loc.login_view_reset_here,
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
