import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../shared/constants/routes.dart';
import '../../../shared/extensions/buildcontext/loc.dart';
import '../../../shared/helpers/loading/loading_screen.dart';
import '../../../shared/utilities/actions/online_status_icon.dart';
import '../../../shared/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import '../../services/auth/firebase/auth_service.dart';
import '../../../shared/utilities/generics/get_arguments.dart';
import '../../../shared/utilities/actions/popup_menu.dart';
import '../../services/cloud/cloud_note.dart';
import '../../services/cloud/firebase_cloud_storage.dart';

class CloudCreateUpdateNoteView extends StatefulWidget {
  const CloudCreateUpdateNoteView({super.key});

  @override
  State<CloudCreateUpdateNoteView> createState() => _CloudCreateUpdateNoteViewState();
}

class _CloudCreateUpdateNoteViewState extends State<CloudCreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _noteTitleController;
  late final TextEditingController _noteTextController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _noteTitleController = TextEditingController();
    _noteTextController = TextEditingController();

    // ? ---------------------------------------------------------------
    // debugPrint('|===> create_update_note (cloud) | initState()');
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final title = _noteTitleController.text;
    final text = _noteTextController.text;
    // ? ---------------------------------------------------------------
    // debugPrint('|===> create_update_note (cloud) | _textControllerListener() | note: $note');
    await _notesService.updateCloudNote(
      documentId: note.documentId,
      title: title,
      text: text,
      isSyncedWithCloud: false,
    );
  }

  void _setupTextControllerListener() {
    _noteTitleController.removeListener(_textControllerListener);
    _noteTextController.removeListener(_textControllerListener);
    _noteTitleController.addListener(_textControllerListener);
    _noteTextController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    // Extracting argument T(optional - note exists on tap) = DatabaseNote from the context
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      // pass text from note to the CreateOrUpdateNote
      _noteTitleController.text = widgetNote.title;
      _noteTextController.text = widgetNote.text;
      // ? -----------------------------------------
      // debugPrint(
      // '|===> create_update_note | createOrGetExistingNote() | title: ${_noteTitleController.text}, text: ${_noteTextController.text}');
      return widgetNote;
    }

    final existingNote = _note;
    // ? ---------------------------------------------------------------
    // debugPrint('|===> create_update_note (cloud) | createNewNote() | existingNote: $existingNote');
    if (existingNote != null) {
      // ? ---------------------------------------------------------------
      // debugPrint('|===> create_update_note (cloud) | createNewNote() | existingNote is not empty: $existingNote');
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesService.createNewCloudNote(ownerUserId: userId);
    _note = newNote;
    // ? -----------------------------------------
    // debugPrint('|===> create_update_note (cloud) | createOrGetExistingNote() | userId: $userId');
    return newNote;
  }

  void _deleteOrSaveNewNoteIfEmpty() async {
    final note = _note;
    final title = _noteTitleController.text;
    final text = _noteTextController.text;
    if (note != null) {
      switch (title.isEmpty && text.isEmpty) {
        case true:
          // ? -----------------------------------------
          // debugPrint('|===>create_update_note  (cloud) | _deleteOrSaveNewNoteIfEmpty() | Note deleted');
          await _notesService.deleteCloudNote(documentId: note.documentId);
        default:
          // ? -----------------------------------------
          // debugPrint('|===>create_update_note  (cloud) | _deleteOrSaveNewNoteIfEmpty() | Note saved');
          await _notesService.updateCloudNote(
            documentId: note.documentId,
            title: title,
            text: text,
            isSyncedWithCloud: false,
          );
      }
    }
  }

  // TODO: is this function used?
  void _safeNoteIfTextNotEmpty() async {
    final note = _note;
    final title = _noteTitleController.text;
    final text = _noteTextController.text;
    // ? ---------------------------------------------------------------
    // debugPrint('|===> create_update_note (cloud) | _safeNoteIfTextNotEmpty() | initial note: $note');
    if (note != null) {
      if (title.isNotEmpty || text.isNotEmpty) {
        await _notesService.updateCloudNote(
          documentId: note.documentId,
          title: title,
          text: text,
          isSyncedWithCloud: false,
        );
        // ? ---------------------------------------------------------------
        // debugPrint('|===> create_update_note (cloud) | _safeNoteIfTextNotEmpty() | saved note: $note');
      }
    }
  }

  @override
  void dispose() {
    _deleteOrSaveNewNoteIfEmpty();
    _safeNoteIfTextNotEmpty();
    _noteTitleController.dispose();
    _noteTextController.dispose();
    // ? ---------------------------------------------------------------
    // debugPrint('|===> create_update_note (cloud) | dispose()');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const OnlineStatusIcon(),
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                context.loc.create_note_view_title,
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                // Navigator.of(context).pop();
                Navigator.pop(context);
                Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
              },
              icon: const Icon(Icons.add)),
          IconButton(
            onPressed: () async {
              final title = _noteTitleController.text;
              final text = _noteTextController.text;
              if (_note == null || (text.isEmpty && title.isEmpty)) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                final sharedNote = '$title\n$text';
                Share.share(sharedNote);
              }
            },
            icon: const Icon(Icons.share),
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
              _setupTextControllerListener();
              // ? ---------------------------------------------------------------
              // debugPrint('|===> create_update_note (cloud) | _note: $_note');
              // debugPrint('|===> create_update_note (cloud) | snapshot: ${snapshot.data}');
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
