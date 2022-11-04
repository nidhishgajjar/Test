import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test/design/color_constants.dart';
import 'package:test/services/cloud/rides/cloud_rides.dart';
import 'package:test/services/cloud/rides/cloud_rides_constants.dart';
import 'package:test/utilities/dialogs/cancel_booking_dialog.dart';

typedef RideCallback = void Function(CloudRide ride);

class UpcomingRidesView extends StatelessWidget {
  final Iterable<CloudRide> rides;

  final RideCallback onCancelRide;
  const UpcomingRidesView({
    Key? key,
    required this.rides,
    required this.onCancelRide,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: rides.length,
      itemBuilder: (context, index) {
        final ride = rides.elementAt(index);
        final status = ride.tripStatus;
        final pickupTime = ride.timePickUp;
        final pickupLocation = ride.locationPickup;
        final dropoffTime = ride.timeDropOff;
        final dropoffLocation = ride.locationDropOff;
        final datesList = ride.datesDropOff;

        final dates = datesList.join("");
        // final date = dates.replaceAll(new RegExp(r"\p{P}", unicode: true), " ");

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: SingleChildScrollView(
            child: Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              color: uniqartBackgroundWhite,
              child: Stack(
                children: [
                  // Details Container
                  Container(
                    height: 400,
                  ),

                  // Cancellation button
                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      icon: const Icon(CupertinoIcons.xmark_circle_fill),
                      onPressed: () async {
                        final shouldCancel = await showDeleteDialog(context);
                        if (shouldCancel) {
                          onCancelRide(ride);
                        }
                      },
                      color: CupertinoColors.systemRed,
                    ),
                  ),

                  // Status Display
                  Positioned(
                    top: 15,
                    left: 20,
                    child: Stack(
                      children: [
                        Container(
                          height: 25,
                          width: 250,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          top: 0,
                          child: Center(
                            child: Text(
                              "$status ",
                              style: const TextStyle(
                                fontSize: 15,
                                color: uniqartOnSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pick Up Display
                  Positioned(
                    top: 65,
                    left: 20,
                    child: SizedBox(
                      width: 300,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Stack(
                              children: [
                                Container(
                                  height: 25,
                                  width: 75,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                const Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  top: 0,
                                  child: Center(
                                    child: Text(
                                      "Pick Up",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: uniqartOnSurface,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 15, 0, 3),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Time:  $pickupTime ",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: uniqartOnSurface,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 3, 0, 3),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                "Location:  $pickupLocation ",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: uniqartOnSurface,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Drop Off Display
                  Positioned(
                    top: 170,
                    left: 20,
                    child: SizedBox(
                      width: 300,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Stack(
                              children: [
                                Container(
                                  height: 25,
                                  width: 75,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                const Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  top: 0,
                                  child: Center(
                                    child: Text(
                                      "Drop Off",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: uniqartOnSurface,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 15, 0, 3),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Time:  $dropoffTime ",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: uniqartOnSurface,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 3, 0, 3),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                "Location:  $dropoffLocation ",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: uniqartOnSurface,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Selected Dates Display
                  Positioned(
                    top: 275,
                    left: 20,
                    child: SizedBox(
                      width: 300,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Stack(
                              children: [
                                Container(
                                  height: 25,
                                  width: 75,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                const Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  top: 0,
                                  child: Center(
                                    child: Text(
                                      "Date/s",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: uniqartOnSurface,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 15, 0, 3),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "$dates ",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: uniqartOnSurface,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.fromLTRB(8, 3, 0, 3),
                          //   child: Align(
                          //     alignment: Alignment.bottomLeft,
                          //     child: Text(
                          //       "Location:  $dropoffLocation ",
                          //       style: const TextStyle(
                          //         fontSize: 11,
                          //         color: uniqartOnSurface,
                          //         height: 1.3,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
