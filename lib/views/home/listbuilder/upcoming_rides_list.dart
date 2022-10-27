import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test/design/color_constants.dart';
import 'package:test/services/cloud/rides/cloud_rides.dart';
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
        final dropoffTime = ride.timeDropOff;
        final status = ride.tripStatus;

        return Container(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            color: CupertinoColors.extraLightBackgroundGray,
            child: Stack(
              children: [
                const SizedBox(
                  height: 150,
                ),
                Positioned(
                  top: 15,
                  left: 20,
                  child: Text(
                    "$status ",
                    style: const TextStyle(
                      fontSize: 14,
                      color: uniqartOnSurface,
                    ),
                  ),
                ),
                Positioned(
                  top: 55,
                  left: 20,
                  child: Text(
                    "Pick up : $pickupTime ",
                    style: const TextStyle(
                      fontSize: 13,
                      color: uniqartOnSurface,
                    ),
                  ),
                ),
                Positioned(
                  top: 85,
                  left: 20,
                  child: Text(
                    "Drop off : $dropoffTime ",
                    style: const TextStyle(
                      fontSize: 13,
                      color: uniqartOnSurface,
                    ),
                  ),
                ),
                Positioned(
                    top: 100,
                    left: 290,
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
