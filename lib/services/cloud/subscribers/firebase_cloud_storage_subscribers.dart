import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/services/cloud/subscribers/cloud_subscribers.dart';
import 'package:test/services/cloud/subscribers/cloud_subscribers_constants.dart';
import 'package:test/services/cloud/subscribers/cloud_subscribers_exceptions.dart';

class FirebaseSubscriberStripeCloudStorage {
  final subscribers = FirebaseFirestore.instance.collection("userinfo");

// Delete ride
  Future<void> deleteRide({required documentId}) async {
    try {
      await subscribers.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteSubscriberException();
    }
  }

// Update ride
  Future<void> updateRemainderRides({
    required String documentId,
    required num remainingRides,
  }) async {
    try {
      await subscribers.doc(documentId).update({
        remainingRidesFieldName: remainingRides,
      });
    } catch (e) {
      throw CouldNotUpdateSubscriberException();
    }
  }

// Read (view all) profiles
  Stream<Iterable<CloudSubscriberProfile>> subscriberDoc({
    required String subscriberEmail,
  }) {
    final allSubscriptionInfo = subscribers
        .where(subscriberEmailFieldName, isEqualTo: subscriberEmail)
        .snapshots()
        .map((event) =>
            event.docs.map((doc) => CloudSubscriberProfile.fromSnapshot(doc)));
    return allSubscriptionInfo;
  }

  Future<CloudSubscriberProfile> createNewUser(
      {required String subscriberEmail,
      required String subscriberPhoneNumber,
      required String subscriberDisplayName}) async {
    final document = await subscribers.add({
      subscriberEmailFieldName: subscriberEmail,
      subscriberPhoneNumberFieldName: subscriberPhoneNumber,
      subscriberDisplayNameFieldName: subscriberDisplayName,
      remainingRidesFieldName: 00,
      ridesLimitFieldName: 00,
      subscriptionExpiryDateFieldName: Timestamp.now().toString(),
    });

    final fetchUser = await document.get();
    return CloudSubscriberProfile(
      documentId: fetchUser.id,
      // subscriberId: "",
      // subscriberEmail: subscriberEmail,
      // subscriberPhoneNumber: subscriberPhoneNumber,
      // subscriberDisplayName: subscriberDisplayName,
      remainingRides: 00,
      ridesLimit: 00,
      // subStartDate: Timestamp.now().toString(),
      subExpiryDate: Timestamp.now().toString(),
    );
  }
}
