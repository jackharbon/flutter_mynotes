import 'dart:developer' as devtools show log;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../local/views/notes/notes_list.view.dart';
import '../../../shared/constants/routes.dart';
import '../../../shared/providers/app_notifier.dart';
import '../../../shared/utilities/actions/toggle_database_source.dart';
import '../../../shared/helpers/loading/loading_widget.dart';
import '../../../shared/utilities/actions/popup_menu.dart';
import '../../../shared/services/crud/notes_services.dart';

class LocalMyNotesView extends StatefulWidget {
  const LocalMyNotesView({
    Key? key,
  }) : super(key: key);

  @override
  State<LocalMyNotesView> createState() => _LocalMyNotesViewState();
}

class _LocalMyNotesViewState extends State<LocalMyNotesView> {
  late final NotesService _notesService;
  // String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    // ? ---------------------------------------------------------------
    devtools.log(' ==> notes_view (local) | initState() | _notesService: $_notesService');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ToggleDatabaseSource(),
            Text(
              'My Notes',
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          popupMenuItems(context),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Builder(builder: (context) {
          return Consumer<AppNotifier>(builder: (context, appStateNotifier, child) {
            return FutureBuilder(
              future: _notesService.getOrCreateUser(email: appStateNotifier.userEmail),
              builder: (context, snapshot) {
                // ? ---------------------------------------------------------------
                devtools.log(
                    ' ==> notes_view (local) | email: ${appStateNotifier.userEmail}, User snapshot: ${snapshot.connectionState}, ${snapshot.data}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.done:
                    return StreamBuilder(
                      stream: _notesService.allNotes,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.active:
                            // ? ---------------------------------------------------------------
                            devtools.log(
                                ' ==> notes_view (local) | allNotes snapshot: ${snapshot.connectionState}, ${snapshot.data}');
                            if (snapshot.hasData) {
                              if (snapshot.data!.isEmpty) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Press',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w200,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
                                        },
                                        icon: Icon(
                                          Icons.add,
                                          size: 40,
                                          color: Theme.of(context).colorScheme.primary,
                                        )),
                                    const Text(
                                      'to write your first note.',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w200,
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                //  snapshot.data is NOT Empty
                                final allNotes = snapshot.data as List<DatabaseNote>;
                                return LocalNotesListView(
                                  notes: allNotes,
                                  onDeleteNote: (note) async {
                                    await _notesService.deleteNote(id: note.id);
                                  },
                                  onTap: (note) {
                                    Navigator.of(context).pushNamed(
                                      createOrUpdateNoteRoute,
                                      arguments: note,
                                    );
                                  },
                                );
                              }
                            } else {
                              // snapshot has NOT data
                              return const LoadingStandardProgressBar();
                            }
                          default:
                            // switch connection.status DONE
                            return const LoadingStandardProgressBar();
                        }
                      },
                    );
                  default:
                    return const LoadingStandardProgressBar();
                } // switch (snapshot.connectionState)
              }, // Builder Snapshot
            );
          });
        }),
      ),
    );
  }
}
