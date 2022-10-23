import 'package:flutter/material.dart';
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
    return Scrollbar(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final ride = rides.elementAt(index);
          final pickup = ride.locationPickup;
          final dropoff = ride.locationDropOff;
          final status = ride.tripStatus;

          return ListTile(
            title: Text(
              "Ride Status: $status",
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text("Pickup: $pickup"),
            trailing: ElevatedButton(
                onPressed: () async {
                  final shouldCancel = await showDeleteDialog(context);
                  if (shouldCancel) {
                    onCancelRide(ride);
                  }
                },
                child: const Text("Cancel")),
          );
        },
      ),
    );
  }
}
