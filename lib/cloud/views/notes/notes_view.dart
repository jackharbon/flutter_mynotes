import 'dart:developer' as devtools show log;
import 'package:flutter/material.dart';

import '../../../shared/constants/routes.dart';
import '../../../shared/utilities/actions/online_status_icon.dart';
import '../../services/auth/auth_service.dart';
import '../../../shared/services/crud/notes_services.dart';
import '../../../shared/helpers/loading/loading_widget.dart';
import '../../../shared/utilities/actions/popup_menu.dart';
import 'notes_list.view.dart';

class CloudMyNotesView extends StatefulWidget {
  const CloudMyNotesView({
    Key? key,
  }) : super(key: key);

  @override
  State<CloudMyNotesView> createState() => _CloudMyNotesViewState();
}

class _CloudMyNotesViewState extends State<CloudMyNotesView> {
  late final LocalNotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  void initState() {
    _notesService = LocalNotesService();
    AuthService.firebase().initialize();
    // ? ---------------------------------------------------------------
    devtools.log(' ==> notes_view (cloud) | initState() | _notesService: $_notesService, userEmail: $userEmail');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            OnlineStatusIcon(),
            Text(
              'My Notes(cloud)',
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
        child: FutureBuilder(
          future: _notesService.getOrCreateLocalUser(email: userEmail),
          builder: (context, snapshot) {
            // ? ---------------------------------------------------------------
            devtools.log(
                ' ==> notes_view (cloud) | User snapshot: ${snapshot.connectionState}, ${snapshot.data}, userEmail: $userEmail');
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
                            ' ==> notes_view (cloud) | allNotes snapshot: ${snapshot.connectionState}, ${snapshot.data}');
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
                            final allNotes = snapshot.data as List<LocalDatabaseNote>;
                            return CloudNotesListView(
                              notes: allNotes,
                              onDeleteNote: (note) async {
                                await _notesService.deleteLocalNote(id: note.id);
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
