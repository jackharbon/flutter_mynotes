import 'package:flutter/material.dart';

import '../../../shared/utilities/dialogs/resend_verification.dart';
import '../../../shared/utilities/menus/popup_menu.dart';
import '../../constants/routes.dart';
import '../../services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  VerifyEmailViewState createState() => VerifyEmailViewState();
}

class VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verify Email (Local)',
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
                style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20)),
                onPressed: () async {
                  await AuthService.firebase().sendEmailVerification();
                  await showSentEmailConfirmationDialog(
                    context,
                    'Email has been sent again\nPlease check your mailbox.',
                    'Email Verification',
                    Icon(
                      Icons.mark_email_unread,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
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
                      await AuthService.firebase().logOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (route) => false,
                      );
                    },
                    child: Text(
                      "Go to the login page.",
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
              )
            ],
          ),
        ),
      ),
    );
  }
}