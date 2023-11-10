import 'dart:developer' as devtools show log;
import 'package:flutter/material.dart';

import '../../shared/helpers/loading/loading_widget.dart';
import '../services/auth/auth_service.dart';
import '../views/login/login_view.dart';
import '../../shared/views/login/register_view.dart';
import '../../shared/views/login/verify_email_view.dart';

class CloudHomePage extends StatelessWidget {
  const CloudHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                // ? ----------------------------------------
                devtools.log(
                    ' ==> main | FutureBuilder | email verified: ${user.email.toString()}');
                return const CloudLoginView();
              } else {
                devtools.log(
                    ' ==> main | FutureBuilder | email not verified: ${user.email.toString()}');
                return const CloudVerifyEmailView();
              }
            } else {
              devtools.log(
                  ' ==> main | FutureBuilder | user is null: ${user.toString()}');
              return const CloudRegisterView();
            }
          default:
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Please wait...',
                ),
              ),
              body: const LoadingStandardProgressBar(),
            );
        }
      },
    );
  }
}
