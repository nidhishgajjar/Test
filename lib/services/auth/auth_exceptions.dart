// login exceptions
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

// register exceptions

class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

// generic exceptions

class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}

// verify phone exceptions

class InvalidPhoneNumberException implements Exception {}

class PhoneNumberAlreadyExistsException implements Exception {}

// verify code exceptions

class VerificationFailedException implements Exception {}

// delete user exceptions

class ReAuthException implements Exception {}
