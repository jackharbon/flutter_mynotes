import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/menus/popup_menu.dart';

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
          'Verify email',
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
                  );
                },
                child: const Text("Send again", style: TextStyle()),
              ),
              TextButton(
                onPressed: () async {
                  await AuthService.firebase().logOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );
                },
                child: const Text("Already clicked? Go to the login page"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showSentEmailConfirmationDialog(
  BuildContext context,
  String error,
  String title,
) {
  return showDialog(
    barrierColor: const Color.fromARGB(200, 0, 0, 0),
    context: context,
    builder: (context) {
      return AlertDialog(
          title: Text(
            title,
          ),
          content: Text(
            error,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          icon: const Icon(
            Icons.mark_email_unread,
            size: 60,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ]);
    },
  );
}
