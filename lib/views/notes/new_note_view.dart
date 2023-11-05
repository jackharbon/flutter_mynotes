import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mynotes/helpers/loading/loading_widget.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_services.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({Key? key}) : super(key: key);

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote? _note = DatabaseNote(
    id: 1,
    userId: 1,
    title: '',
    text: '',
    isSyncedWithCloud: false,
  );
  late final NotesService _notesService;
  late final TextEditingController _titleController;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = NotesService();
    _titleController = TextEditingController();
    _textController = TextEditingController();
    // ? ---------------------------------------------------------------
    log(' ==> new_note_view | initState()');
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final title = _titleController.text;
    final text = _textController.text;
    // ? ---------------------------------------------------------------
    log(' ==> new_note_view | _textControllerListener() | note: $note, title: $title, text: $text,');
    await _notesService.updateNote(
      note: note,
      title: title,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
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
    final email = currentUser.email;
    final owner = await _notesService.getUser(email: email!);
    // ? ---------------------------------------------------------------
    log(' ==> new_note_view | createNewNote() | currentUser: $currentUser email: $email $owner: $owner');
    return await _notesService.createNote(owner: owner);
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      // ? ---------------------------------------------------------------
      log(' ==> new_note_view | _deleteNoteIfTextIsEmpty() | note: $note');
      _notesService.deleteNote(id: note.id);
    }
  }

  void _safeNoteIfTextNotEmpty() async {
    final note = _note;
    final title = _titleController.text;
    final text = _textController.text;
    // ? ---------------------------------------------------------------
    log(' ==> new_note_view | _safeNoteIfTextNotEmpty() | note: $note, title: $title, text: $text');
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        note: note,
        text: text,
        title: title,
      );
    } else {
      // ? ---------------------------------------------------------------
      log(' ==> new_note_view | _safeNoteIfTextNotEmpty() | note is not saved');
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _safeNoteIfTextNotEmpty();
    _textController.dispose();
    // ? ---------------------------------------------------------------
    log(' ==> new_note_view | dispose()');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        backgroundColor: Colors.orange,
        actions: const [],
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
                      controller: _titleController,
                      keyboardType: TextInputType.text,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Start typing your title here',
                      ),
                    ),
                    TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        hintText: 'Start typing your note here',
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
