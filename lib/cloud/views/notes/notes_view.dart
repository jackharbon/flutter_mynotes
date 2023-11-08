import 'dart:developer' as devtools show log;
import 'package:flutter/material.dart';

import '../../constants/routes.dart';
import '../../services/auth/auth_service.dart';
import '../../services/crud/notes_services.dart';
import '../../../shared/helpers/loading/loading_widget.dart';
import '../../../shared/utilities/menus/popup_menu.dart';
import 'notes_list.view.dart';

class MyNotesView extends StatefulWidget {
  const MyNotesView({
    Key? key,
  }) : super(key: key);

  @override
  State<MyNotesView> createState() => _MyNotesViewState();
}

class _MyNotesViewState extends State<MyNotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    // ? ---------------------------------------------------------------
    devtools
        .log(' ==> notes_view | initState() | _notesService: $_notesService');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Notes (Cloud)',
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
              },
              icon: const Icon(Icons.add)),
          popupMenuItems(context),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: _notesService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            // ? ---------------------------------------------------------------
            devtools.log(
                ' ==> notes_view | User snapshot: ${snapshot.connectionState}, ${snapshot.data}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.done:
                return StreamBuilder(
                  stream: _notesService.allNotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
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
                                      Navigator.of(context)
                                          .pushNamed(createOrUpdateNoteRoute);
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      size: 40,
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                            final allNotes =
                                snapshot.data as List<DatabaseNote>;
                            return NotesListView(
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
        ),
      ),
    );
  }
}
