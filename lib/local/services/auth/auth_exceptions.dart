// User: user-not-found
class UserNotFoundAuthException implements Exception {}

//  User not logged in
class UserNotLoggedInAuthException implements Exception {}

// Missing data
class MissingDataAuthException implements Exception {}

// Email: invalid-email
class InvalidEmailAuthException implements Exception {}

// Email: email-already-in-use
class EmailAlreadyInUseAuthException implements Exception {}

// Password: wrong-password
class WrongPasswordAuthException implements Exception {}

// Password: weak-password
class WeakPasswordAuthException implements Exception {}

// Delete Account
class ColdNotDeleteUserException implements Exception {}

// Default
class UnknownAuthException implements Exception {}

// Generic
class GenericAuthException implements Exception {}
