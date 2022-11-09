import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uniqart/consants/routes.dart';
import 'package:uniqart/design/color_constants.dart';
import 'package:uniqart/miscellaneous/localizations/loc.dart';
import 'package:uniqart/services/auth/auth_service.dart';
import 'package:uniqart/services/cloud/rides/cloud_rides.dart';
import 'package:uniqart/services/cloud/rides/firebase_cloud_storage_rides.dart';
import 'package:uniqart/services/cloud/users/cloud_user_profile.dart';
import 'package:uniqart/services/cloud/users/firebase_cloud_storage_user_profile.dart';
import 'package:uniqart/services/place/bloc/application_bloc.dart';
import 'package:uniqart/utilities/dialogs/error_dialog.dart';

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

// Textediting controllers
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

  late final ScrollController _scrollController;

  int remaining = 0;
  int absOverage = 0;

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

// Dates Algorithm to get upcoming dates on selected days
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

// Cupertino modal popup
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
            setState(() {
              _timePickUpController.text = DateFormat.jm().format(
                time.subtract(
                  const Duration(minutes: 15),
                ),
              );
              _timeDropOffController.text = DateFormat.jm().format(time);
            });
            if (_repeatBooking == false) {
              setState(() {
                _dateDropOffController.text = DateFormat.MMMEd().format(date);
              });
            }

            Navigator.pop(context);
          },
          child: Text(
            context.loc.generic_select,
            style: const TextStyle(color: uniqartTextField),
          ),
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

    // Initialize selected location listeners and gets place information from api
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

    _scrollController = ScrollController();

    pickupNode = FocusNode();
    dropoffNode = FocusNode();
    bookingRequest = createABookingRequest(context);
  }

// Update location fields to cloud
  void _locationControllerUpateRide() async {
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

// Update single ride fields to cloud
  void _singleFieldUpdateRide() async {
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
        repeatBooking: typeString,
        numOfRides: 1);
  }

// Update repeat fields to cloud
  void _repeatFieldUpdateRide() async {
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

    int count = 0;

    List total = [
      _monSelectedDates.length,
      _tueSelectedDates.length,
      _wedSelectedDates.length,
      _thuSelectedDates.length,
      _friSelectedDates.length,
      _satSelectedDates.length,
      _sunSelectedDates.length,
    ];

    count = total.reduce((value, element) => value + element);
    // remaining = count;

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

// Select location fields listener (update)
  void _setupTextControllerListener() {
    _pickUpController.removeListener(_locationControllerUpateRide);
    _pickUpController.addListener(_locationControllerUpateRide);
    _dropOffController.removeListener(_locationControllerUpateRide);
    _dropOffController.addListener(_locationControllerUpateRide);
  }

// Single ride field listener (update)
  void _setupSingleRideListener() {
    _timeDropOffController.removeListener(_singleFieldUpdateRide);
    _timeDropOffController.addListener(_singleFieldUpdateRide);
    _dateDropOffController.removeListener(_singleFieldUpdateRide);
    _dateDropOffController.addListener(_singleFieldUpdateRide);
    _bookingBoolController.removeListener(_singleFieldUpdateRide);
    _bookingBoolController.addListener(_singleFieldUpdateRide);
  }

// Repeat ride field listener (update)
  void _setupRepeatRideListener() {
    _timeDropOffController.removeListener(_repeatFieldUpdateRide);
    _timeDropOffController.addListener(_repeatFieldUpdateRide);

    _monRepeatDatesController.removeListener(_repeatFieldUpdateRide);
    _monRepeatDatesController.addListener(_repeatFieldUpdateRide);
    _tuesRepeatDatesController.removeListener(_repeatFieldUpdateRide);
    _tuesRepeatDatesController.addListener(_repeatFieldUpdateRide);
    _wedRepeatDatesController.removeListener(_repeatFieldUpdateRide);
    _wedRepeatDatesController.addListener(_repeatFieldUpdateRide);
    _thuRepeatDatesController.removeListener(_repeatFieldUpdateRide);
    _thuRepeatDatesController.addListener(_repeatFieldUpdateRide);
    _friRepeatDatesController.removeListener(_repeatFieldUpdateRide);
    _friRepeatDatesController.addListener(_repeatFieldUpdateRide);
    _satRepeatDatesController.removeListener(_repeatFieldUpdateRide);
    _satRepeatDatesController.addListener(_repeatFieldUpdateRide);
    _sunRepeatDatesController.removeListener(_repeatFieldUpdateRide);
    _sunRepeatDatesController.addListener(_repeatFieldUpdateRide);
    _daysSelectedController.removeListener(_repeatFieldUpdateRide);
    _daysSelectedController.addListener(_repeatFieldUpdateRide);
    _bookingBoolController.removeListener(_repeatFieldUpdateRide);
    _bookingBoolController.addListener(_repeatFieldUpdateRide);
  }

// Creates ride in cloud
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
    _scrollController.dispose();

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
          color: uniqartTextField,
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
              _setupRepeatRideListener();
              if (_repeatBooking == true) {
                _setupSingleRideListener();
              }
              return Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          pickUpLocationField(applicationBloc),
                          dropOffLocationField(applicationBloc),
                          const SizedBox(
                            height: 10,
                          ),
                          SingleChildScrollView(
                            child: Stack(
                              children: [
                                Container(
                                  height: 325,
                                  decoration: const BoxDecoration(
                                      color: Colors.transparent),
                                ),
                                if (_pickUpController.text.isNotEmpty &&
                                    _dropOffController.text.isNotEmpty &&
                                    _inputPickUpController.text.isNotEmpty &&
                                    _inputDropOffController.text.isNotEmpty)
                                  Positioned(
                                    top: 30,
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: timeCupertinoField(),
                                  ),
                                if (_pickUpController.text.isNotEmpty &&
                                    _dropOffController.text.isNotEmpty &&
                                    _inputPickUpController.text.isNotEmpty &&
                                    _inputDropOffController.text.isNotEmpty &&
                                    _timePickUpController.text.isNotEmpty)
                                  Positioned(
                                    top: 95,
                                    left: 55,
                                    child: repeatSwitch(),
                                  ),
                                if (_repeatBooking == true &&
                                    _pickUpController.text.isNotEmpty &&
                                    _dropOffController.text.isNotEmpty &&
                                    _inputPickUpController.text.isNotEmpty &&
                                    _inputDropOffController.text.isNotEmpty &&
                                    _timePickUpController.text.isNotEmpty)
                                  Positioned(
                                    top: 185,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: filterChipsDays(),
                                    ),
                                  ),
                                if (_repeatBooking == false &&
                                    _pickUpController.text.isNotEmpty &&
                                    _dropOffController.text.isNotEmpty &&
                                    _inputPickUpController.text.isNotEmpty &&
                                    _inputDropOffController.text.isNotEmpty)
                                  Positioned(
                                      top: 95,
                                      right: 55,
                                      child: dateCupertinoField()),
                                if (applicationBloc.searchResults.isNotEmpty)
                                  Container(
                                    height: 500,
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      color: uniqartSurfaceWhite,
                                    ),
                                  ),
                                if (applicationBloc.searchResults.isNotEmpty)
                                  Container(
                                    child:
                                        tempAutoCompleteList(applicationBloc),
                                  )
                              ],
                            ),
                          ),
                          if (_repeatBooking == true &&
                              _pickUpController.text.isNotEmpty &&
                              _dropOffController.text.isNotEmpty &&
                              _inputPickUpController.text.isNotEmpty &&
                              _inputDropOffController.text.isNotEmpty &&
                              _timePickUpController.text.isNotEmpty &&
                              _selectedDays.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  Scrollbar(
                                    controller: _scrollController,
                                    thumbVisibility: true,
                                    child: Container(
                                      height: 175,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: SingleChildScrollView(
                                          controller: _scrollController,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                gettingDatesBasedOnDaysSelected(),
                                          )),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 45,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(55, 0, 55, 25),
        child: CupertinoButton(
          color: uniqartPrimary,
          disabledColor: uniqartBackgroundWhite,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(20),
          onPressed: () {
            if ((_repeatBooking == false &&
                _formKey.currentState!.validate())) {
              _ridesService.updateRequestStatus(
                  documentId: _ride!.documentId, requestStatus: true);
              Navigator.of(context).pop(homeRoute);
            } else if ((_repeatBooking == true && remaining >= 0) &&
                (_monSelectedDates.isNotEmpty ||
                    _tueSelectedDates.isNotEmpty ||
                    _wedSelectedDates.isNotEmpty ||
                    _thuSelectedDates.isNotEmpty ||
                    _friSelectedDates.isNotEmpty ||
                    _satSelectedDates.isNotEmpty ||
                    _sunSelectedDates.isNotEmpty)) {
              _ridesService.updateRequestStatus(
                  documentId: _ride!.documentId, requestStatus: true);
              Navigator.of(context).pop(homeRoute);
            } else if (remaining < 0) {
              showErrorDialog(context,
                  "You are trying to book $absOverage trips more than it is available. ");
            } else {
              showErrorDialog(context, context.loc.booking_error);
            }
          },
          child: Text(
            context.loc.booking_request_button,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: uniqartOnSurface,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

// Switch stack that controls type of ride (repeat/single)
  Stack repeatSwitch() {
    return Stack(
      children: [
        Center(
          child: Container(
            height: 45,
            width: 115,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
          ),
        ),
        const Positioned(
          left: 17,
          top: 10,
          child: Icon(
            Icons.event_repeat_rounded,
            color: uniqartPrimary,
          ),
        ),
        Positioned(
          right: 5,
          top: 0.5,
          bottom: 0.5,
          child: Switch.adaptive(
              value: _repeatBooking,
              onChanged: (bool value) {
                setState(() => _repeatBooking = value);
                _bookingBoolController.text = _repeatBooking.toString();
              }),
        ),
      ],
    );
  }

// Stream that helps us to show upcoming dates based on selectd days using dates algorithm and bulid a list of filter chips to allow users to customize
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
              final dateExpiry = retrieveDocument.subExpiryDate;
              final remainingRides = retrieveDocument.remainingRides;

              final present = DateTime.now();
              final expiryDate = dateExpiry.toDate();

              return Column(
                children: [
                  if (remaining < 0)
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Text(
                          "You are trying to book $absOverage trips more than it is available."),
                    ),
                  if (remaining >= -4)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                            _monRepeatDatesController.text =
                                _monSelectedDates.reversed.toString();
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
                            _tuesRepeatDatesController.text =
                                _tueSelectedDates.reversed.toString();
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
                            _wedRepeatDatesController.text =
                                _wedSelectedDates.reversed.toString();
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
                            _thuRepeatDatesController.text =
                                _thuSelectedDates.reversed.toString();
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
                            _friRepeatDatesController.text =
                                _friSelectedDates.reversed.toString();
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
                            _satRepeatDatesController.text =
                                _satSelectedDates.reversed.toString();
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
                            _sunRepeatDatesController.text =
                                _sunSelectedDates.reversed.toString();
                          }
                        } else if (someElement == "Su" &&
                            _sunRepeatDatesController.text.isEmpty) {
                          _sunRepeatDatesController.text =
                              _sunSelectedDates.reversed.toString();
                        }

                        int count = 0;

                        List total = [
                          _monSelectedDates.length,
                          _tueSelectedDates.length,
                          _wedSelectedDates.length,
                          _thuSelectedDates.length,
                          _friSelectedDates.length,
                          _satSelectedDates.length,
                          _sunSelectedDates.length,
                        ];
                        count =
                            total.reduce((value, element) => value + element);

                        remaining = remainingRides - count;
                        absOverage = remaining.abs();

                        return Stack(
                          children: [
                            if (someElement == "Mo")
                              Padding(
                                padding: const EdgeInsets.all(3.0),
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
                                        backgroundColor: uniqartOnSurface,
                                        selectedColor:
                                            CupertinoColors.lightBackgroundGray,
                                        checkmarkColor: uniqartPrimary,
                                        label: Text(dates),
                                        labelStyle: const TextStyle(
                                          color: uniqartTextField,
                                          fontSize: 10,
                                        ),
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
                            if (someElement == "Tu")
                              Padding(
                                padding: const EdgeInsets.all(3.0),
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
                                        backgroundColor: uniqartOnSurface,
                                        selectedColor:
                                            CupertinoColors.lightBackgroundGray,
                                        checkmarkColor: uniqartPrimary,
                                        label: Text(dates),
                                        labelStyle: const TextStyle(
                                          color: uniqartTextField,
                                          fontSize: 10,
                                        ),
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
                            if (someElement == "We")
                              Padding(
                                padding: const EdgeInsets.all(3.0),
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
                                        backgroundColor: uniqartOnSurface,
                                        selectedColor:
                                            CupertinoColors.lightBackgroundGray,
                                        checkmarkColor: uniqartPrimary,
                                        label: Text(dates),
                                        labelStyle: const TextStyle(
                                          color: uniqartTextField,
                                          fontSize: 10,
                                        ),
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
                            if (someElement == "Th")
                              Padding(
                                padding: const EdgeInsets.all(3.0),
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
                                        backgroundColor: uniqartOnSurface,
                                        selectedColor:
                                            CupertinoColors.lightBackgroundGray,
                                        checkmarkColor: uniqartPrimary,
                                        label: Text(dates),
                                        labelStyle: const TextStyle(
                                          color: uniqartTextField,
                                          fontSize: 10,
                                        ),
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
                            if (someElement == "Fr")
                              Padding(
                                padding: const EdgeInsets.all(3.0),
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
                                        backgroundColor: uniqartOnSurface,
                                        selectedColor:
                                            CupertinoColors.lightBackgroundGray,
                                        checkmarkColor: uniqartPrimary,
                                        label: Text(dates),
                                        labelStyle: const TextStyle(
                                          color: uniqartTextField,
                                          fontSize: 10,
                                        ),
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
                            if (someElement == "Sa")
                              Padding(
                                padding: const EdgeInsets.all(3.0),
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
                                        backgroundColor: uniqartOnSurface,
                                        selectedColor:
                                            CupertinoColors.lightBackgroundGray,
                                        checkmarkColor: uniqartPrimary,
                                        label: Text(dates),
                                        labelStyle: const TextStyle(
                                          color: uniqartTextField,
                                          fontSize: 10,
                                        ),
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
                            if (someElement == "Su")
                              Padding(
                                padding: const EdgeInsets.all(3.0),
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
                                        backgroundColor: uniqartOnSurface,
                                        selectedColor:
                                            CupertinoColors.lightBackgroundGray,
                                        checkmarkColor: uniqartPrimary,
                                        label: Text(dates),
                                        labelStyle: const TextStyle(
                                          color: uniqartTextField,
                                          fontSize: 10,
                                        ),
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

// Filter chips to select days
  filterChipsDays() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(55, 0, 55, 0),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          children: [
            "Mo",
            "Tu",
            "We",
            "Th",
            "Fr",
            "Sa",
            "Su",
            "😎",
          ].map(
            (days) {
              return FilterChip(
                backgroundColor: uniqartSecondary,
                selectedColor: uniqartPrimary,
                showCheckmark: false,
                label: Text(
                  days,
                  style: const TextStyle(color: uniqartSurfaceWhite),
                ),
                labelStyle: const TextStyle(
                  color: uniqartDisabled,
                ),
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

// Places autocomplete list
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
            leading: const Icon(
              CupertinoIcons.placemark_fill,
              color: uniqartDisabled,
            ),
            title: Text(
              applicationBloc.searchResults[index].description,
              style: const TextStyle(color: uniqartTextField),
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

// Select time field
  timeCupertinoField() {
    return Stack(
      children: [
        Positioned(
          left: 55,
          right: 55,
          child: Container(
            height: 45,
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          left: 75,
          top: 13,
          child: Center(
            child: Text(
              context.loc.booking_dropoff_text,
              style: const TextStyle(
                color: uniqartTextField,
              ),
            ),
          ),
        ),
        const Positioned(
          left: 145,
          top: 10,
          child: Center(
            child: Icon(
              CupertinoIcons.time,
              color: uniqartPrimary,
            ),
          ),
        ),
        Positioned(
          right: 70,
          top: 8,
          child: Center(
            child: SizedBox(
              width: 105,
              child: CupertinoTextField(
                placeholder: DateFormat.jm().format(time),
                readOnly: true,
                style: const TextStyle(
                  color: uniqartTextField,
                  fontSize: 16,
                ),
                padding: const EdgeInsets.fromLTRB(17, 5, 17, 5),
                controller: _timeDropOffController,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: uniqartOnSurface,
                ),
                onTap: () => _showDialog(
                  selectTime(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

// Select date for single ride
  dateCupertinoField() {
    return Stack(
      children: [
        Center(
          child: Container(
            height: 45,
            width: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          left: -7,
          top: 0.5,
          bottom: 0.5,
          child: SizedBox(
            width: 150,
            child: CupertinoTextFormFieldRow(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.loc.booking_empty_date;
                }
                return null;
              },
              style: const TextStyle(
                color: uniqartTextField,
                fontSize: 16,
              ),
              placeholder: DateFormat.MMMEd().format(date),
              readOnly: true,
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              controller: _dateDropOffController,
              onTap: () {
                _showDialog(
                  selectDate(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

// Select pickup location field
  pickUpLocationField(ApplicationBloc applicationBloc) {
    return Stack(
      children: [
        Positioned(
          right: 7,
          bottom: 0,
          top: 0,
          child: IconButton(
            onPressed: () {
              applicationBloc.clearSelectedPickupLocation();
              _inputPickUpController.clear();
            },
            icon: const Icon(Icons.highlight_off_rounded),
            color: uniqartPrimary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            child: CupertinoTextFormFieldRow(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.loc.booking_empty_pickup;
                }
                return null;
              },
              autofocus: false,
              focusNode: pickupNode,
              controller: _inputPickUpController,
              textInputAction: TextInputAction.next,
              enableSuggestions: true,
              autocorrect: false,
              autofillHints: const [AutofillHints.fullStreetAddress],
              keyboardType: TextInputType.streetAddress,
              placeholder: context.loc.booking_select_pickup,
              onChanged: (value) => applicationBloc.searchPickUpPlaces(value),

              placeholderStyle: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.inactiveGray,
              ),
              style: const TextStyle(
                fontSize: 14,
                color: uniqartTextField,
              ),
              padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: CupertinoColors.lightBackgroundGray,
              ),

              // cursorColor: uniqartOnSurface,
            ),
          ),
        ),
      ],
    );
  }

// Select dropoff location field
  dropOffLocationField(ApplicationBloc applicationBloc) {
    return Stack(
      children: [
        Positioned(
          right: 7,
          bottom: 0,
          top: 0,
          child: IconButton(
            onPressed: () {
              applicationBloc.clearSelectedDropOffLocation();
              _inputDropOffController.clear();
            },
            icon: const Icon(Icons.highlight_off_rounded),
            color: uniqartPrimary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            child: CupertinoTextFormFieldRow(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.loc.booking_empty_dropoff;
                }
                return null;
              },

              autofocus: false,
              focusNode: dropoffNode,
              controller: _inputDropOffController,
              textInputAction: TextInputAction.done,
              enableSuggestions: true,
              autocorrect: false,
              autofillHints: const [AutofillHints.fullStreetAddress],
              keyboardType: TextInputType.streetAddress,
              placeholder: context.loc.booking_select_dropoff,

              onChanged: (value) => applicationBloc.searchDropOffPlaces(value),
              placeholderStyle: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.inactiveGray,
              ),
              style: const TextStyle(
                fontSize: 14,
                color: uniqartTextField,
              ),
              padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: CupertinoColors.lightBackgroundGray,
              ),

              // cursorColor: uniqartOnSurface,
            ),
          ),
        ),
      ],
    );
  }

// Cupertino time picker
  CupertinoDatePicker selectTime() {
    return CupertinoDatePicker(
      initialDateTime: time,
      mode: CupertinoDatePickerMode.time,
      onDateTimeChanged: (DateTime newTime) {
        setState(() => time = newTime);

        // _timeDropOffController.text = DateFormat.jm().format(time);
        // _timePickUpController.text = DateFormat.jm().format(
        //   time.subtract(
        //     const Duration(minutes: 15),
        //   ),
        // );
      },
    );
  }

// Cupertino date picker
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

        // _dateDropOffController.text = DateFormat.MMMEd().format(date);
      },
    );
  }
}
