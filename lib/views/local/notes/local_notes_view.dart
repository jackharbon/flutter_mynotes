import 'dart:developer' as devtools show log;
import 'package:flutter/material.dart';
import 'package:mynotes/constants/local/local_routes.dart';
import 'package:mynotes/helpers/loading/loading_widget.dart';
import 'package:mynotes/services/local/auth/local_auth_service.dart';
import 'package:mynotes/services/local/crud/local_notes_services.dart';
import 'package:mynotes/utilities/menus/popup_menu.dart';
import 'package:mynotes/views/local/notes/local_notes_list.view.dart';

class MyNotesViewLocal extends StatefulWidget {
  const MyNotesViewLocal({
    Key? key,
  }) : super(key: key);

  @override
  State<MyNotesViewLocal> createState() => _MyNotesViewLocalState();
}

class _MyNotesViewLocalState extends State<MyNotesViewLocal> {
  late final NotesServiceLocal _notesService;
  String get userEmail => AuthServiceLocal.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesServiceLocal();
    // ? ---------------------------------------------------------------
    devtools
        .log(' ==> notes_view | initState() | _notesService: $_notesService');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Notes | $userEmail',
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createOrUpdateNoteRouteLocal);
              },
              icon: const Icon(Icons.add)),
          popupMenuItems(context),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: _notesService.getOrCreateUserLocal(email: userEmail),
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
                                      Navigator.of(context).pushNamed(
                                          createOrUpdateNoteRouteLocal);
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
                                snapshot.data as List<DatabaseNoteLocal>;
                            return NotesListViewLocal(
                              notes: allNotes,
                              onDeleteNote: (note) async {
                                await _notesService.deleteNoteLocal(
                                    id: note.id);
                              },
                              onTap: (note) {
                                Navigator.of(context).pushNamed(
                                  createOrUpdateNoteRouteLocal,
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
