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
        final pickupTime = ride.timePickUp;
        final pickupLocation = ride.locationPickup;
        final dropoffTime = ride.timeDropOff;
        final dropoffLocation = ride.locationDropOff;
        final datesList = ride.datesDropOff;

        final dates = datesList.join("");
        final date = dates.replaceAll(new RegExp(r"\p{P}", unicode: true), " ");

        final daysList = ride.daysSelected;
        final days = daysList.reduce((value, element) => value + element);
        final day = days.replaceAll(new RegExp(r"\p{P}", unicode: true), "");

        final status = ride.tripStatus;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            color: uniqartBackgroundWhite,
            child: Stack(
              children: [
                const SizedBox(
                  height: 375,
                ),
                Positioned(
                  top: 15,
                  left: 20,
                  child: Text(
                    "$status ",
                    style: const TextStyle(
                      fontSize: 15,
                      color: uniqartOnSurface,
                    ),
                  ),
                ),

                Positioned(
                  top: 60,
                  left: 20,
                  child: SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Pick Up",
                            style: TextStyle(
                              fontSize: 13,
                              color: uniqartOnSurface,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Align(
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
                        const SizedBox(
                          height: 5,
                        ),
                        Align(
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
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 175,
                  left: 20,
                  child: SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Drop Off",
                            style: TextStyle(
                              fontSize: 13,
                              color: uniqartOnSurface,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Align(
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
                        const SizedBox(
                          height: 5,
                        ),
                        Align(
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
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 300,
                  left: 20,
                  child: SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Dates:$date",
                            style: const TextStyle(
                              fontSize: 11,
                              color: uniqartOnSurface,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            "Days:  $day",
                            style: const TextStyle(
                              fontSize: 11,
                              color: uniqartOnSurface,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Positioned(
                //   top: 150,
                //   left: 20,
                //   child: Wrap(children: [
                //     SizedBox(
                //       width: 250,
                //       child: Text(
                //         "$pickupLocation ",
                //         style: const TextStyle(
                //           fontSize: 11,
                //           color: uniqartOnSurface,
                //         ),
                //       ),
                //     ),
                //   ]),
                // ),
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
                    )),
              ],
            ),

            // ListTile(
            //   title: Text(
            //     "Ride Status: $status",
            //     maxLines: 1,
            //     softWrap: true,
            //     overflow: TextOverflow.ellipsis,
            //   ),
            //   subtitle: Text("Pickup: $pickup"),
            //   trailing: IconButton(
            //     icon: const Icon(
            //       CupertinoIcons.xmark_circle_fill,
            //       color: CupertinoColors.destructiveRed,
            //     ),
            //     onPressed: () async {
            //       final shouldCancel = await showDeleteDialog(context);
            //       if (shouldCancel) {
            //         onCancelRide(ride);
            //       }
            //     },
            //   ),
            // ),
          ),
        );
      },
    );
  }
}
