import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';

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
        backgroundColor: Colors.amber,
        title: const Text('Verify email'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                backgroundColor: Colors.amber,
                radius: 60,
                child: Image(image: AssetImage('assets/icon/logo.png')), //Text
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
                    backgroundColor: Colors.amber,
                    textStyle: const TextStyle(fontSize: 20)),
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  user?.sendEmailVerification();
                },
                child: const Text(
                  "Send again",
                ),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
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
