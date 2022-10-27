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
      appBar: AppBar(
        title: const Text("Uniqart"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          nestedStreams(applicationBloc),
          const SizedBox(
            height: 50,
          ),
          Container(
            height: 500,
            padding: const EdgeInsets.fromLTRB(20, 35, 20, 0),
            decoration: const BoxDecoration(
              color: CupertinoColors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30),
              ),
            ),
            child: StreamBuilder(
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
                        rides: allRides.where(
                          (element) => true,
                        ),
                        onCancelRide: (ride) async {
                          await _ridesService.updateRide(
                            documentId: ride.documentId,
                            dateDropOff: ride.dateDropOff,
                            locationDropOff: ride.locationDropOff,
                            locationPickup: ride.locationPickup,
                            timeDropOff: ride.timeDropOff,
                            timePickUp: ride.timePickUp,
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
          ),
        ],
      ),
    );
  }

  StreamBuilder<Iterable<CloudUserProfile>> nestedStreams(
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

              return StreamBuilder(
                stream: _ridesService
                    .allRides(
                      ownerUID: userId,
                    )
                    .getLength,
                builder: (context, AsyncSnapshot<int> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final rideCount = snapshot.data ?? 0;

                        final remainder = allowedRides - rideCount;

                        return Center(
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 35,
                              ),
                              remainingRides(remainder),
                              const SizedBox(
                                height: 50,
                              ),
                              if (remainder <= 0)
                                SizedBox(
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
                              if (remainder > 0)
                                SizedBox(
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

  Stack remainingRides(int remainder) {
    return Stack(
      children: [
        Container(
          width: 175,
          height: 175,
          decoration: const BoxDecoration(
            color: CupertinoColors.white,
            shape: BoxShape.circle,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 15,
          child: Center(
            child: Text(
              "$remainder",
              style: const TextStyle(fontSize: 50, color: uniqartOnSurface),
            ),
          ),
        ),
        const Positioned(
          top: 80,
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(
            child: Text(
              "remaining rides",
              style: TextStyle(fontSize: 13, color: uniqartOnSurface),
            ),
          ),
        ),
      ],
    );
  }
}

class Data {
  int? maxRide;

  Data({
    required this.maxRide,
  });
}
