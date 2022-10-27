class CloudStorageException implements Exception {
  const CloudStorageException();
}

// C in CRUD
class CouldNotCreateUserInfoException extends CloudStorageException {}

// R in CRUD
class CouldNotGetAllUserInfoException extends CloudStorageException {}

// U in CRUD
class CouldNotUpdateUserInfoException extends CloudStorageException {}

// D in CRUD
class CouldNotDeleteUserInfoException extends CloudStorageException {}
