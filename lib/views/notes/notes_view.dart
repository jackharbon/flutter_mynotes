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
                        devtools.log(' ==> my_notes_view | waiting');
                        return const Text('waiting');
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final allNotes = snapshot.data as List<DatabaseNote>;
                          // ? ---------------------------------------------------------------
                          devtools
                              .log(' ==> my_notes_view | allNotes: $allNotes');
                          devtools.log(
                              ' ==> my_notes_view | Notes snapshot: $snapshot');
                          return ListView.builder(
                              itemCount: allNotes.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    allNotes[index].text,
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {}),
                                  onTap: () {},
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
