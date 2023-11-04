import 'dart:developer' as devtools show log;
import 'package:flutter/material.dart';
import 'package:mynotes/helpers/loading/loading_widget.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_services.dart';
import 'package:mynotes/utilities/menus/popup_menu.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    _notesService.open();
    // ? ---------------------------------------------------------------
    devtools.log(' ==> notes_view | initState()');
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    // ? ---------------------------------------------------------------
    devtools.log(' ==> notes_view | dispose()');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Notes',
        ),
        actions: [
          popupMenuItems(context),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: _notesService.getOrCreateUser(email: userEmail),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // ? ---------------------------------------------------------------
            devtools.log(' ==> notes_view | User snapshot: $snapshot');
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                  stream: _notesService.allNotes,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<DatabaseNote>> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        // ? ---------------------------------------------------------------
                        devtools.log(' ==> notes_view | waiting');
                        return const Text('waiting');
                      case ConnectionState.active:
                        // ? ---------------------------------------------------------------
                        devtools.log(' ==> notes_view | active');
                        return const Text('active');
                      case ConnectionState.done:
                        // ? ---------------------------------------------------------------
                        devtools.log(' ==> notes_view | done');
                        return const Text('done');
                      default:
                        return const LoadingStandardProgressBar();
                    }
                  },
                );
              default:
                return const LoadingStandardProgressBar();
            } // switch (snapshot.connectionState)
          }, // Builder Snapshot
        ),
      ),
    );
  }
}
