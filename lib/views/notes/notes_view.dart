import 'dart:developer' as devtools show log;
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
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
    devtools
        .log(' ==> notes_view | initState() | _notesService: $_notesService');
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
              case ConnectionState.done:
                return StreamBuilder(
                  stream: _notesService.allNotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        // ? ---------------------------------------widget------------------------
                        devtools.log(
                            ' ==> my_notes_view | Notes snapshot1: ${snapshot.connectionState}, ${snapshot.data}');
                        return const Text('waiting');
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final allNotes = snapshot.data as List<DatabaseNote>;
                          // ? ---------------------------------------------------------------
                          devtools
                              .log(' ==> my_notes_view | allNotes: $allNotes');
                          devtools.log(
                              ' ==> my_notes_view | Notes snapshot2 ${snapshot.connectionState}, ${snapshot.data}');
                          return ListView.builder(
                              itemCount: allNotes.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: ListTile(
                                    title: Text(
                                      allNotes[index].title ?? '...',
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    trailing: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            final id = allNotes[index].id;
                                            _notesService.deleteNote(id: id);
                                          });
                                        }),
                                    onTap: () {
                                      setState(() {});
                                    },
                                    subtitle: Text(
                                      allNotes[index].text,
                                      maxLines: 10,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              });
                        } else {
                          return const LoadingStandardProgressBar();
                        }
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
