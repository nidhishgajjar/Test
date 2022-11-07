import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/services/cloud/rides/cloud_rides.dart';
import 'package:test/services/cloud/rides/cloud_rides_constants.dart';
import 'package:test/services/cloud/rides/cloud_rides_exceptions.dart';

class FirebaseRidesCloudStorage {
  final rides = FirebaseFirestore.instance.collection("rides");

// Delete ride
  Future<void> deleteRide({required documentId}) async {
    try {
      await rides.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteRideException();
    }
  }

// Update Location ride
  Future<void> updateLocationRide({
    required String documentId,
    required String locationDropOff,
    required String locationPickup,
  }) async {
    try {
      await rides.doc(documentId).update({
        locationDropOffFieldName: locationDropOff,
        locationPickUpFieldName: locationPickup,
      });
    } catch (e) {
      throw CouldNotUpdateRideException();
    }
  }

// Update Single ride
  Future<void> updateSinglDateTimeRide({
    required String documentId,
    required String timePickUp,
    required String timeDropOff,
    required List datesDropOff,
    required String repeatBooking,
    required int numOfRides,
  }) async {
    try {
      await rides.doc(documentId).update({
        timePickUpFieldName: timePickUp,
        timeDropOffFieldName: timeDropOff,
        datesDropOffSelectedFieldName: datesDropOff,
        repeatBookingFieldName: repeatBooking,
        numberOfRidesFieldName: numOfRides,
      });
    } catch (e) {
      throw CouldNotUpdateRideException();
    }
  }

  // Update Repeat ride
  Future<void> updateRepeatRide({
    required String documentId,
    required String timePickUp,
    required String timeDropOff,
    required List datesDropOff,
    required String repeatBooking,
    required int numOfRides,
    required List daysSelected,
  }) async {
    try {
      await rides.doc(documentId).update({
        timePickUpFieldName: timePickUp,
        timeDropOffFieldName: timeDropOff,
        datesDropOffSelectedFieldName: datesDropOff,
        repeatBookingFieldName: repeatBooking,
        numberOfRidesFieldName: numOfRides,
        daysSelectedFieldName: daysSelected,
      });
    } catch (e) {
      throw CouldNotUpdateRideException();
    }
  }

// Update Cancellation status
  Future<void> updateCancellationStatus({
    required String documentId,
    required bool cancellationStatus,
  }) async {
    try {
      await rides.doc(documentId).update({
        cancellationStatusFieldName: cancellationStatus,
      });
    } catch (e) {
      throw CouldNotUpdateRideException();
    }
  }

// Update Request status
  Future<void> updateRequestStatus({
    required String documentId,
    required bool requestStatus,
  }) async {
    try {
      await rides.doc(documentId).update({
        requestStatusFieldName: requestStatus,
      });
    } catch (e) {
      throw CouldNotUpdateRideException();
    }
  }

// Read all completed rides
  Stream<Iterable<CloudRide>> allCompletedRides({
    required String ownerUID,
  }) {
    final allCompletedRides = rides
        .where(ownerUIDFieldName, isEqualTo: ownerUID)
        .where(cancellationStatusFieldName, isEqualTo: false)
        .where(completionFieldName, isEqualTo: true)
        // .orderBy(bookingTimeFieldName, descending: true)
        .limit(30)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudRide.fromSnapshot(doc)));
    return allCompletedRides;
  }

// Read all scheduled rides
  Stream<Iterable<CloudRide>> allScheduledRides({
    required String ownerUID,
  }) {
    final allScheduledRides = rides
        .where(ownerUIDFieldName, isEqualTo: ownerUID)
        .where(cancellationStatusFieldName, isEqualTo: false)
        .where(completionFieldName, isEqualTo: false)
        .where(requestStatusFieldName, isEqualTo: true)
        .orderBy(bookingTimeFieldName, descending: true)
        .limit(10)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudRide.fromSnapshot(doc)));
    return allScheduledRides;
  }

// Read all no cancelled ride (maintain ride count)
  Stream<Iterable<CloudRide>> allRides({
    required String ownerUID,
    required DateTime expiryDate,
    required DateTime startDate,
  }) {
    final allRides = rides
        .where(ownerUIDFieldName, isEqualTo: ownerUID)
        .where(cancellationStatusFieldName, isEqualTo: false)
        .where(bookingTimeFieldName, isGreaterThanOrEqualTo: startDate)
        .where(bookingTimeFieldName, isLessThanOrEqualTo: expiryDate)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudRide.fromSnapshot(doc)));
    return allRides;
  }

  Future<CloudRide> createNewRide({
    required String ownerUID,
    required String? displayName,
    required String? contactNumber,
  }) async {
    final document = await rides.add({
      ownerUIDFieldName: ownerUID,
      displayNameFieldName: displayName,
      contactNumberFieldName: contactNumber,
      timePickUpFieldName: '',
      timeDropOffFieldName: '',
      datesDropOffSelectedFieldName: [],
      locationDropOffFieldName: "",
      locationPickUpFieldName: "",
      tripStatusFieldName: "Requested",
      requestStatusFieldName: false,
      confirmationStatusFieldName: false,
      cancellationStatusFieldName: false,
      completionFieldName: false,
      bookingTimeFieldName: Timestamp.now(),
      repeatBookingFieldName: 'true',
      numberOfRidesFieldName: 1,
      daysSelectedFieldName: [],
      qratorFieldName: "Nidhish",
      conveyanceFieldName: "Elantra 2019",
      conveyanceColorFieldName: "Black",
      numberPlateFieldName: "CJPK 870",
      subExpiryDateFieldName: Timestamp.now(),
      subStartDateFieldName: Timestamp.now(),
    });
    // throw const AlertDialog();
    final fetchRide = await document.get();
    return CloudRide(
        documentId: fetchRide.id,
        ownerUID: ownerUID,
        displayName: displayName,
        contactNumber: contactNumber,
        timePickUp: '',
        timeDropOff: "",
        datesDropOff: const [],
        locationDropOff: "",
        locationPickup: "",
        tripStatus: "Requested",
        requestStatus: true,
        confirmationStatus: false,
        cancellationStatus: false,
        completion: false,
        bookingTime: Timestamp.now(),
        repeatBooking: 'true',
        numOfRides: 1,
        daysSelected: const [],
        qratorName: '',
        conveyance: '',
        conveyanceColor: '',
        numPlate: '',
        subExpiryDate: Timestamp.now(),
        subStartDate: Timestamp.now());
  }
}
