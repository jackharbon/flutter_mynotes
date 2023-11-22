import 'dart:developer' as devtools show log;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/helpers/loading/loading_widget.dart';
import '../../shared/providers/app_notifier.dart';
import '../../shared/services/crud/notes_services.dart';
import 'login/login_view.dart';

class LocalHomePage extends StatefulWidget {
  const LocalHomePage({super.key});

  @override
  State<LocalHomePage> createState() => _LocalHomePageState();
}

class _LocalHomePageState extends State<LocalHomePage> {
  late final LocalNotesService _notesService;
  DatabaseUser? user;

  @override
  void initState() {
    _notesService = LocalNotesService();
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
              final user = _notesService.getLocalUser(email: appStateNotifier.userEmail);
              // ? ----------------------------------------
              devtools.log(' ==> home_view (local) | FutureBuilder | email verified: $user');
              // TODO: isEmailVerified
              return const LocalLoginView();
                                    default:
              return Scaffold(
                appBar: AppBar(
                  title: const Text(
                    'Please wait..(local).',
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
