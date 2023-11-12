import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20)),
                  onPressed: () async {
                    await AuthService.firebase().sendEmailVerification();
                    await showSentEmailConfirmationDialog(
                      context,
                      'Email has been sent again\nPlease check your mailbox.',
                      'Verification email',
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
                          decorationColor:
                              Theme.of(context).colorScheme.primary,
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
