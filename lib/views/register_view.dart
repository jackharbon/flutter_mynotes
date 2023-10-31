import 'dart:developer' as devtools show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/helpers/loading/loading_widget.dart';
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
                                  final userCredentials = await FirebaseAuth
                                      .instance
                                      .createUserWithEmailAndPassword(
                                    email: email,
                                    password: password,
                                  );
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  user?.sendEmailVerification();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const VerifyEmailView()));
                                  // ? -----------------------------------------------------
                                  devtools.log(
                                      ' |====> register_view | TextButton | userCredentials: $userCredentials');
                                } on FirebaseAuthException catch (e) {
                                  switch (e.code) {
                                    case 'weak-password':
                                      devtools.log(
                                          ' |====> register_view | TextButton | Weak Password!');
                                    case 'email-already-in-use':
                                      devtools.log(
                                          ' |====> register_view | TextButton | Email Already In Use!');
                                    case 'invalid-email':
                                      devtools.log(
                                          ' |====> register_view | TextButton | Invalid Email!');
                                    case 'channel-error':
                                      devtools.log(
                                          ' |====> register_view | TextButton | Chanel Error: Missing Input!');
                                    default:
                                      devtools.log(
                                          ' |====> register_view | TextButton | Default Error: $e');
                                  }
                                } catch (e) {
                                  devtools.log(
                                      ' |====> register_view | TextButton | General Error: $e');
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
