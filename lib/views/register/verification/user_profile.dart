import 'package:flutter/material.dart';
import 'package:test/services/auth/auth_service.dart';
import 'package:test/services/cloud/users/cloud_user_profile.dart';
import 'package:test/services/cloud/users/firebase_cloud_storage_user_profile.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  CloudUserProfile? _userProfile;
  late Future<CloudUserProfile> profileRequest;
  late final FirebaseUserCloudStorage _userProfileService;
  @override
  void initState() {
    _userProfileService = FirebaseUserCloudStorage();
    super.initState();
    profileRequest = createAUserProfile(context);
  }

  Future<CloudUserProfile> createAUserProfile(BuildContext context) async {
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final email = currentUser.email;
    final phoneNumber = currentUser.phoneNumber;
    final displayName = currentUser.displayName;

    final newProfile = await _userProfileService.createNewUser(
      ownerUID: userId,
      ownerEmail: email,
      ownerPhoneNumber: phoneNumber,
      ownerDisplayName: displayName,
    );

    _userProfile = newProfile;
    return newProfile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: profileRequest,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return const Text("Creating your profile");
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
