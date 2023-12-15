import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/app_notifier.dart';
import '../../../shared/services/crud/notes_services.dart';

typedef NoteCallback = void Function(LocalDatabaseNote note);

class LocalNotesListView extends StatefulWidget {
  final List<LocalDatabaseNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const LocalNotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  State<LocalNotesListView> createState() => _LocalNotesListViewState();
}

class _LocalNotesListViewState extends State<LocalNotesListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(builder: (context, appStateNotifier, child) {
      return ListView.builder(
          itemCount: widget.notes.length,
          itemBuilder: (context, index) {
            final note = widget.notes[index];
            final positionNumber = index + 1;
            // -------------- deleting by swiping left --------------
            return Dismissible(
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  color: Theme.of(context).colorScheme.error,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 28.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Delete this note',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onError,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ],
                    ),
                  ),
                ),
                key: UniqueKey(),
                onDismissed: (DismissDirection endToStart) {
                  setState(() {
                    widget.onDeleteNote(note);
                  });
                },
                child: Column(
                  children: [
                    Card(
                      child: ListTile(
                        onTap: () {
                          // Call back to the notes_view onTap function
                          widget.onTap(note);
                        },
                        // -------------- list tiles: TITLE --------------
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
                            Visibility(
                              visible: appStateNotifier.isDateVisible,
                              child: Text(
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
                            ),
                          ],
                        ),
                        // -------------- list tiles: SUBTITLE --------------
                        subtitle: (appStateNotifier.isSubtitleVisible)
                            ? Text(
                                note.text,
                                maxLines: 10,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        leading: (appStateNotifier.isNumberVisible) ? Text('$positionNumber') : null,
                        // -------------- list tiles: TRAILING ICONS --------------
                        trailing: (appStateNotifier.isDeletingMode)
                            ? IconButton(
                                onPressed: () {
                                  final noteId = widget.notes[index].id.toString();
                                  setState(() {
                                    switch (appStateNotifier.selectedItems.contains(noteId)) {
                                      case true:
                                        appStateNotifier.selectedItems.removeWhere((item) => item == noteId);
                                        Provider.of<AppNotifier>(context, listen: false)
                                            .selectedItemsForDelete(appStateNotifier.selectedItems);
                                        // ? --------------------------------------------
                                        debugPrint('|===> notes_list_view (local) | ListTile | index: $index');
                                      case false:
                                        appStateNotifier.selectedItems.add(noteId);
                                        Provider.of<AppNotifier>(context, listen: false)
                                            .selectedItemsForDelete(appStateNotifier.selectedItems);
                                        // ? --------------------------------------------
                                        debugPrint('|===> notes_list_view (local) | ListTile | index: $index');
                                    }
                                    (appStateNotifier.selectedItems.isEmpty)
                                        ? Provider.of<AppNotifier>(context, listen: false)
                                            .itemsCheckedToDeleteState(false)
                                        : Provider.of<AppNotifier>(context, listen: false)
                                            .itemsCheckedToDeleteState(true);
                                    // ? --------------------------------------------
                                    debugPrint(
                                        '|===> notes_list_view (local) | ListTile | selectedItems: ${appStateNotifier.selectedItems}, noteId: $noteId \n selectedItems length: ${appStateNotifier.selectedItems.length}');
                                    debugPrint(
                                        '|===> notes_list_view (local) | ListTile | itemsCheckedToDelete: ${appStateNotifier.itemsCheckedToDelete}, isDeletingMode: ${appStateNotifier.isDeletingMode}');
                                  });
                                },
                                icon: (appStateNotifier.selectedItems.contains(note.id.toString()))
                                    ? Icon(
                                        Icons.check_box_outlined,
                                        size: 20.0,
                                        color: Theme.of(context).colorScheme.error,
                                      )
                                    : Icon(
                                        Icons.check_box_outline_blank,
                                        size: 20.0,
                                        color: Theme.of(context).colorScheme.outline,
                                      ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ));
          });
    });
  }
}
