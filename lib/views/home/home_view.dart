import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:uniqart/consants/routes.dart';
import 'package:uniqart/design/color_constants.dart';
import 'package:uniqart/services/auth/auth_service.dart';
import 'package:uniqart/services/cloud/rides/cloud_rides.dart';
import 'package:uniqart/services/cloud/rides/firebase_cloud_storage_rides.dart';
import 'package:uniqart/services/cloud/users/cloud_user_profile.dart';
import 'package:uniqart/services/cloud/users/firebase_cloud_storage_user_profile.dart';
import 'package:uniqart/services/place/bloc/application_bloc.dart';
import 'package:uniqart/views/home/listbuilder/upcoming_rides_list.dart';
import 'package:url_launcher/url_launcher.dart';

// final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// typedef UserCallBack = void Function(CloudUserProfile user);

// extension Count<T extends Iterable> on Stream<T> {
//   Stream<int> get getLength => map((event) => event.length);
// }

final Uri _subscribeStripeUrl =
    Uri.parse('https://buy.stripe.com/test_aEUcPz717eCjduE9AA');

Future<void> _launchUrl() async {
  try {
    if (!await launchUrl(
      _subscribeStripeUrl,
      mode: LaunchMode.inAppWebView,
    )) {
    } else {
      throw "could not launch $_subscribeStripeUrl";
    }
  } catch (_) {}
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
      backgroundColor: uniqartBackgroundWhite,
      appBar: AppBar(
        title: const Text(
          "UNIQART",
          // style: TextStyle(color: uniqartOnSurface),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        // backgroundColor: uniqartDisabled,
      ),
      body: ListView(
        children: [
          // Top half 2 nested streams (users/rides) to calculate remaining rides
          nestedStreamsTopHalf(applicationBloc),

          // Bottom section for scheduled trips
          const SizedBox(
            height: 30,
          ),
          const Center(
            child: Text(
              "Scheduled Trips",
              style: TextStyle(
                color: uniqartTextField,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),

          StreamBuilder(
            stream: _ridesService.allScheduledRides(
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
              final startDate = retrieveDocument.subStartDate!.toDate();

              bool trial = retrieveDocument.trial;

              return StreamBuilder(
                stream: _ridesService.allRides(
                  ownerUID: userId,
                  expiryDate: expiryDate,
                  startDate: startDate,
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
                        final formattedExpiry =
                            DateFormat.yMMMd().format(expiryDate);

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
                                height: 475,
                                decoration: const BoxDecoration(
                                  color: uniqartOnSurface,
                                ),
                              ),

                              // Circle box container
                              if (remainder > 0 &&
                                  DateTime.now().isBefore(expiryDate))
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  bottom: 75,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        child: Center(
                                          child: CircularPercentIndicator(
                                            radius: 97,
                                            lineWidth: 15,
                                            backgroundColor: uniqartSecondary,
                                            progressColor: uniqartDisabled,
                                            percent: remainder / allowedRides,
                                            circularStrokeCap:
                                                CircularStrokeCap.round,
                                            animation: true,
                                            center: Container(
                                              width: 165,
                                              decoration: const BoxDecoration(
                                                color: CupertinoColors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // 00 rides (text) with condition
                              if (remainder <= 0 ||
                                  DateTime.now().isAfter(expiryDate))
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  bottom: 70,
                                  child: Center(
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 300,
                                          height: 300,
                                          decoration: BoxDecoration(
                                            color: uniqartBackgroundWhite,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        Positioned(
                                          top: 25,
                                          left: 30,
                                          right: 30,
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: Container(
                                                  width: 250,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: uniqartOnSurface,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                              ),
                                              const Positioned(
                                                top: 7,
                                                left: 0,
                                                right: 0,
                                                child: Center(
                                                  child: Text(
                                                    "Standard Conveyance",
                                                    style: TextStyle(
                                                      color: uniqartTextField,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 90,
                                          left: 30,
                                          right: 30,
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: Container(
                                                  width: 250,
                                                  height: 185,
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: uniqartOnSurface,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 15,
                                                right: 0,
                                                left: 0,
                                                child: Center(
                                                  child: Container(
                                                    height: 20,
                                                    width: 150,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          uniqartSurfaceWhite,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Positioned(
                                                top: 17,
                                                left: 0,
                                                right: 0,
                                                child: Center(
                                                  child: Text(
                                                    "Re-Subscribe",
                                                    style: TextStyle(
                                                      color: uniqartPrimary,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Positioned(
                                                top: 55,
                                                child: SizedBox(
                                                  width: 200,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            35, 0, 0, 0),
                                                    child: Text(
                                                      "Includes 60 trips within a three-kilometer radius of a univeristy.",
                                                      style: TextStyle(
                                                        color: uniqartPrimary,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 10,
                                                left: 0,
                                                right: 0,
                                                child: Center(
                                                  child: Container(
                                                    width: 175,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          uniqartSurfaceWhite,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Positioned(
                                                bottom: 53,
                                                left: 0,
                                                right: 0,
                                                child: Center(
                                                  child: Text(
                                                    "99 CAD/Month",
                                                    style: TextStyle(
                                                      color: uniqartDisabled,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Positioned(
                                                bottom: 15,
                                                left: 0,
                                                right: 0,
                                                child: Center(
                                                  child: Text(
                                                    "1.65 CAD/trip ONLY",
                                                    style: TextStyle(
                                                      color: uniqartTextField,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),

                              // Build Subscribe Section

                              // Remaining rides with condition (text)
                              if (remainder > 0 &&
                                  DateTime.now().isBefore(expiryDate))
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  bottom: 70,
                                  child: Center(
                                    child: Text(
                                      "$remainder",
                                      style: const TextStyle(
                                          fontSize: 50,
                                          color: uniqartTextField),
                                    ),
                                  ),
                                ),

                              // Text
                              if (remainder > 0 &&
                                  DateTime.now().isBefore(expiryDate))
                                const Positioned(
                                  top: 175,
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: Text(
                                      "Remaining Rides",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: uniqartTextField),
                                    ),
                                  ),
                                ),

                              // Subscribe button with condition
                              if (remainder <= 0 ||
                                  DateTime.now().isAfter(expiryDate))
                                Positioned(
                                  top: 350,
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: SizedBox(
                                      height: 50,
                                      width: 300,
                                      child: CupertinoButton(
                                        color: uniqartSecondary,
                                        padding: EdgeInsets.zero,
                                        borderRadius: BorderRadius.circular(20),
                                        onPressed: _launchUrl,
                                        child: Stack(children: const [
                                          Positioned(
                                            left: 85,
                                            top: 13,
                                            child: Icon(
                                              CupertinoIcons
                                                  .bag_fill_badge_plus,
                                              color: uniqartDisabled,
                                            ),
                                          ),
                                          Positioned(
                                            top: 17,
                                            right: 95,
                                            // left: 0,
                                            child: Center(
                                              child: Text(
                                                'SUBSCRIBE',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: uniqartTextField,
                                                    letterSpacing: 1),
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                  ),
                                ),
                              // Subscribe button with condition
                              if (DateTime.now().isAfter(expiryDate
                                      .subtract(const Duration(days: 3))) &&
                                  DateTime.now().isBefore(expiryDate) &&
                                  trial == true)
                                Positioned(
                                  // top: 0,
                                  // left: 0,
                                  // right: 0,
                                  // bottom: 0,
                                  child: Center(
                                    child: SizedBox(
                                      height: 85,
                                      width: double.infinity,
                                      child: CupertinoButton(
                                        color: uniqartDisabled,
                                        padding: const EdgeInsets.all(10),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
                                        onPressed: _launchUrl,
                                        child: Text(
                                          'Trial ends on $formattedExpiry. Please update your payment information. CLICK HERE! (please ignore if already updated)',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: uniqartSurfaceWhite,
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
                                  top: 350,
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: SizedBox(
                                      height: 35,
                                      width: 300,
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
                                        child: Stack(children: const [
                                          Positioned(
                                            left: 35,
                                            top: 5,
                                            child: Icon(
                                              CupertinoIcons
                                                  .location_circle_fill,
                                              color: uniqartSecondary,
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            right: 35,
                                            // left: 0,
                                            child: Center(
                                              child: Text(
                                                'REQUEST AN EXPERIENCE',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: uniqartOnSurface,
                                                    letterSpacing: 1),
                                              ),
                                            ),
                                          ),
                                        ]),

                                        // const Text(
                                        //   'REQUEST AN EXPERIENCE',
                                        //   style: TextStyle(
                                        //       fontSize: 13,
                                        //       color: uniqartOnSurface,
                                        //       letterSpacing: 1),
                                        // ),
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
