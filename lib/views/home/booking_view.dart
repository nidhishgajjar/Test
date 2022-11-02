import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:test/consants/routes.dart';
import 'package:test/design/color_constants.dart';
import 'package:test/services/auth/auth_service.dart';
import 'package:test/services/cloud/rides/cloud_rides.dart';
import 'package:test/services/cloud/rides/firebase_cloud_storage_rides.dart';
import 'package:test/services/cloud/users/cloud_user_profile.dart';
import 'package:test/services/cloud/users/firebase_cloud_storage_user_profile.dart';
import 'package:test/services/place/bloc/application_bloc.dart';

class BookingView extends StatefulWidget {
  const BookingView({super.key});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  CloudRide? _ride;

  String get userId => AuthService.firebase().currentUser!.id;

  late DateTime date = DateTime.now().add(const Duration(days: 1));
  late DateTime time = DateTime.now();
  late DateTime datetime = DateTime.now();
  late final currentDate = DateFormat.MMMEd().format(datetime);
  late final currentTime = DateFormat.jm().format(datetime);
  late StreamSubscription locationPickUpSubscription;
  late StreamSubscription locationDropOffSubscription;

  late final FirebaseRidesCloudStorage _ridesService;
  late final FirebaseUserCloudStorage _userProfileService;
  late final TextEditingController _pickUpController;
  late final TextEditingController _inputPickUpController;
  late final TextEditingController _dropOffController;
  late final TextEditingController _inputDropOffController;
  late final TextEditingController _timePickUpController;
  late final TextEditingController _timeDropOffController;
  late final TextEditingController _dateDropOffController;
  late final TextEditingController _monRepeatDatesController;
  late final TextEditingController _tuesRepeatDatesController;
  late final TextEditingController _wedRepeatDatesController;
  late final TextEditingController _thuRepeatDatesController;
  late final TextEditingController _friRepeatDatesController;
  late final TextEditingController _satRepeatDatesController;
  late final TextEditingController _sunRepeatDatesController;
  late final TextEditingController _daysSelectedController;
  late final TextEditingController _bookingBoolController;

  final _selectedDays = [];

  final _allUpcomingMonDates = [];
  final _monSelectedDates = [];

  final _allUpcomingTueDates = [];
  final _tueSelectedDates = [];

  final _allUpcomingWedDates = [];
  final _wedSelectedDates = [];

  final _allUpcomingThuDates = [];
  final _thuSelectedDates = [];

  final _allUpcomingFriDates = [];
  final _friSelectedDates = [];

  final _allUpcomingSatDates = [];
  final _satSelectedDates = [];

  final _allUpcomingSunDates = [];
  final _sunSelectedDates = [];

  late Future<CloudRide> bookingRequest;
  late final _formKey = GlobalKey<FormState>();
  late FocusNode pickupNode;
  late FocusNode dropoffNode;

  bool _repeatBooking = true;

  List daysBetween(DateTime from, DateTime to, day) {
    List dates = [];
    while (from.isBefore(to)) {
      from = from.add(const Duration(days: 1));
      if (from.weekday == day) {
        dates.insert(0, DateFormat.MMMd().format(from));
      }
    }

    return dates;
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: [
          Container(
            height: 175,
            padding: const EdgeInsets.only(top: 6.0),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
              top: true,
              child: child,
            ),
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            _timePickUpController.text = DateFormat.jm().format(
              time.subtract(
                const Duration(minutes: 15),
              ),
            );
            _timeDropOffController.text = DateFormat.jm().format(time);
            _dateDropOffController.text = DateFormat.MMMEd().format(date);

            Navigator.pop(context);
          },
          child: const Text("Done"),
        ),
      ),
    );
  }

  @override
  void initState() {
    final applicationBloc = Provider.of<ApplicationBloc>(
      context,
      listen: false,
    );
    _ridesService = FirebaseRidesCloudStorage();
    _userProfileService = FirebaseUserCloudStorage();
    super.initState();
    locationPickUpSubscription =
        applicationBloc.selectedPickupLocation.stream.listen((place) {
      var pickUpName = place.name;
      var pickUpAddress = place.address;
      _pickUpController.text = "$pickUpName - $pickUpAddress";
      _inputPickUpController.text = "$pickUpName - $pickUpAddress";
      applicationBloc.clearSelectedPickupLocation();
    });
    locationDropOffSubscription =
        applicationBloc.selectedDropOffLocation.stream.listen((place) {
      var dropOffName = place.name;
      var dropOffAddress = place.address;
      _dropOffController.text = "$dropOffName - $dropOffAddress";
      _inputDropOffController.text = "$dropOffName - $dropOffAddress";
      applicationBloc.clearSelectedPickupLocation();
    });

    _pickUpController = TextEditingController();
    _inputPickUpController = TextEditingController();
    _dropOffController = TextEditingController();
    _inputDropOffController = TextEditingController();
    _timePickUpController = TextEditingController();
    _timeDropOffController = TextEditingController();
    _dateDropOffController = TextEditingController();

    _monRepeatDatesController = TextEditingController();
    _tuesRepeatDatesController = TextEditingController();
    _wedRepeatDatesController = TextEditingController();
    _thuRepeatDatesController = TextEditingController();
    _friRepeatDatesController = TextEditingController();
    _satRepeatDatesController = TextEditingController();
    _sunRepeatDatesController = TextEditingController();
    _daysSelectedController = TextEditingController();

    _bookingBoolController = TextEditingController();

    pickupNode = FocusNode();
    dropoffNode = FocusNode();
    bookingRequest = createABookingRequest(context);
  }

  void _locationControllerListener() async {
    final ride = _ride;
    if (ride == null) {
      return;
    }

    final pickUp = _pickUpController.text;
    final dropOff = _dropOffController.text;

    await _ridesService.updateLocationRide(
      documentId: ride.documentId,
      locationPickup: pickUp,
      locationDropOff: dropOff,
    );
  }

  void _singleFieldListener() async {
    final ride = _ride;
    if (ride == null) {
      return;
    }

    final typeString = _bookingBoolController.text;

    final pickUpTimeApprox = _timePickUpController.text;
    final dropOffTime = _timeDropOffController.text;
    final singleDropOffDate = _dateDropOffController.text;

    List dates = [
      singleDropOffDate,
    ];

    await _ridesService.updateSinglDateTimeRide(
        documentId: ride.documentId,
        timePickUp: "$pickUpTimeApprox (approx). We'll confirm shortly.",
        timeDropOff: dropOffTime,
        datesDropOff: dates,
        repeatBooking: typeString);
  }

  void _repeatFieldListener() async {
    final ride = _ride;
    if (ride == null) {
      return;
    }

    final typeString = _bookingBoolController.text;

    final pickUpTimeApprox = _timePickUpController.text;
    final dropOffTime = _timeDropOffController.text;
    final monDropOffDates = _monRepeatDatesController.text;
    final tuesDropOffDates = _tuesRepeatDatesController.text;
    final wedDropOffDates = _wedRepeatDatesController.text;
    final thursDropOffDates = _thuRepeatDatesController.text;
    final friDropOffDates = _friRepeatDatesController.text;
    final satDropOffDates = _satRepeatDatesController.text;
    final sunDropOffDates = _sunRepeatDatesController.text;

    List dates = [
      monDropOffDates,
      tuesDropOffDates,
      wedDropOffDates,
      thursDropOffDates,
      friDropOffDates,
      satDropOffDates,
      sunDropOffDates,
    ];

    List days = [_daysSelectedController.text];

    List total = [
      _monSelectedDates.length,
      _tueSelectedDates.length,
      _wedSelectedDates.length,
      _thuSelectedDates.length,
      _friSelectedDates.length,
      _satSelectedDates.length,
      _sunSelectedDates.length,
    ];

    int count = total.reduce((value, element) => value + element);
    if (count == 0) count = count + 1;

    await _ridesService.updateRepeatRide(
      documentId: ride.documentId,
      timePickUp: "$pickUpTimeApprox (approx). We'll confirm shortly.",
      timeDropOff: dropOffTime,
      datesDropOff: dates,
      repeatBooking: typeString,
      numOfRides: count,
      daysSelected: days,
    );
  }

  void _setupTextControllerListener() {
    _pickUpController.removeListener(_locationControllerListener);
    _pickUpController.addListener(_locationControllerListener);
    _dropOffController.removeListener(_locationControllerListener);
    _dropOffController.addListener(_locationControllerListener);
    _timeDropOffController.removeListener(_repeatFieldListener);
    _timeDropOffController.addListener(_repeatFieldListener);
    _dateDropOffController.removeListener(_singleFieldListener);
    _dateDropOffController.addListener(_singleFieldListener);
    _monRepeatDatesController.removeListener(_repeatFieldListener);
    _monRepeatDatesController.addListener(_repeatFieldListener);
    _tuesRepeatDatesController.removeListener(_repeatFieldListener);
    _tuesRepeatDatesController.addListener(_repeatFieldListener);
    _wedRepeatDatesController.removeListener(_repeatFieldListener);
    _wedRepeatDatesController.addListener(_repeatFieldListener);
    _thuRepeatDatesController.removeListener(_repeatFieldListener);
    _thuRepeatDatesController.addListener(_repeatFieldListener);
    _friRepeatDatesController.removeListener(_repeatFieldListener);
    _friRepeatDatesController.addListener(_repeatFieldListener);
    _satRepeatDatesController.removeListener(_repeatFieldListener);
    _satRepeatDatesController.addListener(_repeatFieldListener);
    _sunRepeatDatesController.removeListener(_repeatFieldListener);
    _sunRepeatDatesController.addListener(_repeatFieldListener);
    _daysSelectedController.removeListener(_repeatFieldListener);
    _daysSelectedController.addListener(_repeatFieldListener);
    _bookingBoolController.removeListener(_repeatFieldListener);
    _bookingBoolController.addListener(_repeatFieldListener);
  }

  Future<CloudRide> createABookingRequest(BuildContext context) async {
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final displayName = currentUser.displayName;
    final contactNumber = currentUser.phoneNumber;

    final newRide = await _ridesService.createNewRide(
      ownerUID: userId,
      displayName: displayName,
      contactNumber: contactNumber,
    );

    _ride = newRide;
    return newRide;
  }

  @override
  void dispose() {
    _pickUpController.dispose();
    _inputPickUpController.dispose();
    _dropOffController.dispose();
    _inputDropOffController.dispose();
    _timePickUpController.dispose();
    _timeDropOffController.dispose();
    _dateDropOffController.dispose();
    _monRepeatDatesController.dispose();
    _tuesRepeatDatesController.dispose();
    _wedRepeatDatesController.dispose();
    _thuRepeatDatesController.dispose();
    _friRepeatDatesController.dispose();
    _satRepeatDatesController.dispose();
    _sunRepeatDatesController.dispose();
    _daysSelectedController.dispose();
    _bookingBoolController.dispose();

    pickupNode.dispose();
    dropoffNode.dispose();
    locationPickUpSubscription.cancel();
    locationDropOffSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _ridesService.deleteRide(
              documentId: _ride?.documentId,
            );
            Navigator.of(
              context,
            ).pop(
              homeRoute,
            );
          },
        ),
        backgroundColor: uniqartSurfaceWhite,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
        future: bookingRequest,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Column(
                      children: [
                        pickUpLocationField(applicationBloc),
                        dropOffLocationField(applicationBloc),
                        const SizedBox(
                          height: 20,
                        ),
                        Stack(
                          children: [
                            Container(
                              height: 500,
                              decoration: const BoxDecoration(
                                  color: Colors.transparent),
                            ),
                            if (_pickUpController.text.isNotEmpty &&
                                _dropOffController.text.isNotEmpty &&
                                _inputPickUpController.text.isNotEmpty &&
                                _inputDropOffController.text.isNotEmpty)
                              Positioned(
                                top: 20,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Row(
                                    children: [
                                      const Text("Repeat Rides"),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Switch.adaptive(
                                          value: _repeatBooking,
                                          onChanged: (bool value) {
                                            setState(
                                                () => _repeatBooking = value);
                                            _bookingBoolController.text =
                                                _repeatBooking.toString();
                                          }),
                                    ],
                                  ),
                                ),
                              ),
                            if (_pickUpController.text.isNotEmpty &&
                                _dropOffController.text.isNotEmpty &&
                                _inputPickUpController.text.isNotEmpty &&
                                _inputDropOffController.text.isNotEmpty)
                              Positioned(
                                top: 25,
                                left: 225,
                                child: timeCupertinoField(),
                              ),
                            if (_repeatBooking == true &&
                                _pickUpController.text.isNotEmpty &&
                                _dropOffController.text.isNotEmpty &&
                                _inputPickUpController.text.isNotEmpty &&
                                _inputDropOffController.text.isNotEmpty)
                              Positioned(
                                top: 70,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: filterChipsDays(),
                                ),
                              ),
                            if (_repeatBooking == true &&
                                _pickUpController.text.isNotEmpty &&
                                _dropOffController.text.isNotEmpty &&
                                _inputPickUpController.text.isNotEmpty &&
                                _inputDropOffController.text.isNotEmpty)
                              Positioned(
                                top: 150,
                                left: 0,
                                right: 0,
                                child: gettingDatesBasedOnDaysSelected(),
                              ),
                            if (_repeatBooking == false &&
                                _pickUpController.text.isNotEmpty &&
                                _dropOffController.text.isNotEmpty &&
                                _inputPickUpController.text.isNotEmpty &&
                                _inputDropOffController.text.isNotEmpty)
                              Positioned(
                                  top: 80,
                                  left: 225,
                                  child: dateCupertinoField()),
                            if (applicationBloc.searchResults.isNotEmpty)
                              Container(
                                  height: 500,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: uniqartSurfaceWhite,
                                  )),
                            if (applicationBloc.searchResults.isNotEmpty)
                              Container(
                                child: tempAutoCompleteList(applicationBloc),
                              )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.of(context).pop(homeRoute);
          }
        },
        label: const Text(
          "create ride",
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  StreamBuilder<Iterable<CloudUserProfile>> gettingDatesBasedOnDaysSelected() {
    return StreamBuilder(
      stream: _userProfileService.userDoc(ownerUID: userId),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.active:
            if (snapshot.hasData) {
              final allUser = snapshot.data as Iterable<CloudUserProfile>;
              final doc = allUser.where((element) => true);
              final retrieveDocument = doc.elementAt(0);
              final date = retrieveDocument.subExpiryDate;
              final remaining = retrieveDocument.remainingRides;
              int absOverage = remaining.abs();

              final present = DateTime.now();
              final expiryDate = date.toDate();
              return Column(
                children: [
                  if (remaining < 0)
                    Text(
                        "You are trying to book $absOverage more than it is available."),
                  if (remaining >= -4)
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _selectedDays.length,
                      itemBuilder: (context, index) {
                        final someElement = _selectedDays.elementAt(index);

                        if (someElement == "Mo" &&
                            _allUpcomingMonDates.isEmpty) {
                          const daySelected = DateTime.monday;
                          final listDates =
                              daysBetween(present, expiryDate, daySelected);

                          for (var i = 0; i < listDates.length; i++) {
                            {
                              _allUpcomingMonDates.add(listDates.elementAt(i));
                              _monSelectedDates.add(listDates.elementAt(i));
                            }
                          }
                        } else if (someElement == "Mo" &&
                            _monRepeatDatesController.text.isEmpty) {
                          _monRepeatDatesController.text =
                              _monSelectedDates.reversed.toString();
                        }

                        if (someElement == "Tu" &&
                            _allUpcomingTueDates.isEmpty) {
                          const daySelected = DateTime.tuesday;
                          final listDates =
                              daysBetween(present, expiryDate, daySelected);

                          for (var i = 0; i < listDates.length; i++) {
                            {
                              _allUpcomingTueDates.add(listDates.elementAt(i));
                              _tueSelectedDates.add(listDates.elementAt(i));
                            }
                          }
                        } else if (someElement == "Tu" &&
                            _tuesRepeatDatesController.text.isEmpty) {
                          _tuesRepeatDatesController.text =
                              _tueSelectedDates.reversed.toString();
                        }

                        if (someElement == "We" &&
                            _allUpcomingWedDates.isEmpty) {
                          const daySelected = DateTime.wednesday;
                          final listDates =
                              daysBetween(present, expiryDate, daySelected);

                          for (var i = 0; i < listDates.length; i++) {
                            {
                              _allUpcomingWedDates.add(listDates.elementAt(i));
                              _wedSelectedDates.add(listDates.elementAt(i));
                            }
                          }
                        } else if (someElement == "We" &&
                            _wedRepeatDatesController.text.isEmpty) {
                          _wedRepeatDatesController.text =
                              _wedSelectedDates.reversed.toString();
                        }

                        if (someElement == "Th" &&
                            _allUpcomingThuDates.isEmpty) {
                          const daySelected = DateTime.thursday;
                          final listDates =
                              daysBetween(present, expiryDate, daySelected);

                          for (var i = 0; i < listDates.length; i++) {
                            {
                              _allUpcomingThuDates.add(listDates.elementAt(i));
                              _thuSelectedDates.add(listDates.elementAt(i));
                            }
                          }
                        } else if (someElement == "Th" &&
                            _thuRepeatDatesController.text.isEmpty) {
                          _thuRepeatDatesController.text =
                              _thuSelectedDates.reversed.toString();
                        }

                        if (someElement == "Fr" &&
                            _allUpcomingFriDates.isEmpty) {
                          const daySelected = DateTime.friday;
                          final listDates =
                              daysBetween(present, expiryDate, daySelected);

                          for (var i = 0; i < listDates.length; i++) {
                            {
                              _allUpcomingFriDates.add(listDates.elementAt(i));
                              _friSelectedDates.add(listDates.elementAt(i));
                            }
                          }
                        } else if (someElement == "Fr" &&
                            _friRepeatDatesController.text.isEmpty) {
                          _friRepeatDatesController.text =
                              _friSelectedDates.reversed.toString();
                        }

                        if (someElement == "Sa" &&
                            _allUpcomingSatDates.isEmpty) {
                          const daySelected = DateTime.saturday;
                          final listDates =
                              daysBetween(present, expiryDate, daySelected);

                          for (var i = 0; i < listDates.length; i++) {
                            {
                              _allUpcomingSatDates.add(listDates.elementAt(i));
                              _satSelectedDates.add(listDates.elementAt(i));
                            }
                          }
                        } else if (someElement == "Sa" &&
                            _satRepeatDatesController.text.isEmpty) {
                          _satRepeatDatesController.text =
                              _satSelectedDates.reversed.toString();
                        }

                        if (someElement == "Su" &&
                            _allUpcomingSunDates.isEmpty) {
                          const daySelected = DateTime.sunday;
                          final listDates =
                              daysBetween(present, expiryDate, daySelected);

                          for (var i = 0; i < listDates.length; i++) {
                            {
                              _allUpcomingSunDates.add(listDates.elementAt(i));
                              _sunSelectedDates.add(listDates.elementAt(i));
                            }
                          }
                        } else if (someElement == "Su" &&
                            _sunRepeatDatesController.text.isEmpty) {
                          _sunRepeatDatesController.text =
                              _sunSelectedDates.reversed.toString();
                        }

                        return Stack(
                          children: [
                            if (someElement == "Mo" && remaining >= -4)
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Center(
                                  child: Wrap(
                                    spacing: 5,
                                    alignment: WrapAlignment.start,
                                    children: [
                                      for (var item
                                          in _allUpcomingMonDates.reversed)
                                        item.toString()
                                    ].map(
                                      (dates) {
                                        return FilterChip(
                                          backgroundColor: CupertinoColors
                                              .lightBackgroundGray,
                                          selectedColor:
                                              CupertinoColors.systemYellow,
                                          showCheckmark: false,
                                          label: Text(dates),
                                          selected:
                                              _monSelectedDates.contains(dates),
                                          onSelected: (val) {
                                            setState(() {
                                              if (val) {
                                                _monSelectedDates.add(dates);
                                              } else {
                                                _monSelectedDates
                                                    .removeWhere((name) {
                                                  return name == dates;
                                                });
                                              }
                                              _monRepeatDatesController.text =
                                                  _monSelectedDates.reversed
                                                      .toString();
                                            });
                                          },
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ),
                            if (someElement == "Tu" && remaining >= -4)
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Center(
                                  child: Wrap(
                                    spacing: 5,
                                    alignment: WrapAlignment.start,
                                    children: [
                                      for (var item
                                          in _allUpcomingTueDates.reversed)
                                        item.toString()
                                    ].map(
                                      (dates) {
                                        return FilterChip(
                                          backgroundColor: CupertinoColors
                                              .lightBackgroundGray,
                                          selectedColor:
                                              CupertinoColors.systemYellow,
                                          showCheckmark: false,
                                          label: Text(dates),
                                          selected:
                                              _tueSelectedDates.contains(dates),
                                          onSelected: (val) {
                                            setState(() {
                                              if (val) {
                                                _tueSelectedDates.add(dates);
                                              } else {
                                                _tueSelectedDates
                                                    .removeWhere((name) {
                                                  return name == dates;
                                                });
                                              }
                                              _tuesRepeatDatesController.text =
                                                  _tueSelectedDates.reversed
                                                      .toString();
                                            });
                                          },
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ),
                            if (someElement == "We" && remaining >= 0)
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Center(
                                  child: Wrap(
                                    spacing: 5,
                                    alignment: WrapAlignment.start,
                                    children: [
                                      for (var item
                                          in _allUpcomingWedDates.reversed)
                                        item.toString()
                                    ].map(
                                      (dates) {
                                        return FilterChip(
                                          backgroundColor: CupertinoColors
                                              .lightBackgroundGray,
                                          selectedColor:
                                              CupertinoColors.systemYellow,
                                          showCheckmark: false,
                                          label: Text(dates),
                                          selected:
                                              _wedSelectedDates.contains(dates),
                                          onSelected: (val) {
                                            setState(() {
                                              if (val) {
                                                _wedSelectedDates.add(dates);
                                              } else {
                                                _wedSelectedDates
                                                    .removeWhere((name) {
                                                  return name == dates;
                                                });
                                              }
                                              _wedRepeatDatesController.text =
                                                  _wedSelectedDates.reversed
                                                      .toString();
                                            });
                                          },
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ),
                            if (someElement == "Th" && remaining >= 0)
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Center(
                                  child: Wrap(
                                    spacing: 5,
                                    alignment: WrapAlignment.start,
                                    children: [
                                      for (var item
                                          in _allUpcomingThuDates.reversed)
                                        item.toString()
                                    ].map(
                                      (dates) {
                                        return FilterChip(
                                          backgroundColor: CupertinoColors
                                              .lightBackgroundGray,
                                          selectedColor:
                                              CupertinoColors.systemYellow,
                                          showCheckmark: false,
                                          label: Text(dates),
                                          selected:
                                              _thuSelectedDates.contains(dates),
                                          onSelected: (val) {
                                            setState(() {
                                              if (val) {
                                                _thuSelectedDates.add(dates);
                                              } else {
                                                _thuSelectedDates
                                                    .removeWhere((name) {
                                                  return name == dates;
                                                });
                                              }
                                              _thuRepeatDatesController.text =
                                                  _thuSelectedDates.reversed
                                                      .toString();
                                            });
                                          },
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ),
                            if (someElement == "Fr" && remaining >= 0)
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Center(
                                  child: Wrap(
                                    spacing: 5,
                                    alignment: WrapAlignment.start,
                                    children: [
                                      for (var item
                                          in _allUpcomingFriDates.reversed)
                                        item.toString()
                                    ].map(
                                      (dates) {
                                        return FilterChip(
                                          backgroundColor: CupertinoColors
                                              .lightBackgroundGray,
                                          selectedColor:
                                              CupertinoColors.systemYellow,
                                          showCheckmark: false,
                                          label: Text(dates),
                                          selected:
                                              _friSelectedDates.contains(dates),
                                          onSelected: (val) {
                                            setState(() {
                                              if (val) {
                                                _friSelectedDates.add(dates);
                                              } else {
                                                _friSelectedDates
                                                    .removeWhere((name) {
                                                  return name == dates;
                                                });
                                              }
                                              _friRepeatDatesController.text =
                                                  _friSelectedDates.reversed
                                                      .toString();
                                            });
                                          },
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ),
                            if (someElement == "Sa" && remaining >= 0)
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Center(
                                  child: Wrap(
                                    spacing: 5,
                                    alignment: WrapAlignment.start,
                                    children: [
                                      for (var item
                                          in _allUpcomingSatDates.reversed)
                                        item.toString()
                                    ].map(
                                      (dates) {
                                        return FilterChip(
                                          backgroundColor: CupertinoColors
                                              .lightBackgroundGray,
                                          selectedColor:
                                              CupertinoColors.systemYellow,
                                          showCheckmark: false,
                                          label: Text(dates),
                                          selected:
                                              _satSelectedDates.contains(dates),
                                          onSelected: (val) {
                                            setState(() {
                                              if (val) {
                                                _satSelectedDates.add(dates);
                                              } else {
                                                _satSelectedDates
                                                    .removeWhere((name) {
                                                  return name == dates;
                                                });
                                              }
                                              _satRepeatDatesController.text =
                                                  _satSelectedDates.reversed
                                                      .toString();
                                            });
                                          },
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ),
                            if (someElement == "Su" && remaining >= 0)
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Center(
                                  child: Wrap(
                                    spacing: 5,
                                    alignment: WrapAlignment.start,
                                    children: [
                                      for (var item
                                          in _allUpcomingSunDates.reversed)
                                        item.toString()
                                    ].map(
                                      (dates) {
                                        return FilterChip(
                                          backgroundColor: CupertinoColors
                                              .lightBackgroundGray,
                                          selectedColor:
                                              CupertinoColors.systemYellow,
                                          showCheckmark: false,
                                          label: Text(dates),
                                          selected:
                                              _sunSelectedDates.contains(dates),
                                          onSelected: (val) {
                                            setState(() {
                                              if (val) {
                                                _sunSelectedDates.add(dates);
                                              } else {
                                                _sunSelectedDates
                                                    .removeWhere((name) {
                                                  return name == dates;
                                                });
                                              }
                                              _satRepeatDatesController.text =
                                                  _sunSelectedDates.reversed
                                                      .toString();
                                            });
                                          },
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ),
                          ],
                        );
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
    );
  }

  Padding filterChipsDays() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 5,
          children: [
            "Mo",
            "Tu",
            "We",
            "Th",
            "Fr",
            "Sa",
            "Su",
          ].map(
            (days) {
              return FilterChip(
                backgroundColor: CupertinoColors.lightBackgroundGray,
                selectedColor: CupertinoColors.systemYellow,
                showCheckmark: false,
                label: Text(days),
                selected: _selectedDays.contains(days),
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedDays.add(days);
                    } else {
                      _selectedDays.removeWhere((name) {
                        return name == days;
                      });
                      if (days == "Mo") {
                        _monRepeatDatesController.clear();
                        _allUpcomingMonDates.clear();
                        _monSelectedDates.clear();
                      } else if (days == "Tu") {
                        _tuesRepeatDatesController.clear();
                        _allUpcomingTueDates.clear();
                        _tueSelectedDates.clear();
                      } else if (days == "We") {
                        _wedRepeatDatesController.clear();
                        _allUpcomingWedDates.clear();
                        _wedSelectedDates.clear();
                      } else if (days == "Th") {
                        _thuRepeatDatesController.clear();
                        _allUpcomingThuDates.clear();
                        _thuSelectedDates.clear();
                      } else if (days == "Fr") {
                        _friRepeatDatesController.clear();
                        _allUpcomingFriDates.clear();
                        _friSelectedDates.clear();
                      } else if (days == "Sa") {
                        _satRepeatDatesController.clear();
                        _allUpcomingSatDates.clear();
                        _satSelectedDates.clear();
                      } else if (days == "Su") {
                        _sunRepeatDatesController.clear();
                        _allUpcomingSunDates.clear();
                        _sunSelectedDates.clear();
                      }
                    }
                    _daysSelectedController.text = _selectedDays.toString();
                  });
                },
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  tempAutoCompleteList(ApplicationBloc applicationBloc) {
    return SizedBox(
      child: ListView.separated(
        separatorBuilder: (context, index) => const Divider(
          height: 10,
          thickness: 0.5,
        ),
        shrinkWrap: true,
        itemCount: applicationBloc.searchResults.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.room),
            title: Text(
              applicationBloc.searchResults[index].description,
              style: const TextStyle(color: Colors.black),
            ),
            onTap: () {
              if (pickupNode.hasFocus) {
                setState(() {
                  applicationBloc.setSelectedPickUpLocation(
                      applicationBloc.searchResults[index].placeId);
                });
              } else {
                setState(() {
                  applicationBloc.setSelectedDropOffLocation(
                      applicationBloc.searchResults[index].placeId);
                });
              }
            },
          );
        },
      ),
    );
  }

  SizedBox timeCupertinoField() {
    return SizedBox(
      width: 125,
      child: CupertinoTextFormFieldRow(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please select dropoff time";
          }
          return null;
        },
        placeholder: DateFormat.jm().format(time),
        readOnly: true,
        prefix: const Icon(CupertinoIcons.time),
        controller: _timeDropOffController,
        onTap: () => _showDialog(
          selectTime(),
        ),
      ),
    );
  }

  SizedBox dateCupertinoField() {
    return SizedBox(
      width: 275,
      child: CupertinoTextFormFieldRow(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please select dropoff date";
          }
          return null;
        },
        placeholder: DateFormat.MMMEd().format(date),
        readOnly: true,
        prefix: const Icon(CupertinoIcons.calendar),
        controller: _dateDropOffController,
        onTap: () {
          _showDialog(
            selectDate(),
          );
        },
      ),
    );
  }

  SizedBox pickUpLocationField(ApplicationBloc applicationBloc) {
    return SizedBox(
      child: CupertinoTextFormFieldRow(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter pickup location";
          }
          return null;
        },
        autofocus: false,
        focusNode: pickupNode,
        controller: _inputPickUpController,
        textInputAction: TextInputAction.next,
        enableSuggestions: true,
        autocorrect: false,
        keyboardType: TextInputType.emailAddress,
        placeholder: "select pickup",
        onChanged: (value) => applicationBloc.searchPickUpPlaces(value),
        prefix: IconButton(
          onPressed: () {
            applicationBloc.clearSelectedPickupLocation();
            _inputPickUpController.clear();
          },
          icon: const Icon(Icons.highlight_off_rounded),
        ),
        placeholderStyle: const TextStyle(
          fontSize: 14,
          color: CupertinoColors.inactiveGray,
        ),
        style: const TextStyle(
          fontSize: 14,
          color: uniqartOnSurface,
        ),
        padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: CupertinoColors.lightBackgroundGray,
        ),

        // cursorColor: uniqartOnSurface,
      ),
      // TextFormField(
      // validator: (value) {
      //   if (value == null || value.isEmpty) {
      //     return "Please enter pickup location";
      //   }
      //   return null;
      // },
      // autofocus: false,
      // focusNode: pickupNode,
      //   controller: _inputPickUpController,
      //   decoration: InputDecoration(
      //       contentPadding: const EdgeInsets.symmetric(
      //         vertical: 0,
      //         horizontal: 20,
      //       ),
      //       prefixIcon: const Icon(Icons.label_rounded),
      // suffixIcon: IconButton(
      //   onPressed: () {
      //     applicationBloc.clearSelectedPickupLocation();
      //     _inputPickUpController.clear();
      //   },
      //   icon: const Icon(Icons.highlight_off_rounded),
      // ),
      //       border: OutlineInputBorder(
      //         borderRadius: BorderRadius.circular(20),
      //       ),
      //       labelText: "select pickup location"),
      // onChanged: (value) => applicationBloc.searchPickUpPlaces(value),
      // ),
    );
  }

  SizedBox dropOffLocationField(ApplicationBloc applicationBloc) {
    return SizedBox(
      child: CupertinoTextFormFieldRow(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter dropoff location";
          }
          return null;
        },
        autofocus: false,
        focusNode: dropoffNode,
        controller: _inputDropOffController,
        textInputAction: TextInputAction.done,
        enableSuggestions: true,
        autocorrect: false,
        keyboardType: TextInputType.streetAddress,
        placeholder: "select dropoff",

        prefix: IconButton(
          onPressed: () {
            applicationBloc.clearSelectedDropOffLocation();
            _inputDropOffController.clear();
          },
          icon: const Icon(Icons.highlight_off_rounded),
        ),

        onChanged: (value) => applicationBloc.searchDropOffPlaces(value),
        placeholderStyle: const TextStyle(
          fontSize: 14,
          color: CupertinoColors.inactiveGray,
        ),
        style: const TextStyle(
          fontSize: 14,
          color: uniqartOnSurface,
        ),
        padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: CupertinoColors.lightBackgroundGray,
        ),

        // cursorColor: uniqartOnSurface,
      ),
    );
  }

  CupertinoDatePicker selectTime() {
    return CupertinoDatePicker(
      initialDateTime: time,
      mode: CupertinoDatePickerMode.time,
      onDateTimeChanged: (DateTime newTime) {
        setState(() => time = newTime);

        _timeDropOffController.text = DateFormat.jm().format(time);
        _timePickUpController.text = DateFormat.jm().format(
          time.subtract(
            const Duration(minutes: 15),
          ),
        );
      },
    );
  }

  CupertinoDatePicker selectDate() {
    return CupertinoDatePicker(
      initialDateTime: DateTime.now().add(const Duration(
        hours: 24,
        minutes: 10,
      )),
      minimumDate: DateTime.now().add(const Duration(hours: 24)),
      mode: CupertinoDatePickerMode.date,
      onDateTimeChanged: (DateTime newDate) {
        setState(() => date = newDate);

        _dateDropOffController.text = DateFormat.MMMEd().format(date);
      },
    );
  }
}
