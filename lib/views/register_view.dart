import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/helpers/loading/loading_widget.dart';

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
        backgroundColor: Colors.green,
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
                      SizedBox(
                        height: 160,
                        child: Image.asset('assets/icon/icon.png'),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      const Text(
                          'Please register in order to interact with and create notes!'),
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
                                      .createUserWithEmailAndPassword(
                                    email: email,
                                    password: password,
                                  );
                                  // ? -----------------------------------------------------
                                  debugPrint(
                                      ' |====> register_view | TextButton | userCredentials: $userCredentials');
                                } on FirebaseAuthException catch (e) {
                                  switch (e.code) {
                                    case 'weak-password':
                                      debugPrint(
                                          ' |====> register_view | TextButton | Weak Password!');
                                    case 'email-already-in-use':
                                      debugPrint(
                                          ' |====> register_view | TextButton | Email Already In Use!');
                                    case 'invalid-email':
                                      debugPrint(
                                          ' |====> register_view | TextButton | Invalid Email!');
                                    case 'channel-error':
                                      debugPrint(
                                          ' |====> register_view | TextButton | Chanel Error: Missing Input!');
                                    default:
                                      debugPrint(
                                          ' |====> register_view | TextButton | Default Error: $e');
                                  }
                                } catch (e) {
                                  debugPrint(
                                      ' |====> register_view | TextButton | General Error: $e');
                                }
                              },
                              child: const Text(
                                'Register',
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
