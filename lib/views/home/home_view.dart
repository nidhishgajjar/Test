import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test/consants/routes.dart';
import 'package:test/services/auth/auth_service.dart';
import 'package:test/services/cloud/rides/cloud_rides.dart';
import 'package:test/services/cloud/rides/firebase_cloud_storage.dart';
import 'package:test/services/place/bloc/application_bloc.dart';
import 'package:test/views/home/listbuilder/upcoming_rides_list.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final FirebaseCloudStorage _ridesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _ridesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text("Uniqart"),
          centerTitle: true,
          automaticallyImplyLeading: false,
          // automaticallyImplyLeading: false,
        ),
        body: StreamBuilder(
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
                  final remainder = 60 - rideCount;

                  return ListView(
                    children: [
                      Text("$remainder rides remaining for this month"),
                      if (remainder <= 0)
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text("Subscribe"),
                        ),
                      if (remainder > 0)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                              // rootNavigator: true,
                            ).pushNamed(
                              createABookingRoute,

                              // arguments: ride,
                            );
                            applicationBloc.clearSelectedPickupLocation();
                          },
                          child: const Text("Schedule a ride"),
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
                                final allRides =
                                    snapshot.data as Iterable<CloudRide>;
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
                  );
                } else {
                  return const CircularProgressIndicator();
                }

              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
