import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:test/services/cloud/rides/cloud_rides_constants.dart';

@immutable
class CloudRide {
  final String documentId;
  final String ownerUID;
  final String? displayName;
  final String? contactNumber;
  final String timePickUp;
  final String timeDropOff;
  final String dateDropOff;
  final String locationDropOff;
  final String locationPickup;
  final String tripStatus;
  final bool? requestStatus;
  final bool confirmationStatus;
  final bool cancellationStatus;
  final bool completion;
  final Timestamp bookingTime;

  const CloudRide({
    required this.documentId,
    required this.ownerUID,
    required this.displayName,
    required this.contactNumber,
    required this.timePickUp,
    required this.timeDropOff,
    required this.dateDropOff,
    required this.locationDropOff,
    required this.locationPickup,
    required this.tripStatus,
    required this.requestStatus,
    required this.confirmationStatus,
    required this.cancellationStatus,
    required this.completion,
    required this.bookingTime,
  });

  CloudRide.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUID = snapshot.data()[ownerUIDFieldName],
        displayName = snapshot.data()[displayNameFieldName],
        contactNumber = snapshot.data()[contactNumberFieldName],
        timePickUp = snapshot.data()[timePickUpFieldName],
        timeDropOff = snapshot.data()[timeDropOffFieldName],
        dateDropOff = snapshot.data()[dateDropOffFieldName],
        locationDropOff = snapshot.data()[locationDropOffFieldName],
        locationPickup = snapshot.data()[locationPickUpFieldName],
        tripStatus = snapshot.data()[tripStatusFieldName],
        requestStatus = snapshot.data()[requestStatusFieldName],
        confirmationStatus = snapshot.data()[confirmationStatusFieldName],
        cancellationStatus = snapshot.data()[cancellationStatusFieldName],
        completion = snapshot.data()[completionFieldName],
        bookingTime = snapshot.data()[bookingTimeFieldName];
}
