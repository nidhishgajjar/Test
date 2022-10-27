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

// Update ride
  Future<void> updateRide({
    required String documentId,
    required String locationDropOff,
    required String locationPickup,
    required String timePickUp,
    required String timeDropOff,
    required String dateDropOff,
    required bool cancellationStatus,
  }) async {
    try {
      await rides.doc(documentId).update({
        locationDropOffFieldName: locationDropOff,
        locationPickUpFieldName: locationPickup,
        timePickUpFieldName: timePickUp,
        timeDropOffFieldName: timeDropOff,
        dateDropOffFieldName: dateDropOff,
        cancellationStatusFieldName: cancellationStatus,
      });
    } catch (e) {
      throw CouldNotUpdateRideException();
    }
  }

// Read (view all) rides
  Stream<Iterable<CloudRide>> allRides({
    required String ownerUID,
  }) {
    final allRides = rides
        .where(ownerUIDFieldName, isEqualTo: ownerUID)
        .where(cancellationStatusFieldName, isEqualTo: false)
        .where(requestStatusFieldName, isEqualTo: true)
        // .orderBy(bookingTimeFieldName, descending: false)
        .limit(10)
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
      dateDropOffFieldName: '',
      locationDropOffFieldName: "",
      locationPickUpFieldName: "",
      tripStatusFieldName: "Requested",
      requestStatusFieldName: true,
      confirmationStatusFieldName: false,
      cancellationStatusFieldName: false,
      completionFieldName: false,
      bookingTimeFieldName: Timestamp.now(),
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
      dateDropOff: "",
      locationDropOff: "",
      locationPickup: "",
      tripStatus: "Requested",
      requestStatus: true,
      confirmationStatus: false,
      cancellationStatus: false,
      completion: false,
      bookingTime: Timestamp.now(),
    );
  }
}
