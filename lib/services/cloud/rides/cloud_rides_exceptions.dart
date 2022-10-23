class CloudStorageException implements Exception {
  const CloudStorageException();
}

// C in CRUD
class CouldNotCreateRideException extends CloudStorageException {}

// R in CRUD
class CouldNotGetAllRidesException extends CloudStorageException {}

// U in CRUD
class CouldNotUpdateRideException extends CloudStorageException {}

// D in CRUD
class CouldNotDeleteRideException extends CloudStorageException {}
