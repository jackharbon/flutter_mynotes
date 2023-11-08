import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/local/local_routes.dart';
import 'package:mynotes/helpers/loading/loading_widget.dart';
import 'package:mynotes/services/local/auth/local_auth_service.dart';
import 'package:mynotes/services/local/crud/local_notes_services.dart';
import 'package:mynotes/utilities/generics/get_arguments.dart';
import 'package:mynotes/utilities/menus/popup_menu.dart';

class CreateUpdateNoteViewLocal extends StatefulWidget {
  const CreateUpdateNoteViewLocal({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteViewLocal> createState() =>
      _CreateUpdateNoteViewLocalState();
}

class _CreateUpdateNoteViewLocalState extends State<CreateUpdateNoteViewLocal> {
  DatabaseNoteLocal? _note;

  late final NotesServiceLocal _notesService;
  late final TextEditingController _noteTitleController;
  late final TextEditingController _noteTextController;
  late final Timestamp createdAt;

  @override
  void initState() {
    _notesService = NotesServiceLocal();
    _noteTitleController = TextEditingController();
    _noteTextController = TextEditingController();
    createdAt = Timestamp.now();

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
    final createdAt = Timestamp.now().toDate().toString().substring(0, 16);
    // ? ---------------------------------------------------------------
    log(' ==> new_note_view | _textControllerListener() | note: $note, title: $title, text: $text, createdAt: $createdAt');
    await _notesService.updateNoteLocal(
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

  Future<DatabaseNoteLocal> createOrGetExistingNote(
      BuildContext context) async {
    // Extracting argument T(optional - note exists on tap) = DatabaseNote from the context
    final widgetNote = context.getArgument<DatabaseNoteLocal>();

    if (widgetNote != null) {
      _note = widgetNote;
      // pass text from note to the CreateOrUpdateNote
      (widgetNote.title != null)
          ? _noteTitleController.text = widgetNote.title!
          : null;
      _noteTextController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    // ? ---------------------------------------------------------------
    log(' ==> new_note_view | createNewNote() | existingNote: $existingNote');
    if (existingNote != null) {
      // ? ---------------------------------------------------------------
      log(' ==> new_note_view | createNewNote() | existingNote is not empty: $existingNote');
      return existingNote;
    }
    final currentUser = AuthServiceLocal.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUserLocal(email: email);
    // ? ---------------------------------------------------------------
    log(' ==> new_note_view | createNewNote() | currentUser email: $email owner: $owner');
    final newNote = await _notesService.createNoteLocal(owner: owner);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (note != null) {
      if (_noteTextController.text.isEmpty &&
          _noteTitleController.text.isEmpty) {
        // ? ---------------------------------------------------------------
        log(' ==> new_note_view | _deleteNoteIfTextIsEmpty() | deleted note: $note');
        await _notesService.deleteNoteLocal(id: note.id);
      }
    }
  }

  void _safeNoteIfTextNotEmpty() async {
    final note = _note;
    final title = _noteTitleController.text;
    final text = _noteTextController.text;
    final createdAt = Timestamp.now().toDate().toString().substring(0, 16);
    // ? ---------------------------------------------------------------
    log(' ==> new_note_view | _safeNoteIfTextNotEmpty() | initial note: $note, title: $title, text: $text, createdAt: $createdAt');
    if (note != null) {
      if (title.isNotEmpty || text.isNotEmpty) {
        await _notesService.updateNoteLocal(
          note: note,
          text: text,
          title: title,
          createdAt: createdAt,
        );
        // ? ---------------------------------------------------------------
        log(' ==> new_note_view | _safeNoteIfTextNotEmpty() | saved note: $note, title: $title, text: $text, createdAt: $createdAt');
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
                Navigator.of(context).pushNamed(createOrUpdateNoteRouteLocal);
              },
              icon: const Icon(Icons.add)),
          popupMenuItems(context),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNoteLocal?;
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
