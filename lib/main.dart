import 'dart:developer' as devtools show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/helpers/loading/loading_widget.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.grey[800],
        primarySwatch: Colors.blue,
        hoverColor: Colors.lightBlueAccent,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black87),
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
      title: 'My Notes',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      routes: {
        homePageRoute: (context) => const RegisterView(),
        registerRoute: (context) => const RegisterView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        loginRoute: (context) => const LoginView(),
        myNotesRoute: (context) => const NotesView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (user.emailVerified) {
                // ? ----------------------------------------
                devtools.log(
                    'main | FutureBuilder | email verified: ${user.toString()}');
                return const LoginView();
              } else {
                devtools.log(
                    'main | FutureBuilder | email not verified: ${user.toString()}');
                return const VerifyEmailView();
              }
            } else {
              devtools.log(
                  'main | FutureBuilder | user is null: ${user.toString()}');
              return const RegisterView();
            }
          default:
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.blue,
                title: const Text('Please wait...'),
              ),
              backgroundColor: Colors.blue[100],
              body: const Center(
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: LoadingStandardProgressBar(),
                ),
              ),
            );
        }
      },
    );
  }
}
