import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test/consants/routes.dart';
import 'package:test/design/color_constants.dart';
import 'package:test/services/auth/auth_service.dart';
import 'package:test/services/cloud/rides/cloud_rides.dart';
import 'package:test/services/cloud/rides/firebase_cloud_storage_rides.dart';
import 'package:test/services/cloud/users/cloud_user_profile.dart';
import 'package:test/services/cloud/users/firebase_cloud_storage_user_profile.dart';
import 'package:test/services/place/bloc/application_bloc.dart';
import 'package:test/views/home/listbuilder/upcoming_rides_list.dart';

// final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// typedef UserCallBack = void Function(CloudUserProfile user);

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final FirebaseRidesCloudStorage _ridesService;
  late final FirebaseUserCloudStorage _userProfileService;

  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _ridesService = FirebaseRidesCloudStorage();
    _userProfileService = FirebaseUserCloudStorage();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);

    return Scaffold(
      // key: _scaffoldKey,
      backgroundColor: CupertinoColors.white,
      appBar: AppBar(
        title: const Text("Uniqart"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          // Top half 2 nested streams (users/rides) to calculate remaining rides
          nestedStreamsTopHalf(applicationBloc),

          // Bottom section for scheduled trips
          const SizedBox(
            height: 25,
          ),
          const Center(
            child: Text(
              "Scheduled Trips",
              style: TextStyle(
                color: uniqartOnSurface,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          StreamBuilder(
            stream: _ridesService.allRides(
              ownerUID: userId,
            ),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  if (snapshot.hasData) {
                    final allRides = snapshot.data as Iterable<CloudRide>;
                    return UpcomingRidesView(
                      rides: allRides.where((element) => true),
                      onCancelRide: (ride) async {
                        await _ridesService.updateCancellationStatus(
                          documentId: ride.documentId,
                          cancellationStatus: true,
                        );
                      },
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                default:
                  return const CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
    );
  }

  StreamBuilder<Iterable<CloudUserProfile>> nestedStreamsTopHalf(
      ApplicationBloc applicationBloc) {
    return StreamBuilder(
      stream: _userProfileService.userDoc(
        ownerUID: userId,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.active:
            if (snapshot.hasData) {
              final allUser = snapshot.data as Iterable<CloudUserProfile>;
              final doc = allUser.where((element) => true);
              final retrieveDocument = doc.elementAt(0);
              final allowedRides = retrieveDocument.ridesLimit;
              final expiryDate = retrieveDocument.subExpiryDate.toDate();

              return StreamBuilder(
                stream: _ridesService.allRides(
                  ownerUID: userId,
                ),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        int counter = 0;
                        final allRides = snapshot.data as Iterable<CloudRide>;
                        final getDocs = allRides.where((element) => true);

                        for (var i = 0; i < getDocs.length; i++) {
                          final loopDocs = getDocs.elementAt(i);
                          final count = loopDocs.numOfRides;
                          counter += count;
                        }

                        final remainder = allowedRides - counter;
                        _userProfileService.updateUserInfo(
                          documentId: retrieveDocument.documentId,
                          remainingRides: remainder,
                        );
                        return Center(
                          child: Stack(
                            children: [
                              // Box container
                              Container(
                                width: double.infinity,
                                height: 375,
                                decoration: const BoxDecoration(
                                  color: uniqartBackgroundWhite,
                                ),
                              ),

                              // Circle box container
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 75,
                                child: Center(
                                  child: Container(
                                    width: 175,
                                    height: 175,
                                    decoration: const BoxDecoration(
                                      color: CupertinoColors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),

                              // 00 rides (text) with condition
                              if (remainder <= 0 ||
                                  DateTime.now().isAfter(expiryDate))
                                const Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  bottom: 90,
                                  child: Center(
                                    child: Text(
                                      "00",
                                      style: TextStyle(
                                          fontSize: 50,
                                          color: uniqartOnSurface),
                                    ),
                                  ),
                                ),

                              // Remaining rides with condition (text)
                              if (remainder > 0 &&
                                  DateTime.now().isBefore(expiryDate))
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  bottom: 90,
                                  child: Center(
                                    child: Text(
                                      "$remainder",
                                      style: const TextStyle(
                                          fontSize: 50,
                                          color: uniqartOnSurface),
                                    ),
                                  ),
                                ),

                              // Text
                              const Positioned(
                                top: 10,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Center(
                                  child: Text(
                                    "remaining rides",
                                    style: TextStyle(
                                        fontSize: 13, color: uniqartOnSurface),
                                  ),
                                ),
                              ),

                              // Subscribe button with condition
                              if (remainder <= 0 ||
                                  DateTime.now().isAfter(expiryDate))
                                Positioned(
                                  top: 285,
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: SizedBox(
                                      height: 25,
                                      width: 225,
                                      child: CupertinoButton(
                                        color: uniqartPrimary,
                                        padding: EdgeInsets.zero,
                                        borderRadius: BorderRadius.circular(10),
                                        onPressed: () {},
                                        child: const Text(
                                          'SUBSCRIBE',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: uniqartOnSurface,
                                              letterSpacing: 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              // Book ride button with condition
                              if (remainder > 0 &&
                                  DateTime.now().isBefore(expiryDate))
                                Positioned(
                                  top: 285,
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: SizedBox(
                                      height: 25,
                                      width: 225,
                                      child: CupertinoButton(
                                        color: uniqartPrimary,
                                        padding: EdgeInsets.zero,
                                        borderRadius: BorderRadius.circular(10),
                                        onPressed: () {
                                          Navigator.of(
                                            context,
                                          ).pushNamed(
                                            createABookingRoute,
                                          );
                                          applicationBloc
                                              .clearSelectedPickupLocation();
                                        },
                                        child: const Text(
                                          'REQUEST AN EXPERIENCE',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: uniqartOnSurface,
                                              letterSpacing: 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }

                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            } else {
              return const CircularProgressIndicator();
            }

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
