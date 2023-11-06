import 'dart:developer' as devtools show log;
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/helpers/loading/loading_widget.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_services.dart';
import 'package:mynotes/utilities/menus/popup_menu.dart';
import 'package:mynotes/views/notes/notes_list.view.dart';

class NotesView extends StatefulWidget {
  const NotesView({
    Key? key,
  }) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    // _notesService.open();
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
                Navigator.of(context).pushNamed(newNoteRoute);
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
                                          .pushNamed(newNoteRoute);
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
                                  newNoteRoute,
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
