import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                radius: 90,
                child: Icon(
                  Icons.article,
                  color: Colors.white,
                  size: 100.0,
                ), //Text
              ), //Circle
              const SizedBox(
                height: 50,
              ),
              const Text('Login to your account to see your notes'),
              const SizedBox(
                height: 50,
              ),
              const Text(
                  "We've sent you an email verification.\nPlease open it and follow the link to verify your account.\n\nIf you haven't received the email yet, press the button below!"),
              TextButton(
                onPressed: () async {
                  final user = await FirebaseAuth.instance.currentUser;
                  user?.sendEmailVerification();
                },
                child: const Text(
                  "Send verification email again",
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login/',
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
