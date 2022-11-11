import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uniqart/services/cloud/users/cloud_user_profile.dart';
import 'package:uniqart/services/cloud/users/cloud_user_profile_constants.dart';
import 'package:uniqart/services/cloud/users/cloud_user_profile_exceptions.dart';

class FirebaseUserCloudStorage {
  final userInfo = FirebaseFirestore.instance.collection("userinfo");

// Delete ride
  Future<void> deleteRide({required documentId}) async {
    try {
      await userInfo.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteUserInfoException();
    }
  }

// Update ride
  Future<void> updateUserInfo({
    required String documentId,
    required int remainingRides,
  }) async {
    try {
      await userInfo.doc(documentId).update({
        remainingRidesFieldName: remainingRides,
      });
    } catch (e) {
      throw CouldNotUpdateUserInfoException();
    }
  }

// Read (view all) rides
  Stream<Iterable<CloudUserProfile>> userDoc({
    required String ownerUID,
  }) {
    final allUserInfo = userInfo
        .where(ownerUIDFieldName, isEqualTo: ownerUID)
        .snapshots()
        .map((event) =>
            event.docs.map((doc) => CloudUserProfile.fromSnapshot(doc)));
    return allUserInfo;
  }

  Stream<Iterable<CloudUserProfile>> userEmail({
    required String ownerEmail,
  }) {
    final allUserInfo = userInfo
        .where(ownerEmailFieldName, isEqualTo: ownerEmail)
        .orderBy(accountCreationTimeStampFieldName, descending: true)
        .limit(5)
        .snapshots()
        .map((event) =>
            event.docs.map((doc) => CloudUserProfile.fromSnapshot(doc)));
    return allUserInfo;
  }

  Future<CloudUserProfile> createNewUser(
      {required String ownerUID,
      required String ownerEmail,
      required String? ownerPhoneNumber,
      required String? ownerDisplayName}) async {
    final document = await userInfo.add({
      ownerUIDFieldName: ownerUID,
      ownerEmailFieldName: ownerEmail,
      // ownerPhoneNumberFieldName: ownerPhoneNumber,
      // ownerDisplayNameFieldName: ownerDisplayName,
      userAccountTypeFieldName: 'regular',
      ridesLimitFieldName: 30,
      subscriberFieldName: false,
      trialFieldName: true,
      subscriptionStartDateFieldName: Timestamp.now(),
      subscriptionExpiryDateFieldName:
          DateTime.now().add(const Duration(days: 7)),
      accountCreationTimeStampFieldName: Timestamp.now(),
      remainingRidesFieldName: 30,
    });

    final fetchUser = await document.get();
    return CloudUserProfile(
      documentId: fetchUser.id,
      ownerUID: ownerUID,
      ownerEmail: ownerEmail,
      // ownerPhoneNumber: ownerPhoneNumber,
      // ownerDisplayName: "",
      accountType: "",
      ridesLimit: 30,
      subscriber: false,
      trial: true,
      subStartDate: Timestamp.now(),
      subExpiryDate: Timestamp.now(),
      accountCreation: Timestamp.now(),
      remainingRides: 30,
    );
  }
}
