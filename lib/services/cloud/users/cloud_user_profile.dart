import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:test/services/cloud/users/cloud_user_profile_constants.dart';

@immutable
class CloudUserProfile {
  final String documentId;
  final String ownerUID;
  final String ownerEmail;
  final String? ownerPhoneNumber;
  final String? ownerDisplayName;
  final String accountType;
  final int ridesLimit;
  final bool subscriber;
  final bool trial;
  final Timestamp? subStartDate;
  final Timestamp? subExpiryDate;
  final Timestamp? accountCreation;
  const CloudUserProfile({
    required this.documentId,
    required this.ownerUID,
    required this.ownerEmail,
    required this.ownerPhoneNumber,
    required this.ownerDisplayName,
    required this.accountType,
    required this.ridesLimit,
    required this.subscriber,
    required this.trial,
    required this.subStartDate,
    required this.subExpiryDate,
    required this.accountCreation,
  });

  CloudUserProfile.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUID = snapshot.data()[ownerUIDFieldName],
        ownerEmail = snapshot.data()[ownerEmailFieldName],
        ownerPhoneNumber = snapshot.data()[ownerPhoneNumberFieldName],
        ownerDisplayName = snapshot.data()[ownerDisplayNameFieldName],
        accountType = snapshot.data()[userAccountTypeFieldName],
        ridesLimit = snapshot.data()[ridesLimitFieldName],
        subscriber = snapshot.data()[subscriberFieldName],
        trial = snapshot.data()[trialFieldName],
        subStartDate = snapshot.data()[subscriptionStartDateFieldName],
        subExpiryDate = snapshot.data()[subscriptionExpiryDateFieldName],
        accountCreation = snapshot.data()[accountCreationTimeStampFieldName];
}
