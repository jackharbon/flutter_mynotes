import 'dart:developer' as devtools show log;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/helpers/loading/loading_widget.dart';
import '../../shared/providers/app_notifier.dart';
import '../../shared/services/crud/notes_services.dart';
import '../../shared/views/login/register_view.dart';
import '../../shared/views/login/verify_email_view.dart';
import 'login/login_view.dart';

class LocalHomePage extends StatefulWidget {
  const LocalHomePage({super.key});

  @override
  State<LocalHomePage> createState() => _LocalHomePageState();
}

class _LocalHomePageState extends State<LocalHomePage> {
  late final NotesService _notesService;
  DatabaseUser? user;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(builder: (context, appStateNotifier, child) {
      return FutureBuilder(
        future: _notesService.open(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = _notesService.getUser(email: appStateNotifier.userEmail);
              // ? ----------------------------------------
              devtools.log(' ==> home_view (local) | FutureBuilder | email verified: $user');
              if (user != null) {
                if (user != null) {
                  return const LocalLoginView();
                } else {
                  devtools.log(' ==> home_vew (local) | FutureBuilder | email not verified: ${user.toString()}');
                  return const CloudVerifyEmailView();
                }
              } else {
                devtools.log(' ==> home_view (local)  | FutureBuilder | user is null: ${user.toString()}');
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
    });
  }
}
