import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/services/cloud/users/cloud_user_profile.dart';
import 'package:test/services/cloud/users/cloud_user_profile_constants.dart';
import 'package:test/services/cloud/users/cloud_user_profile_exceptions.dart';

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
    required String name,
  }) async {
    try {
      await userInfo.doc(documentId).update({
        ownerDisplayNameFieldName: name,
      });
    } catch (e) {
      throw CouldNotUpdateUserInfoException();
    }
  }

// Read (view all) rides
  Stream<Iterable<CloudUserProfile>> userDoc({required String ownerUID}) {
    final allUserInfo = userInfo
        .where(ownerUIDFieldName, isEqualTo: ownerUID)
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
      ownerPhoneNumberFieldName: ownerPhoneNumber,
      ownerDisplayNameFieldName: ownerDisplayName,
      userAccountTypeFieldName: 'regular',
      ridesLimitFieldName: 60,
      subscriberFieldName: false,
      trialFieldName: false,
      subscriptionStartDateFieldName: null,
      subscriptionExpiryDateFieldName: Timestamp.now(),
      accountCreationTimeStampFieldName: Timestamp.now(),
    });

    final fetchUser = await document.get();
    return CloudUserProfile(
      documentId: fetchUser.id,
      ownerUID: ownerUID,
      ownerEmail: ownerEmail,
      ownerPhoneNumber: ownerPhoneNumber,
      ownerDisplayName: "",
      accountType: "",
      ridesLimit: 60,
      subscriber: false,
      trial: false,
      subStartDate: null,
      subExpiryDate: Timestamp.now(),
      accountCreation: Timestamp.now(),
    );
  }
}
