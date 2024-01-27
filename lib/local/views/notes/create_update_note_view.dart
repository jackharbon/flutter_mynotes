import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../shared/extensions/buildcontext/loc.dart';
import '../../../shared/helpers/loading/loading_screen.dart';
import '../../../shared/utilities/actions/online_status_icon.dart';
import '../../../shared/services/crud/notes_services.dart';
// import '../../../shared/utilities/generics/get_arguments.dart';
import '../../../shared/utilities/actions/popup_menu.dart';
import '../../../shared/utilities/actions/user_settings_drawer.dart';

class LocalCreateUpdateNoteView extends StatefulWidget {
  const LocalCreateUpdateNoteView({super.key});

  @override
  State<LocalCreateUpdateNoteView> createState() => _LocalCreateUpdateNoteViewState();
}

class _LocalCreateUpdateNoteViewState extends State<LocalCreateUpdateNoteView> {
  late final LocalNotesService _notesService;
  late final TextEditingController _noteTitleController;
  late final TextEditingController _noteTextController;
  late final Timestamp createdAtNow;
  final getXArguments = Get.arguments;
  DatabaseUser get user => getXArguments[0]['user'];
  LocalDatabaseNote? get editNote => getXArguments[0]['note'];
  LocalDatabaseNote? _note;

  @override
  void initState() {
    _notesService = LocalNotesService();
    _noteTitleController = TextEditingController();
    _noteTextController = TextEditingController();
    createdAtNow = Timestamp.now();
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
    // '|===> create_update (local) | _textControllerListener() | title: $title, text: $text');
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
    // note passed by getXArguments
    final widgetNote = editNote;

    if (widgetNote != null) {
      _note = widgetNote;
      // pass text from note to the CreateOrUpdateNote
      (widgetNote.title != null) ? _noteTitleController.text = widgetNote.title! : null;
      _noteTextController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    // ? ---------------------------------------------------------------
    // debugPrint('|===> create_update (local) | createNewNote() | existingNote: $existingNote');
    if (existingNote != null) {
      // ? ---------------------------------------------------------------
      // debugPrint('|===> create_update (local) | createNewNote() | existingNote is not empty: $existingNote');
      return existingNote;
    }
    final owner = await _notesService.getLocalUser(email: user.email);
    // ? ---------------------------------------------------------------
    debugPrint('|===> create_update (local) | createNewNote() | currentUser: ${user.email} owner: $owner');
    final newNote = await _notesService.createLocalNote(owner: owner);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (note != null) {
      if (_noteTextController.text.isEmpty && _noteTitleController.text.isEmpty) {
        // ? ---------------------------------------------------------------
        // debugPrint('|===> create_update (local) | _deleteNoteIfTextIsEmpty() | deleted note: $note');
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
    // '|===> create_update (local) | _safeNoteIfTextNotEmpty() | title: $title, text: $text);
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
        // '|===> create_update (local) | _safeNoteIfTextNotEmpty() | saved title: $title, text: $text');
      }
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _safeNoteIfTextNotEmpty();
    _noteTitleController.dispose();
    _noteTextController.dispose();
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
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                'Edit Note(local)',
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              Get.toNamed('/create', arguments: [
                {"user": user}
              ]);
            },
            icon: const Icon(Icons.add),
          ),
          popupMenuItems(context),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const LoadingStandardProgressBar();
            case ConnectionState.done:
              _note = snapshot.data as LocalDatabaseNote?;
              _setupTextControllerListener();
              // ? ---------------------------------------------------------------
              // debugPrint('|===> create_update (local) | _note: $_note');
              // debugPrint('|===> create_update (local) | snapshot: ${snapshot.data}');
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      autofocus: true,
                      controller: _noteTitleController,
                      keyboardType: TextInputType.text,
                      maxLines: null,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        labelText: context.loc.create_note_view_title_textField_labelText,
                        hintText: context.loc.create_note_view_title_textField_hintText,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.surfaceTint,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: TextField(
                          controller: _noteTextController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: context.loc.create_note_view_note_textField_labelText,
                            hintText: context.loc.create_note_view_note_textField_hintText,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
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
