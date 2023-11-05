import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/helpers/loading/loading_widget.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_services.dart';
import 'package:mynotes/utilities/menus/popup_menu.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({Key? key}) : super(key: key);

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote? _note;

  late final NotesService _notesService;
  late final TextEditingController _noteTitleController;
  late final TextEditingController _noteTextController;

  @override
  void initState() {
    _notesService = NotesService();
    _noteTitleController = TextEditingController();
    _noteTextController = TextEditingController();
    // ? ---------------------------------------------------------------
    log(' ==> new_note_view | initState()');
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final title = _noteTitleController.text;
    final text = _noteTextController.text;
    // TODO: final createdAt = Timestamp.now();
    // ? ---------------------------------------------------------------
    log(' ==> new_note_view | _textControllerListener() | note: $note, title: $title, text: $text,');
    await _notesService.updateNote(
      note: note,
      title: title,
      text: text,
      // TODO: createdAt: createdAt,
    );
  }

  void _setupTextControllerListener() {
    _noteTitleController.removeListener(_textControllerListener);
    _noteTextController.removeListener(_textControllerListener);
    _noteTitleController.addListener(_textControllerListener);
    _noteTextController.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    // ? ---------------------------------------------------------------
    log(' ==> new_note_view | createNewNote() | existingNote: $existingNote');
    if (existingNote != null) {
      // ? ---------------------------------------------------------------
      log(' ==> new_note_view | createNewNote() | existingNote is not empty: $existingNote');
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    // ? ---------------------------------------------------------------
    log(' ==> new_note_view | createNewNote() | currentUser email: $email owner: $owner');
    return await _notesService.createNote(owner: owner);
  }

  void _deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (note != null) {
      if (_noteTextController.text.isEmpty &&
          _noteTitleController.text.isEmpty) {
        // ? ---------------------------------------------------------------
        log(' ==> new_note_view | _deleteNoteIfTextIsEmpty() | deleted note: $note');
        await _notesService.deleteNote(id: note.id);
      }
    }
  }

  void _safeNoteIfTextNotEmpty() async {
    final note = _note;
    final title = _noteTitleController.text;
    final text = _noteTextController.text;
    // TODO: final createdAt = Timestamp.now();
    // ? ---------------------------------------------------------------
    log(' ==> new_note_view | _safeNoteIfTextNotEmpty() | initial note: $note, title: $title, text: $text');
    if (note != null) {
      if (title.isNotEmpty || text.isNotEmpty) {
        await _notesService.updateNote(
          note: note,
          text: text,
          title: title,
          // TODO: createdAt: createdAt,
        );
        // ? ---------------------------------------------------------------
        log(' ==> new_note_view | _safeNoteIfTextNotEmpty() | saved note: $note, title: $title, text: $text');
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
    log(' ==> new_note_view | dispose()');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(newNoteRoute);
              },
              icon: const Icon(Icons.add)),
          popupMenuItems(context),
        ],
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote?;
              _setupTextControllerListener();
              // ? ---------------------------------------------------------------
              log(' ==> new_note_view | _note: $_note');
              log(' ==> new_note_view | snapshot: ${snapshot.data}');
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
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
    );
  }
}
