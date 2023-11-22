import 'package:flutter/foundation.dart';

@immutable
class CloudStorageException implements Exception {
  const CloudStorageException();
}

// ------ If there isn't internet connection ------
// C in CRUD
class CouldNotCreateCloudNoteException extends CloudStorageException {}

// R in CRUD
class CouldNotGetAllCloudNotesException extends CloudStorageException {}

// U in CRUD
class CouldNotUpdateCloudNoteException extends CloudStorageException {}

// D in CRUD
class CouldNotDeleteCloudNoteException extends CloudStorageException {}
