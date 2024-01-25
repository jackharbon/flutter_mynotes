// ====== Database Exceptions ======

class LocalDatabaseAlreadyOpenException implements Exception {}

class LocalUnableToGetDocumentsDirectoryException implements Exception {}

class LocalDatabaseIsNotOpenException implements Exception {}

class LocalUnknownAuthException implements Exception {}

// ------ User Exceptions ------

class LocalMissingDataAuthException implements Exception {}

class LocalInvalidEmailAuthException implements Exception {}

class LocalCouldNotDeleteUserException implements Exception {}

class LocalUserAlreadyExistException implements Exception {}

class LocalCouldNotFindUserException implements Exception {}

class LocalWrongPasswordAuthException implements Exception {}

// ------ Note Exceptions ------

class LocalColdNotDeleteLocalNoteException implements Exception {}

class LocalNoteAlreadyExistException implements Exception {}

class LocalCouldNotFindLocalNoteException implements Exception {}

class LocalCouldNotUpdateLocalNoteException implements Exception {}

class LocalUserShouldBeSetBeforeReadingAllNotes implements Exception {}
