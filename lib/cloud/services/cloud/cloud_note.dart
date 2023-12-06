import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String title;
  final String text;
  final Timestamp createdAt;
  final bool isSyncedWithCloud;
  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.title,
    required this.text,
    required this.createdAt,
    required this.isSyncedWithCloud,
  });

  // notes are wrapped with Firebase wrapper: QueryDocumentSnapshot

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        title = snapshot.data()[titleFieldName] as String,
        text = snapshot.data()[textFieldName] as String,
        createdAt = snapshot.data()[createdAtFieldName] as Timestamp,
        isSyncedWithCloud = snapshot.data()[isSyncedWithCloudFieldName] as bool;

  @override
  String toString() =>
      'CloudNote, ID = $documentId, ownerUserId = $ownerUserId, title = $title, createdAt: ${createdAt.toDate().toString().substring(0, 16)}, isSyncedWithCloud: $isSyncedWithCloud';
}
