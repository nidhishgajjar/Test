class CloudStorageException implements Exception {
  const CloudStorageException();
}

// C in CRUD
class CouldNotCreateSubscriberInfoException extends CloudStorageException {}

// R in CRUD
class CouldNotGetAllSubscriberInfoException extends CloudStorageException {}

// U in CRUD
class CouldNotUpdateSubscriberException extends CloudStorageException {}

// D in CRUD
class CouldNotDeleteSubscriberException extends CloudStorageException {}
