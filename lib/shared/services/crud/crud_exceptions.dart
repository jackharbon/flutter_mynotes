// ====== Exceptions ======

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectoryException implements Exception {}

class DatabaseIsNotOpenException implements Exception {}

class UnknownAuthException implements Exception {}

// ------ User Exceptions ------

class MissingDataAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

class CouldNotDeleteUserException implements Exception {}

class UserAlreadyExistException implements Exception {}

class CouldNotFindUserException implements Exception {}

class WrongPasswordAuthException implements Exception {}

// ------ Note Exceptions ------

class ColdNotDeleteLocalNoteException implements Exception {}

class LocalNoteAlreadyExistException implements Exception {}

class CouldNotFindLocalNoteException implements Exception {}

class CouldNotUpdateLocalNoteException implements Exception {}

class UserShouldBeSetBeforeReadingAllNotes implements Exception {}
