import 'dart:developer' as devtools show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/helpers/loading/loading_widget.dart';
import 'package:mynotes/utilities/show_error.dart';
import 'package:mynotes/views/verify_email_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text('Register'),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.amber,
                        radius: 60,
                        child: Image(image: AssetImage('assets/icon/logo.png')),
                      ), //Circle
                      const SizedBox(
                        height: 50,
                      ),
                      const Text(
                        'Please register create your notes!',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      TextField(
                        controller: _email,
                        enableSuggestions: false,
                        autocorrect: false,
                        autofocus: true,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                        ),
                      ),
                      TextField(
                        controller: _password,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                        ),
                      ),
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  textStyle: const TextStyle(fontSize: 20)),
                              onPressed: () async {
                                final email = _email.text;
                                final password = _password.text;
                                try {
                                  await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                    email: email,
                                    password: password,
                                  );
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  user?.sendEmailVerification();
                                  Navigator.of(context)
                                      .pushNamed(verifyEmailRoute);
                                } on FirebaseAuthException catch (e) {
                                  switch (e.code) {
                                    case 'channel-error':
                                      await showErrorDialog(
                                        context,
                                        'Please check the form fields!',
                                      );
                                    case 'invalid-email':
                                      await showErrorDialog(
                                        context,
                                        'Please check your email address',
                                      );
                                    case 'email-already-in-use':
                                      await showErrorDialog(
                                        context,
                                        'Email address is already in Use!',
                                      );
                                    case 'weak-password':
                                      await showErrorDialog(
                                        context,
                                        'Weak password!',
                                      );
                                    default:
                                      await showErrorDialog(
                                        context,
                                        'Error: ${e.code}',
                                      );
                                  }
                                } catch (e) {
                                  devtools.log(
                                      ' |====> register_view | TextButton | Generic Error: ${e.toString()}');
                                  await showErrorDialog(
                                    context,
                                    'Error: ${e.toString()}!',
                                  );
                                }
                              },
                              child: const Text(
                                'Register',
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  loginRoute,
                                  (route) => false,
                                );
                              },
                              child:
                                  const Text('Already registered? Login here.'),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            default:
              // return const Text('Loading..');
              return const LoadingStandardProgressBar();
          }
        },
      ),
    );
  }
}
