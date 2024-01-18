import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../cloud/services/auth/bloc/auth_bloc.dart';
import '../../../cloud/services/auth/bloc/auth_event.dart';
import '../../services/crud/notes_services.dart';
import '../../providers/app_notifier.dart';
import '../../utilities/actions/online_status_icon.dart';
import '../../utilities/dialogs/resend_verification.dart';
import '../../../cloud/services/auth/auth_service.dart';
import '../../utilities/actions/popup_menu.dart';

class CloudVerifyEmailView extends StatefulWidget {
  const CloudVerifyEmailView({super.key});

  @override
  CloudVerifyEmailViewState createState() => CloudVerifyEmailViewState();
}

class CloudVerifyEmailViewState extends State<CloudVerifyEmailView> {
  late final LocalNotesService _notesService;
  bool isTimeToSendAgain = false;

  @override
  void initState() {
    _notesService = LocalNotesService();
    Future.delayed(const Duration(seconds: 20));
    setState(() => isTimeToSendAgain = true);
    // ? --------------------------------
    // debugPrint('|===> verify_email_view | initState() | isTimeToSendAgain: $isTimeToSendAgain ');
    super.initState();
  }

  Future sendVerificationEmailAgain() async {
    try {
      context.read<AuthBloc>().add(
            const AuthEventSendEmailVerification(),
          );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("I'm sending a verification email")));
      setState(() => isTimeToSendAgain = false);
      // ? --------------------------------
      // debugPrint('|===> verify_email_view | sendVerificationEmailAgain() | isTimeToSendAgain: $isTimeToSendAgain ');
      await Future.delayed(const Duration(seconds: 30));
      setState(() => isTimeToSendAgain = true);
      // ? --------------------------------
      // debugPrint('|===> verify_email_view | sendVerificationEmailAgain() | isTimeToSendAgain: $isTimeToSendAgain ');
    } catch (e) {
      // ? --------------------------------
      // debugPrint('|===> verify_email_view | sendVerificationEmailAgain() | isTimeToSendAgain: $isTimeToSendAgain ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(builder: (context, appStateNotifier, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              OnlineStatusIcon(),
              Text(
                'Verify Email',
              ),
            ],
          ),
          actions: [
            popupMenuItems(context),
          ],
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
                    Icons.mark_email_read,
                    size: 60.0,
                  ), //Text
                ), //Circle
                const SizedBox(
                  height: 30,
                ),
                (!appStateNotifier.isOnline)
                    ? Text(
                        'Connect to the Internet to verify an email!',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.error),
                      )
                    : const SizedBox(
                        height: 25,
                      ),
                const SizedBox(
                  height: 25,
                ),
                const Text(
                    "We've sent you an email verification.\nPlease open it and follow the link to verify your account.\n\nIf you haven't received the email yet, press the button below!"),
                const SizedBox(
                  height: 25,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
                  onPressed: () async {
                    if (appStateNotifier.isOnline) {
                      (isTimeToSendAgain)
                          ? sendVerificationEmailAgain()
                          : await showSentEmailConfirmationDialog(
                              context,
                              "Email has been already send.\nPlease wait a few minutes before next request.",
                              'Verification Email',
                              Icon(
                                Icons.hourglass_top,
                                size: 60,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            );
                    } else {
                      await showSentEmailConfirmationDialog(
                        context,
                        "Please switch on your internet connection to send the email.",
                        'No Internet Connection',
                        Icon(
                          Icons.cloud_off_outlined,
                          size: 60,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  },
                  child: const Text("Send again", style: TextStyle()),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already clicked?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final user = AuthService.firebase().currentUser;
                        if (user != null) {
                          bool isUserEmailVerified = user.isEmailVerified;
                          (isUserEmailVerified)
                              ? await _notesService.updateLocalUserIsEmailVerified(email: user.email)
                              : null;
                          context.read<AuthBloc>().add(
                                const AuthEventLogOut(),
                              );
                        } else {
                          context.read<AuthBloc>().add(
                                const AuthEventShouldRegister(),
                              );
                        }
                      },
                      child: Text(
                        "Login here.",
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
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
