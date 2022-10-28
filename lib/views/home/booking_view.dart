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
  // late StreamSubscription something;
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
  late final TextEditingController _thursRepeatDatesController;
  late final TextEditingController _friRepeatDatesController;
  late final TextEditingController _satRepeatDatesController;
  late final TextEditingController _sunRepeatDatesController;
  late final TextEditingController _daysSelectedController;
  late final TextEditingController _bookingBoolController;

  final _selectedDays = [];
  final _monSelectedDates = [];
  final _tuesSelectedDates = [];
  final _wedSelectedDates = [];
  final _thursSelectedDates = [];
  final _friSelectedDates = [];
  final _satSelectedDates = [];
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
      _inputPickUpController.text = pickUpName;
      applicationBloc.clearSelectedPickupLocation();
    });
    locationDropOffSubscription =
        applicationBloc.selectedDropOffLocation.stream.listen((place) {
      var dropOffName = place.name;
      var dropOffAddress = place.address;
      _dropOffController.text = "$dropOffName - $dropOffAddress";
      _inputDropOffController.text = dropOffName;
      applicationBloc.clearSelectedPickupLocation();
    });

    // something =
    //     applicationBloc.selectedDropOffLocation.stream.listen((place) {});

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
    _thursRepeatDatesController = TextEditingController();
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

    // List total = [
    //   _monSelectedDates.length,
    //   _tuesSelectedDates.length,
    //   _wedSelectedDates.length,
    //   _thursSelectedDates.length,
    //   _friSelectedDates.length,
    //   _satSelectedDates.length,
    //   _sunSelectedDates.length,
    // ];

    // int count = total.reduce((value, element) => value + element);
    // if (count == 0) count = count + 1;

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

    // List total = [
    //   _monSelectedDates.length,
    //   _tuesSelectedDates.length,
    //   _wedSelectedDates.length,
    //   _thursSelectedDates.length,
    //   _friSelectedDates.length,
    //   _satSelectedDates.length,
    //   _sunSelectedDates.length,
    // ];

    // int count = total.reduce((value, element) => value + element);
    // if (count == 0) count = count + 1;

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
    final thursDropOffDates = _thursRepeatDatesController.text;
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
      _tuesSelectedDates.length,
      _wedSelectedDates.length,
      _thursSelectedDates.length,
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
    _thursRepeatDatesController.removeListener(_repeatFieldListener);
    _thursRepeatDatesController.addListener(_repeatFieldListener);
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
    _thursRepeatDatesController.dispose();
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
                        const SizedBox(
                          height: 20,
                        ),
                        dropOffLocationField(applicationBloc),
                        const SizedBox(
                          height: 20,
                        ),
                        Stack(
                          children: [
                            Container(
                              height: 500,
                              // width: double.infinity,
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
              List total = [
                _monSelectedDates.length,
                _tuesSelectedDates.length,
                _wedSelectedDates.length,
                _thursSelectedDates.length,
                _friSelectedDates.length,
                _satSelectedDates.length,
                _sunSelectedDates.length,
              ];

              int count = total.reduce((value, element) => value + element);
              if (count == 0) count = count + 1;
              int overage = remaining - count;
              int absOverage = overage.abs();

              final present = DateTime.now();
              final expiryDate = date.toDate();
              return ListView.builder(
                shrinkWrap: true,
                itemCount: _selectedDays.length,
                itemBuilder: (context, index) {
                  final someElement = _selectedDays.elementAt(index);

                  if (someElement == "Mo" && _monSelectedDates.isEmpty) {
                    const daySelected = DateTime.monday;
                    final listDates =
                        daysBetween(present, expiryDate, daySelected);
                    if (_monSelectedDates.contains(listDates.elementAt(0))) {
                      _monSelectedDates.clear();
                    }

                    for (var i = 0; i < listDates.length; i++) {
                      {
                        _monSelectedDates.add(listDates.elementAt(i));
                      }
                    }

                    _monRepeatDatesController.text =
                        _monSelectedDates.reversed.toString();
                  }

                  if (someElement == "Tu" && _tuesSelectedDates.isEmpty) {
                    const daySelected = DateTime.tuesday;
                    final listDates =
                        daysBetween(present, expiryDate, daySelected);

                    for (var i = 0; i < listDates.length; i++) {
                      {
                        _tuesSelectedDates.add(listDates.elementAt(i));
                      }
                    }

                    _tuesRepeatDatesController.text =
                        _tuesSelectedDates.reversed.toString();
                  }

                  if (someElement == "We" && _wedSelectedDates.isEmpty) {
                    const daySelected = DateTime.wednesday;
                    final listDates =
                        daysBetween(present, expiryDate, daySelected);

                    for (var i = 0; i < listDates.length; i++) {
                      {
                        _wedSelectedDates.add(listDates.elementAt(i));
                      }
                    }
                    _wedRepeatDatesController.text =
                        _wedSelectedDates.reversed.toString();
                  }

                  if (someElement == "Th" && _thursSelectedDates.isEmpty) {
                    const daySelected = DateTime.thursday;
                    final listDates =
                        daysBetween(present, expiryDate, daySelected);

                    for (var i = 0; i < listDates.length; i++) {
                      {
                        _thursSelectedDates.add(listDates.elementAt(i));
                      }
                    }
                    _thursRepeatDatesController.text =
                        _thursSelectedDates.reversed.toString();
                  }

                  if (someElement == "Fr" && _friSelectedDates.isEmpty) {
                    const daySelected = DateTime.friday;
                    final listDates =
                        daysBetween(present, expiryDate, daySelected);

                    for (var i = 0; i < listDates.length; i++) {
                      {
                        _friSelectedDates.add(listDates.elementAt(i));
                      }
                    }
                    _friRepeatDatesController.text =
                        _friSelectedDates.reversed.toString();
                  }

                  if (someElement == "Sa" && _satSelectedDates.isEmpty) {
                    const daySelected = DateTime.saturday;
                    final listDates =
                        daysBetween(present, expiryDate, daySelected);

                    for (var i = 0; i < listDates.length; i++) {
                      {
                        _satSelectedDates.add(listDates.elementAt(i));
                      }
                    }
                    _satRepeatDatesController.text =
                        _satSelectedDates.reversed.toString();
                  }

                  if (someElement == "Su" && _sunSelectedDates.isEmpty) {
                    const daySelected = DateTime.sunday;
                    final listDates =
                        daysBetween(present, expiryDate, daySelected);

                    for (var i = 0; i < listDates.length; i++) {
                      {
                        _sunSelectedDates.add(listDates.elementAt(i));
                      }
                    }
                    _sunRepeatDatesController.text =
                        _sunSelectedDates.reversed.toString();
                  }
                  // Reverse dats without brackets

                  final reversedMon = _monSelectedDates.reversed;
                  final monDates = reversedMon.join(", ");

                  final reversedTue = _tuesSelectedDates.reversed;
                  final tueDates = reversedTue.join(", ");

                  final reversedWed = _wedSelectedDates.reversed;
                  final wedDates = reversedWed.join(", ");

                  final reversedThu = _thursSelectedDates.reversed;
                  final thuDates = reversedThu.join(", ");

                  final reversedFri = _friSelectedDates.reversed;
                  final friDates = reversedFri.join(", ");

                  final reversedSat = _satSelectedDates.reversed;
                  final satDates = reversedSat.join(", ");

                  final reversedSun = _sunSelectedDates.reversed;
                  final sunDates = reversedSun.join(", ");

                  return Stack(
                    children: [
                      if (count > remaining)
                        Text(
                            "You are trying to book $absOverage more than it is available."),
                      if (someElement == "Mo" && count < remaining)
                        Row(
                          children: [
                            const Text("Monday - "),
                            Text("$monDates "),
                          ],
                        ),
                      if (someElement == "Tu" && count < remaining)
                        Row(
                          children: [
                            const Text("Tuesday - "),
                            Text("$tueDates "),
                          ],
                        ),
                      if (someElement == "We" && count < remaining)
                        Row(
                          children: [
                            const Text("Wednesday - "),
                            Text("$wedDates "),
                          ],
                        ),
                      if (someElement == "Th" && count < remaining)
                        Row(
                          children: [
                            const Text("Thursday - "),
                            Text("$thuDates "),
                          ],
                        ),
                      if (someElement == "Fr" && count < remaining)
                        Row(
                          children: [
                            const Text("Friday - "),
                            Text("$friDates "),
                          ],
                        ),
                      if (someElement == "Sa" && count < remaining)
                        Row(
                          children: [
                            const Text("Saturday - "),
                            Text("$satDates "),
                          ],
                        ),
                      if (someElement == "Su" && count < remaining)
                        Row(
                          children: [
                            const Text("Sunday - "),
                            Text("$sunDates "),
                          ],
                        ),
                    ],
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
    );
  }

  Padding filterChipsDays() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
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
                  }
                  _daysSelectedController.text = _selectedDays.toString();

                  _monSelectedDates.clear();
                  _monRepeatDatesController.clear();
                  _tuesSelectedDates.clear();
                  _tuesRepeatDatesController.clear();
                  _wedSelectedDates.clear();
                  _wedRepeatDatesController.clear();
                  _thursSelectedDates.clear();
                  _thursRepeatDatesController.clear();
                  _friSelectedDates.clear();
                  _friRepeatDatesController.clear();
                  _satSelectedDates.clear();
                  _satRepeatDatesController.clear();
                  _sunSelectedDates.clear();
                  _sunRepeatDatesController.clear();
                });
              },
            );
          },
        ).toList(),
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
      width: 275,
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter pickup location";
          }
          return null;
        },
        autofocus: false,
        focusNode: pickupNode,
        controller: _inputPickUpController,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 20,
            ),
            prefixIcon: const Icon(Icons.label_rounded),
            suffixIcon: IconButton(
              onPressed: () {
                applicationBloc.clearSelectedPickupLocation();
                _inputPickUpController.clear();
              },
              icon: const Icon(Icons.highlight_off_rounded),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            labelText: "select pickup location"),
        onChanged: (value) => applicationBloc.searchPickUpPlaces(value),
      ),
    );
  }

  SizedBox dropOffLocationField(ApplicationBloc applicationBloc) {
    return SizedBox(
      width: 275,
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter dropoff location";
          }
          return null;
        },
        autofocus: false,
        focusNode: dropoffNode,
        controller: _inputDropOffController,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 20,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                applicationBloc.clearSelectedDropOffLocation();
                _inputDropOffController.clear();
              },
              icon: const Icon(Icons.clear_rounded),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            labelText: "select dropoff location"),
        onChanged: (value) => applicationBloc.searchDropOffPlaces(value),
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
