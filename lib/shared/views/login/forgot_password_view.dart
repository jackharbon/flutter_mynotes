import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cloud/services/auth/firebase/auth_exceptions.dart';
import '../../../cloud/services/auth/bloc/auth_bloc.dart';
import '../../../cloud/services/auth/bloc/auth_event.dart';
import '../../../cloud/services/auth/bloc/auth_state.dart';
import '../../extensions/buildcontext/loc.dart';
import '../../utilities/actions/online_status_icon.dart';
import '../../utilities/dialogs/error_dialog.dart';
import '../../utilities/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  ForgotPasswordViewState createState() => ForgotPasswordViewState();
}

class ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }
          if (state.exception != null) {
            if (state.exception is CloudMissingDataAuthException) {
              await showErrorDialog(
                context,
                context.loc.dialog_error_missing_credentials,
                context.loc.dialog_error_title_password_reset,
                Icon(
                  Icons.text_fields,
                  size: 60,
                  color: Theme.of(context).colorScheme.error,
                ),
              );
            } else if (state.exception is CloudInvalidEmailAuthException) {
              await showErrorDialog(
                context,
                context.loc.dialog_error_invalid_email,
                context.loc.dialog_error_title_password_reset,
                Icon(
                  Icons.email,
                  size: 60,
                  color: Theme.of(context).colorScheme.error,
                ),
              );
            } else if (state.exception is CloudUserNotFoundAuthException) {
              await showErrorDialog(
                context,
                context.loc.dialog_error_user_not_found,
                context.loc.dialog_error_title_password_reset,
                Icon(
                  Icons.person_off_rounded,
                  size: 60,
                  color: Theme.of(context).colorScheme.error,
                ),
              );
            } else {
              await showErrorDialog(
                context,
                context.loc.dialog_error_occured,
                context.loc.dialog_error_title_password_reset,
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const OnlineStatusIcon(),
              Text(
                context.loc.forgot_password_view_title,
              ),
            ],
          ),
          actions: const [],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 60,
                  child: Icon(
                    Icons.lock_reset_sharp,
                    size: 60.0,
                  ), //Text
                ), //Circle
                const SizedBox(
                  height: 30,
                ),
                Text(
                  context.loc.forgot_password_view_prompt,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofocus: true,
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: context.loc.textField_email_labelText,
                    hintText: context.loc.textField_email_hintText,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.outgoing_mail,
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
                  onPressed: () {
                    final email = _controller.text;
                    context.read<AuthBloc>().add(AuthEventForgotPassword(email: email));
                  },
                  label: Text(
                    context.loc.forgot_password_view_send_link,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  },
                  child: Text(
                    context.loc.forgot_password_view_back_to_login,
                    style: TextStyle(
                      shadows: [Shadow(color: Theme.of(context).colorScheme.primary, offset: const Offset(0, -2))],
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
          ),
        ),
      ),
    );
  }
}
