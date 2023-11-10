import 'package:flutter/material.dart';
import '../../services/crud/notes_services.dart';
import '../../../shared/utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(DatabaseNote note);

class LocalNotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const LocalNotesListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Card(
            child: ListTile(
              onTap: () {
                // ? Call back to the notes_view onTap function
                onTap(note);
              },
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      (note.title != '') ? note.title! : "...",
                      maxLines: 1,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Text(
                    note.createdAt,
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () async {
                    final shouldDelete = await showDeleteDialog(context);
                    if (shouldDelete) {
                      onDeleteNote(note);
                    }
                  }),
              subtitle: Text(
                note.text,
                maxLines: 5,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        });
  }
}
