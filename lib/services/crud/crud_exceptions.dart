// ====== Exceptions ======

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectoryException implements Exception {}

class DatabaseIsNotOpenException implements Exception {}

// ------ User Exceptions ------

class ColdNotDeleteUserException implements Exception {}

class UserAlreadyExistException implements Exception {}

class CouldNotFindUserException implements Exception {}

// ------ Note Exceptions ------

class ColdNotDeleteNoteException implements Exception {}

class NoteAlreadyExistException implements Exception {}

class CouldNotFindNoteException implements Exception {}

class CouldNotUpdateNoteException implements Exception {}

class UserShouldBeSetBeforeReadingAllNotes implements Exception {}
