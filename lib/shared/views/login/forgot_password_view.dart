import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cloud/services/auth/auth_exceptions.dart';
import '../../../cloud/services/auth/bloc/auth_bloc.dart';
import '../../../cloud/services/auth/bloc/auth_event.dart';
import '../../../cloud/services/auth/bloc/auth_state.dart';
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
            if (state.exception is MissingDataAuthException) {
              await showErrorDialog(
                context,
                'Missing credentials!\nPlease check the form fields.',
                'Password Reset',
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
                'Password Reset',
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
                'Password Reset',
                Icon(
                  Icons.person_off_rounded,
                  size: 60,
                  color: Theme.of(context).colorScheme.error,
                ),
              );
            } else {
              await showErrorDialog(
                context,
                'An error has occurred.\nPlease try again.',
                'Password Reset',
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
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              OnlineStatusIcon(),
              Text(
                'Password Reset(cloud)',
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
                  height: 50,
                ),
                const Text(
                  'Enter your email, and we will send you a password reset link',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 50,
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofocus: true,
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
                  onPressed: () {
                    final email = _controller.text;
                    context.read<AuthBloc>().add(AuthEventForgotPassword(email: email));
                  },
                  child: const Text(
                    'Send link',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  },
                  child: const Text(
                    'Back to the login page',
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
