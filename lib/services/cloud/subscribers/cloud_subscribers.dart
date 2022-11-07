// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
// import 'package:uniqart/services/cloud/subscribers/cloud_subscribers_constants.dart';

// @immutable
// class CloudSubscriberProfile {
//   final String documentId;
//   // final String subscriberId;
//   // final String subscriberEmail;
//   // final String subscriberPhoneNumber;
//   // final String subscriberDisplayName;
//   final num ridesLimit;
//   final num remainingRides;
//   // final String subStartDate;
//   final String subExpiryDate;

//   const CloudSubscriberProfile({
//     required this.documentId,
//     // required this.subscriberId,
//     // required this.subscriberEmail,
//     // required this.subscriberPhoneNumber,
//     // required this.subscriberDisplayName,
//     required this.ridesLimit,
//     // required this.subStartDate,
//     required this.subExpiryDate,
//     required this.remainingRides,
//   });

//   CloudSubscriberProfile.fromSnapshot(
//       QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
//       : documentId = snapshot.id,
//         // subscriberId = snapshot.data()[subscriberIdFieldName],
//         // subscriberEmail = snapshot.data()[subscriberEmailFieldName],
//         // subscriberPhoneNumber = snapshot.data()[subscriberPhoneNumberFieldName],
//         // subscriberDisplayName = snapshot.data()[subscriberDisplayNameFieldName],
//         ridesLimit = snapshot.data()[ridesLimitFieldName],
//         // subStartDate = snapshot.data()[subscriptionStartDateFieldName],
//         subExpiryDate = snapshot.data()[subscriptionExpiryDateFieldName],
//         remainingRides = snapshot.data()[remainingRidesFieldName];
// }
