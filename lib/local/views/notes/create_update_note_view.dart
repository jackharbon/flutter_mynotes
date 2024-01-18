import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../cloud/services/auth/auth_service.dart';
import '../../../shared/constants/routes.dart';
import '../../../shared/helpers/loading/loading_screen.dart';
import '../../../shared/utilities/actions/online_status_icon.dart';
import '../../../shared/services/crud/notes_services.dart';
import '../../../shared/utilities/generics/get_arguments.dart';
import '../../../shared/utilities/actions/popup_menu.dart';

class LocalCreateUpdateNoteView extends StatefulWidget {
  const LocalCreateUpdateNoteView({super.key});

  @override
  State<LocalCreateUpdateNoteView> createState() => _LocalCreateUpdateNoteViewState();
}

class _LocalCreateUpdateNoteViewState extends State<LocalCreateUpdateNoteView> {
  LocalDatabaseNote? _note;

  late final LocalNotesService _notesService;
  late final TextEditingController _noteTitleController;
  late final TextEditingController _noteTextController;
  late final Timestamp createdAtNow;

  @override
  void initState() {
    _notesService = LocalNotesService();
    _noteTitleController = TextEditingController();
    _noteTextController = TextEditingController();
    createdAtNow = Timestamp.now();

    // ? ---------------------------------------------------------------
    // debugPrint('|===> create_update_note_view | initState()');
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final title = _noteTitleController.text;
    final text = _noteTextController.text;
    final createdAt = createdAtNow.toDate().toString().substring(0, 16);
    // ? ---------------------------------------------------------------
    // debugPrint(
    // '|===> new_note_view (local) | _textControllerListener() | note: $note, title: $title, text: $text, createdAt: $createdAt');
    await _notesService.updateLocalNote(
      note: note,
      title: title,
      text: text,
      createdAt: createdAt,
    );
  }

  void _setupTextControllerListener() {
    _noteTitleController.removeListener(_textControllerListener);
    _noteTextController.removeListener(_textControllerListener);
    _noteTitleController.addListener(_textControllerListener);
    _noteTextController.addListener(_textControllerListener);
  }

  Future<LocalDatabaseNote> createOrGetExistingNote(BuildContext context) async {
    // Extracting argument T(optional - note exists on tap) = DatabaseNote from the context
    final widgetNote = context.getArgument<LocalDatabaseNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      // pass text from note to the CreateOrUpdateNote
      (widgetNote.title != null) ? _noteTitleController.text = widgetNote.title! : null;
      _noteTextController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    // ? ---------------------------------------------------------------
    // debugPrint('|===> new_note_view (local) | createNewNote() | existingNote: $existingNote');
    if (existingNote != null) {
      // ? ---------------------------------------------------------------
      // debugPrint('|===> new_note_view (local) | createNewNote() | existingNote is not empty: $existingNote');
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email;
    final owner = await _notesService.getLocalUser(email: email);
    // ? ---------------------------------------------------------------
    // debugPrint('|===> new_note_view (local) | createNewNote() | currentUser email: $email owner: $owner');
    final newNote = await _notesService.createLocalNote(owner: owner);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (note != null) {
      if (_noteTextController.text.isEmpty && _noteTitleController.text.isEmpty) {
        // ? ---------------------------------------------------------------
        // debugPrint('|===> new_note_view (local) | _deleteNoteIfTextIsEmpty() | deleted note: $note');
        await _notesService.deleteLocalNote(id: note.id);
      }
    }
  }

  void _safeNoteIfTextNotEmpty() async {
    final note = _note;
    final title = _noteTitleController.text;
    final text = _noteTextController.text;
    final createdAt = Timestamp.now().toDate().toString().substring(0, 16);
    // ? ---------------------------------------------------------------
    // debugPrint(
    // '|===> new_note_view (local) | _safeNoteIfTextNotEmpty() | initial note: $note, title: $title, text: $text, createdAt: $createdAt');
    if (note != null) {
      if (title.isNotEmpty || text.isNotEmpty) {
        await _notesService.updateLocalNote(
          note: note,
          text: text,
          title: title,
          createdAt: createdAt,
        );
        // ? ---------------------------------------------------------------
        // debugPrint(
        // '|===> new_note_view (local) | _safeNoteIfTextNotEmpty() | saved note: $note, title: $title, text: $text, createdAt: $createdAt');
      }
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _safeNoteIfTextNotEmpty();
    _noteTitleController.dispose();
    _noteTextController.dispose();
    // ? ---------------------------------------------------------------
    // debugPrint('|===> new_note_view (local) | dispose()');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            OnlineStatusIcon(),
            Text('New Note(local)'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          popupMenuItems(context),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: createOrGetExistingNote(context),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                _note = snapshot.data as LocalDatabaseNote?;
                _setupTextControllerListener();
                // ? ---------------------------------------------------------------
                // debugPrint('|===> new_note_view (local) | _note: $_note');
                // debugPrint('|===> new_note_view (local) | snapshot: ${snapshot.data}');
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        autofocus: true,
                        controller: _noteTitleController,
                        keyboardType: TextInputType.text,
                        maxLines: null,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'Start typing your title here',
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: SingleChildScrollView(
                            child: TextField(
                              controller: _noteTextController,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: const InputDecoration(
                                labelText: 'Message',
                                hintText: 'Start typing your note here',
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              default:
                return const LoadingStandardProgressBar();
            }
          },
        ),
      ),
    );
  }
}
