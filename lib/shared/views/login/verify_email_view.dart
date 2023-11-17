import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/crud/notes_services.dart';
import '../../providers/app_notifier.dart';
import '../../utilities/dialogs/resend_verification.dart';
import '../../constants/routes.dart';
import '../../../cloud/services/auth/auth_service.dart';
import '../../utilities/actions/popup_menu.dart';

class CloudVerifyEmailView extends StatefulWidget {
  const CloudVerifyEmailView({Key? key}) : super(key: key);

  @override
  CloudVerifyEmailViewState createState() => CloudVerifyEmailViewState();
}

class CloudVerifyEmailViewState extends State<CloudVerifyEmailView> {
  late final NotesService _notesService;
  bool isTimeToSendAgain = false;

  @override
  void initState() {
    _notesService = NotesService();
    Future.delayed(const Duration(seconds: 20));
    setState(() => isTimeToSendAgain = true);
    // ? --------------------------------
    devtools.log(' ==> verify_email_view | initState() | isTimeToSendAgain: $isTimeToSendAgain ');
    super.initState();
  }

  Future sendVerificationEmailAgain() async {
    try {
      await AuthService.firebase().sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("I'm sending a verification email")));
      setState(() => isTimeToSendAgain = false);
      // ? --------------------------------
      devtools.log(' ==> verify_email_view | sendVerificationEmailAgain() | isTimeToSendAgain: $isTimeToSendAgain ');
      await Future.delayed(const Duration(seconds: 30));
      setState(() => isTimeToSendAgain = true);
      // ? --------------------------------
      devtools.log(' ==> verify_email_view | sendVerificationEmailAgain() | isTimeToSendAgain: $isTimeToSendAgain ');
    } catch (e) {
      // ? --------------------------------
      devtools.log(' ==> verify_email_view | sendVerificationEmailAgain() | isTimeToSendAgain: $isTimeToSendAgain ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(builder: (context, appStateNotifier, child) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: (appStateNotifier.isOnline)
                    ? const Icon(Icons.cloud_done_outlined)
                    : const Icon(Icons.cloud_outlined),
                color: (appStateNotifier.isOnline)
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onError,
                onPressed: () {},
              ),
              const Text(
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
                  height: 50,
                ),
                const Text(
                  'Last step: verify your adres email.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 50,
                ),
                const Text(
                    "We've sent you an email verification.\nPlease open it and follow the link to verify your account.\n\nIf you haven't received the email yet, press the button below!"),
                const SizedBox(
                  height: 20,
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
                        bool isUserEmailVerified = user!.isEmailVerified;
                        (isUserEmailVerified) ? await _notesService.updateIsEmailVerified(email: user.email!) : null;
                        // ? --------------------------------
                        await AuthService.firebase().logOut();
                        devtools.log(
                            ' ==> verify_email_view | login button | email: ${user.email}, user.isEmailVerified: ${user.isEmailVerified}');
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute,
                          (route) => false,
                        );
                      },
                      child: Text(
                        "Go to the login page.",
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