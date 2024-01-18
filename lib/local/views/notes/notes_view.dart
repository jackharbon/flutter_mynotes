import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../local/views/notes/notes_list.view.dart';
import '../../../shared/constants/routes.dart';
import '../../../shared/helpers/loading/loading_screen.dart';
import '../../../shared/providers/app_notifier.dart';
import '../../../shared/utilities/actions/online_status_icon.dart';
import '../../../shared/utilities/actions/popup_menu.dart';
import '../../../shared/services/crud/notes_services.dart';

class LocalMyNotesView extends StatefulWidget {
  const LocalMyNotesView({
    super.key,
  });

  @override
  State<LocalMyNotesView> createState() => _LocalMyNotesViewState();
}

class _LocalMyNotesViewState extends State<LocalMyNotesView> {
  late final LocalNotesService _notesService;
  bool isDescending = true;
  bool isSearchOn = false;
  String sortFieldName = 'created_at';

  @override
  void initState() {
    _notesService = LocalNotesService();
    // ? ---------------------------------------------------------------
    // debugPrint('|===> notes_view (local) | initState() | _notesService: $_notesService');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ======================= APP BAR =======================
      appBar: AppBar(
        // -------------- APP BAR counting number of notes --------------
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const OnlineStatusIcon(),
            StreamBuilder(
              stream: _notesService.allLocalNotesStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // ? --------------------------------------------
                  // debugPrint('|===> notes_view (local) | notes count snapshot.data: ${snapshot.data}');
                  final noteCount = snapshot.data!.length;
                  return Text('$noteCount Notes');
                } else {
                  return const Text('My Notes (local)');
                }
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          popupMenuItems(context),
        ],
      ),
      body: Consumer<AppNotifier>(builder: (context, appStateNotifier, child) {
        return FutureBuilder(
          future: _notesService.getOrCreateLocalUser(email: appStateNotifier.userEmail),
          builder: (context, snapshot) {
            // ? ---------------------------------------------------------------
            debugPrint(
                '|===> notes_view (local) | email: ${appStateNotifier.userEmail}, User snapshot: ${snapshot.connectionState}, ${snapshot.data}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.done:
                return Column(
                  children: [
                    Container(
                      color: Theme.of(context).colorScheme.primary,
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // -------------- FIRST TOP BAR LEFT: Left icons search / sort / show
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // -------------- FIRST TOP BAR LEFT: Icons sort aphabetically
                              IconButton(
                                  onPressed: () {
                                    setState(
                                      () {
                                        sortFieldName = 'title';
                                        isDescending = !isDescending;
                                        // ? --------------------------------------------
                                        // debugPrint('|===> notes_view (local) | button isDescending: $isDescending');
                                        // debugPrint('|===> notes_view (local) | button sortFieldName: $sortFieldName');
                                      },
                                    );
                                  },
                                  icon: (sortFieldName == 'title')
                                      ? (isDescending)
                                          ? Icon(
                                              Icons.text_rotate_up,
                                              color: Theme.of(context).colorScheme.onPrimary,
                                            )
                                          : Icon(
                                              Icons.text_rotate_vertical,
                                              color: Theme.of(context).colorScheme.onPrimary,
                                            )
                                      : Icon(
                                          Icons.sort_by_alpha,
                                          color: Theme.of(context).colorScheme.primaryContainer,
                                        )),
                              // -------------- FIRST TOP BAR LEFT: Icons sort created
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      sortFieldName = 'created_at';
                                      isDescending = !isDescending;
                                      // ? --------------------------------------------
                                      // debugPrint('|===> notes_view (local) | button isDescending: $isDescending');
                                      // debugPrint('|===> notes_view (local) | button sortFieldName: $sortFieldName');
                                    });
                                  },
                                  icon: (sortFieldName == 'created_at')
                                      ? (isDescending)
                                          ? Icon(
                                              Icons.arrow_upward,
                                              color: Theme.of(context).colorScheme.onPrimary,
                                            )
                                          : Icon(
                                              Icons.arrow_downward,
                                              color: Theme.of(context).colorScheme.onPrimary,
                                            )
                                      : Icon(
                                          Icons.pending_actions,
                                          color: Theme.of(context).colorScheme.primaryContainer,
                                        )),
                              Text(
                                '|',
                                style: TextStyle(color: Theme.of(context).colorScheme.primaryContainer),
                              ),
                              // -------------- FIRST TOP BAR LEFT: Icons show numbers
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    Provider.of<AppNotifier>(context, listen: false)
                                        .isNumberVisibleState(!appStateNotifier.isNumberVisible);
                                    // ? --------------------------------------------
                                    debugPrint(
                                        '|===> notes_view (local) | button isNumberVisible: $appStateNotifier.isNumberVisible');
                                  });
                                },
                                icon: (appStateNotifier.isNumberVisible)
                                    ? Icon(
                                        Icons.format_list_numbered,
                                        size: 24,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      )
                                    : Icon(
                                        Icons.list,
                                        size: 28,
                                        color: Theme.of(context).colorScheme.primaryContainer,
                                      ),
                              ),
                              // -------------- FIRST TOP BAR LEFT: Icons show notes text
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    Provider.of<AppNotifier>(context, listen: false)
                                        .isSubtitleVisibleState(!appStateNotifier.isSubtitleVisible);
                                    // ? --------------------------------------------
                                    debugPrint(
                                        '|===> notes_view (local) | button isSubtitleVisible: ${appStateNotifier.isSubtitleVisible}');
                                  });
                                },
                                icon: (appStateNotifier.isSubtitleVisible)
                                    ? Icon(
                                        Icons.view_headline,
                                        size: 26,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      )
                                    : Icon(
                                        Icons.view_agenda,
                                        size: 22,
                                        color: Theme.of(context).colorScheme.primaryContainer,
                                      ),
                              ),
                              // -------------- FIRST TOP BAR LEFT: Icons show created_at
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    Provider.of<AppNotifier>(context, listen: false)
                                        .isDateVisibleState(!appStateNotifier.isDateVisible);
                                    // ? --------------------------------------------
                                    debugPrint(
                                        '|===> notes_view (local) | button isDateVisible: ${appStateNotifier.isDateVisible}');
                                  });
                                },
                                icon: (appStateNotifier.isDateVisible)
                                    ? Icon(
                                        Icons.calendar_today,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        size: 22,
                                      )
                                    : Icon(
                                        Icons.event_busy,
                                        color: Theme.of(context).colorScheme.primaryContainer,
                                        size: 26,
                                      ),
                              ),
                              Text(
                                '|',
                                style: TextStyle(color: Theme.of(context).colorScheme.primaryContainer),
                              ),
                            ],
                          ),
                          // -------------- FIRST TOP BAR RIGHT: Icons select all / delete
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // -------------- FIRST TOP BAR RIGHT: Icons delete
                              IconButton(
                                onPressed: () {
                                  // ? --------------------------------------------
                                  debugPrint(
                                      '|===> notes_view (local) | Delete Button | selectedItems: ${appStateNotifier.selectedItems}');
                                  setState(() async {
                                    switch (appStateNotifier.isDeletingMode) {
                                      case false:
                                        Provider.of<AppNotifier>(context, listen: false).isDeletingModeState(true);
                                      case true:
                                        if (appStateNotifier.itemsCheckedToDelete) {
                                          if (appStateNotifier.selectedItems.isEmpty) {
                                            Provider.of<AppNotifier>(context, listen: false)
                                                .itemsCheckedToDeleteState(false);
                                          } else {
                                            for (var noteId in appStateNotifier.selectedItems) {
                                              final noteIdInt = int.parse(noteId);
                                              await _notesService.deleteLocalNote(id: noteIdInt);
                                              // ? --------------------------------
                                              debugPrint(
                                                  '|===> notes_view | Delete button | selectedItems: $appStateNotifier.selectedItems');
                                            }
                                            appStateNotifier.selectedItems.clear();
                                            Provider.of<AppNotifier>(context, listen: false)
                                                .itemsCheckedToDeleteState(false);
                                            Provider.of<AppNotifier>(context, listen: false).isDeletingModeState(false);
                                            Provider.of<AppNotifier>(context, listen: false)
                                                .selectedItemsForDelete(appStateNotifier.selectedItems);
                                            debugPrint(
                                                '|===> notes_view (local) | Delete Button | isDeletingMode: ${appStateNotifier.isDeletingMode}, itemsCheckedToDelete: ${appStateNotifier.itemsCheckedToDelete}');
                                          }
                                        } else {
                                          Provider.of<AppNotifier>(context, listen: false).isDeletingModeState(false);
                                        }
                                        // ? --------------------------------
                                        debugPrint(
                                            '|===> notes_view (local) | Delete Button | isDeletingMode: ${appStateNotifier.isDeletingMode}, itemsCheckedToDelete: ${appStateNotifier.itemsCheckedToDelete}');
                                    }
                                  });
                                },
                                icon: !(appStateNotifier.isDeletingMode)
                                    ? Icon(
                                        Icons.edit_note_outlined,
                                        size: 28,
                                        color: Theme.of(context).colorScheme.primaryContainer,
                                      )
                                    : (appStateNotifier.selectedItems.isEmpty)
                                        ? Icon(
                                            Icons.delete_outline,
                                            color: Theme.of(context).colorScheme.onPrimary,
                                          )
                                        : Icon(
                                            Icons.delete,
                                            color: Theme.of(context).colorScheme.error,
                                          ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // =
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StreamBuilder(
                          stream: _notesService.allLocalNotesStream,
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                              case ConnectionState.active:
                                // ======================= STREAM ALL NOTES =======================title
                                debugPrint(
                                    '|===> notes_view (local) | allNotes snapshot: ${snapshot.connectionState}, ${snapshot.data}');
                                if (snapshot.hasData) {
                                  if (snapshot.data!.isEmpty) {
                                    // -------------- PRESS + to write
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Press',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.w200,
                                          ),
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
                                            },
                                            icon: Icon(
                                              Icons.add,
                                              size: 40,
                                              color: Theme.of(context).colorScheme.primary,
                                            )),
                                        const Text(
                                          'to write your first note.',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.w200,
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    // ======================= LIST OF NOTES =======================
                                    // snapshot.data is NOT Empty
                                    final allNotes = snapshot.data as List<LocalDatabaseNote>;
                                    (sortFieldName == 'created_at')
                                        ? (isDescending)
                                            ? allNotes.sort((b, a) => a.createdAt.compareTo(b.createdAt))
                                            : allNotes.sort((a, b) => a.createdAt.compareTo(b.createdAt))
                                        : (isDescending)
                                            ? allNotes.sort((b, a) => a.title!.compareTo(b.title!))
                                            : allNotes.sort((a, b) => a.title!.compareTo(b.title!));
                                    (isDescending) ? allNotes.reversed : allNotes;
                                    return LocalNotesListView(
                                      notes: allNotes,
                                      onDeleteNote: (note) async {
                                        await _notesService.deleteLocalNote(id: note.id);
                                      },
                                      onTap: (note) {
                                        Navigator.of(context).pushNamed(
                                          createOrUpdateNoteRoute,
                                          arguments: note,
                                        );
                                      },
                                    );
                                  }
                                } else {
                                  // snapshot has NOT data
                                  return const LoadingStandardProgressBar();
                                }
                              default:
                                // switch connection.status DONE
                                return const LoadingStandardProgressBar();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                );
              default:
                return const LoadingStandardProgressBar();
            } // switch (snapshot.connectionState)
          }, // Builder Snapshot
        );
      }),
    );
  }
}
