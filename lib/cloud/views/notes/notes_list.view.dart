import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/extensions/buildcontext/loc.dart';
import '../../../shared/providers/app_notifier.dart';
import '../../services/cloud/cloud_note.dart';

typedef NoteCallback = void Function(CloudNote note);

class CloudNotesListView extends StatefulWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const CloudNotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  State<CloudNotesListView> createState() => _CloudNotesListViewState();
}

class _CloudNotesListViewState extends State<CloudNotesListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (context, appStateNotifier, child) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: widget.notes.length,
          itemBuilder: (context, index) {
            final note = widget.notes.elementAt(index);
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
                        context.loc.notes_list_view_delete_note,
                        style: TextStyle(
                          fontSize: 20,
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
                        widget.onTap(note);
                      },
                      // -------------- list tiles: TITLE --------------
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              (note.title.isNotEmpty) ? note.title : '...',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: true,
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
                              note.createdAt.toDate().toString().substring(2, 16),
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
                                final note = widget.notes.elementAt(index);
                                setState(() {
                                  switch (appStateNotifier.selectedItems.contains(note.documentId)) {
                                    case true:
                                      appStateNotifier.selectedItems.removeWhere((item) => item == note.documentId);
                                      Provider.of<AppNotifier>(context, listen: false)
                                          .selectedItemsForDelete(appStateNotifier.selectedItems);
                                    // ? --------------------------------------------
                                    // debugPrint('|===> notes_list_view (cloud) | ListTile | index: $index');
                                    case false:
                                      appStateNotifier.selectedItems.add(note.documentId);
                                      Provider.of<AppNotifier>(context, listen: false)
                                          .selectedItemsForDelete(appStateNotifier.selectedItems);
                                    // ? --------------------------------------------
                                    // debugPrint('|===> notes_list_view (cloud) | ListTile | index: $index');
                                  }
                                  (appStateNotifier.selectedItems.isEmpty)
                                      ? Provider.of<AppNotifier>(context, listen: false)
                                          .itemsCheckedToDeleteState(false)
                                      : Provider.of<AppNotifier>(context, listen: false)
                                          .itemsCheckedToDeleteState(true);
                                  // ? --------------------------------------------
                                  // debugPrint(
                                  // '|===> notes_list_view (cloud) | ListTile | selectedItems: ${appStateNotifier.selectedItems}, note.documentId: ${note.documentId} \n selectedItems length: ${appStateNotifier.selectedItems.length}');
                                  // debugPrint(
                                  // '|===> notes_list_view (cloud) | ListTile | itemsCheckedToDelete: ${appStateNotifier.itemsCheckedToDelete}, isDeletingMode: ${appStateNotifier.isDeletingMode}');
                                });
                              },
                              icon: (appStateNotifier.selectedItems.contains(note.documentId))
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
              ),
            );
          },
        );
      },
    );
  }
}
