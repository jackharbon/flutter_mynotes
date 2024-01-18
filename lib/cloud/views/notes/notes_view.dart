import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/constants/routes.dart';
import '../../../shared/helpers/loading/loading_screen.dart';
import '../../../shared/providers/app_notifier.dart';
import '../../../shared/utilities/actions/online_status_icon.dart';
import '../../../shared/utilities/actions/popup_menu.dart';
import '../../services/auth/auth_service.dart';
import '../../services/cloud/cloud_note.dart';
// import '../../services/cloud/cloud_storage_constants.dart';
import '../../services/cloud/firebase_cloud_storage.dart';
import 'notes_list.view.dart';

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

class CloudMyNotesView extends StatefulWidget {
  const CloudMyNotesView({
    super.key,
    // required this.notes,
  });

  @override
  State<CloudMyNotesView> createState() => _CloudMyNotesViewState();
}

class _CloudMyNotesViewState extends State<CloudMyNotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;
  final db = FirebaseFirestore.instance;

  bool isDescending = true;
  bool isSearchOn = false;
  String sortFieldName = 'created_at';

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    // ? ---------------------------------------------------------------
    // debugPrint('|===> notes_view (cloud) | initState() | _notesService: $_notesService');
    // debugPrint('|===> notes_view (cloud) | initState() | userId: $userId');
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
              stream: _notesService
                  .allCloudNotesStream(
                    ownerUserId: userId,
                    sortFieldName: sortFieldName,
                    isSortDescending: isDescending,
                  )
                  .getLength,
              builder: (context, AsyncSnapshot<int> snapshot) {
                if (snapshot.hasData) {
                  // ? --------------------------------------------
                  // debugPrint('|===> notes_view (cloud) | notes count snapshot.data: ${snapshot.data}');
                  final noteCount = snapshot.data ?? 0;
                  return Text('$noteCount Notes(cloud)');
                } else {
                  return const Text('My Notes (cloud)');
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
                                // debugPrint('|===> notes_view (cloud) | button isDescending: $isDescending');
                                // debugPrint('|===> notes_view (cloud) | button sortFieldName: $sortFieldName');
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
                              // debugPrint('|===> notes_view (cloud) | button isDescending: $isDescending');
                              // debugPrint('|===> notes_view (cloud) | button sortFieldName: $sortFieldName');
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
                              '|===> notes_view (cloud) | Delete Button | selectedItems: ${appStateNotifier.selectedItems}');
                          setState(() async {
                            switch (appStateNotifier.isDeletingMode) {
                              case false:
                                Provider.of<AppNotifier>(context, listen: false).isDeletingModeState(true);
                              case true:
                                if (appStateNotifier.itemsCheckedToDelete) {
                                  if (appStateNotifier.selectedItems.isEmpty) {
                                    Provider.of<AppNotifier>(context, listen: false).itemsCheckedToDeleteState(false);
                                  } else {
                                    for (var noteId in appStateNotifier.selectedItems) {
                                      await _notesService.deleteCloudNote(documentId: noteId);
                                      // ? --------------------------------
                                      debugPrint(
                                          '|===> notes_view | Delete button | selectedItems: $appStateNotifier.selectedItems');
                                    }
                                    appStateNotifier.selectedItems.clear();
                                    Provider.of<AppNotifier>(context, listen: false).itemsCheckedToDeleteState(false);
                                    Provider.of<AppNotifier>(context, listen: false).isDeletingModeState(false);
                                    Provider.of<AppNotifier>(context, listen: false)
                                        .selectedItemsForDelete(appStateNotifier.selectedItems);
                                    debugPrint(
                                        '|===> notes_view (cloud) | Delete Button | isDeletingMode: ${appStateNotifier.isDeletingMode}, itemsCheckedToDelete: ${appStateNotifier.itemsCheckedToDelete}');
                                  }
                                } else {
                                  Provider.of<AppNotifier>(context, listen: false).isDeletingModeState(false);
                                }
                                // ? --------------------------------
                                debugPrint(
                                    '|===> notes_view (cloud) | Delete Button | isDeletingMode: ${appStateNotifier.isDeletingMode}, itemsCheckedToDelete: ${appStateNotifier.itemsCheckedToDelete}');
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
                                    Icons.delete_outlined,
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
            // ======================= STREAM ALL NOTES =======================
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder(
                  stream: _notesService.allCloudNotesStream(
                    ownerUserId: userId,
                    sortFieldName: sortFieldName,
                    isSortDescending: isDescending,
                  ),
                  builder: (context, snapshot) {
                    // ? ---------------------------------------------------------------
                    // debugPrint('|===> notes_view (cloud) | User snapshot: ${snapshot.connectionState}');
                    // debugPrint('|===> notes_view (cloud) | snapshot.data: ${snapshot.data}, userId: $userId');
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        // ? ---------------------------------------------------------------
                        // debugPrint('|===> notes_view (cloud) | allNotes snapshot: ${snapshot.connectionState}');
                        // debugPrint('|===> notes_view (cloud) | snapshot.data: ${snapshot.data}');
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return Row(
                              // -------------- PRESS + to write
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
                            final allNotes = snapshot.data as Iterable<CloudNote>;
                            // ? ---------------------------------------------------------------
                            // debugPrint('|===> notes_view (cloud) | allNotes is not empty: $allNotes');
                            return CloudNotesListView(
                              notes: allNotes,
                              onDeleteNote: (note) async {
                                await _notesService.deleteCloudNote(documentId: note.documentId);
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
                    } // switch (snapshot.connectionState)
                  }, // Builder Snapshot
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
