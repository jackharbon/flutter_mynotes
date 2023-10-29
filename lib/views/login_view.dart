import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/helpers/loading/loading_widget.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        backgroundColor: Colors.blue,
        title: const Text('Login'),
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
                      SizedBox(
                        height: 160,
                        child: Image.asset('assets/icon/icon.png'),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      const Text('Login to your account to see your notes.'),
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
                            TextButton(
                              onPressed: () async {
                                final email = _email.text;
                                final password = _password.text;
                                try {
                                  final userCredentials = await FirebaseAuth
                                      .instance
                                      .signInWithEmailAndPassword(
                                    email: email,
                                    password: password,
                                  );
                                  // ? -----------------------------------------------------
                                  debugPrint(
                                      ' |====> login_view | TextButton | userCredentials: $userCredentials');
                                } on FirebaseAuthException catch (e) {
                                  switch (e.code) {
                                    case 'user-not-found':
                                      debugPrint(
                                          ' |====> login_view | TextButton | User Not Found!');
                                    case 'wrong-password':
                                      debugPrint(
                                          ' |====> login_view | TextButton | Wrong Password!');
                                    case 'invalid-email':
                                      debugPrint(
                                          ' |====> register_view | TextButton | Invalid Email!');
                                    case 'channel-error':
                                      debugPrint(
                                          ' |====> login_view | TextButton | Chanel Error: Missing Input!');
                                    default:
                                      debugPrint(
                                          ' |====> login_view | TextButton | Default Error: $e');
                                  }
                                } catch (e) {
                                  debugPrint(
                                      ' |====> login_view | TextButton | General Error: $e');
                                }
                              },
                              child: const Text(
                                'Login',
                              ),
                            ),
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
