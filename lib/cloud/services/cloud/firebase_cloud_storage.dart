// import 'dart:developer' as devtools show log;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'cloud_note.dart';
import 'cloud_storage_constants.dart';
import 'cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes'); // returns collection reference

  // Stream os notes
  Stream<Iterable<CloudNote>> allCloudNotesStream({
    required String ownerUserId,
  }) =>
      notes.snapshots().map((event) =>
          event.docs.map((doc) => CloudNote.fromSnapshot(doc)).where((note) => note.ownerUserId == ownerUserId));

  // Stream<Iterable<CloudNote>> getAllCloudNotes({
  //   required String ownerUserId,
  //   String? sortFieldName,
  //   required bool isSortDescending,
  // }) {
  //   final allNotes = notes
  //       .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
  //       .orderBy("$sortFieldName", descending: isSortDescending)
  //       .snapshots()
  //       .map(
  //         (event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)),
  //       );
  //   // ? --------------------------------------------
  //   devtools.log('firebase_cloud_storage | allNotes() | allNotes ${allNotes.toString()}');
  //   return allNotes;
  // }

  // gets a snapshot of the notes at that moment in time
  Future<Iterable<CloudNote>> getCloudNotes({
    required String ownerUserId,
    String? sortFieldName,
    required bool isSortDescending,
  }) async {
    try {
      return await notes
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .orderBy("$sortFieldName", descending: isSortDescending)
          .get()
          .then((value) {
        return value.docs.map(
          (doc) {
            return CloudNote(
              documentId: doc.id,
              ownerUserId: doc.data()[ownerUserIdFieldName] as String,
              title: doc.data()[titleFieldName] as String,
              text: doc.data()[textFieldName] as String,
              createdAt: doc.data()[createdAtFieldName] as Timestamp,
              isSyncedWithCloud: doc.data()[isSyncedWithCloudFieldName] as bool,
            );
          },
        );
      });
    } catch (e) {
      throw CouldNotGetAllCloudNotesException();
    }
  }

  Future<void> updateCloudNote({
    required String documentId,
    required String title,
    required String text,
    required Timestamp createdAt,
    required bool isSyncedWithCloud,
  }) async {
    try {
      await notes.doc(documentId).update({
        titleFieldName: title,
        textFieldName: text,
        createdAt: FieldValue.serverTimestamp(),
        isSyncedWithCloudFieldName: isSyncedWithCloud,
      });
    } catch (e) {
      throw CouldNotUpdateCloudNoteException();
    }
  }

  Future<CloudNote> createNewCloudNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      titleFieldName: '',
      textFieldName: '',
      createdAtFieldName: (createdAtFieldName.isEmpty) ? DateTime.now() : FieldValue.serverTimestamp(),
      isSyncedWithCloudFieldName: true,
    });
    final fetchedNote = await document.get();
    // ? --------------------------------------------
    // devtools.log('firebase_cloud_storage | createNewNote() | fetchedNote ${fetchedNote.toString()}');
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      title: '',
      text: '',
      createdAt: Timestamp.now(),
      isSyncedWithCloud: true,
    );
  }

  Future<void> deleteCloudNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteCloudNoteException();
    }
  }

// making a cloud storage a singleton
  static final FirebaseCloudStorage _shared = FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance(); // private constructor
  // factory constructor talking to the static final field FirebaseCloudStorage _shared calling private initializer
  factory FirebaseCloudStorage() => _shared;
}
