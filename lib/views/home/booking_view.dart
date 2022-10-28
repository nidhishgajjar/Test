import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:test/consants/routes.dart';
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

  void _pickUpDropOffControllerListener() async {
    final ride = _ride;
    if (ride == null) {
      return;
    }

    // final typeString = _bookingBoolController.text;

    final pickUp = _pickUpController.text;
    final dropOff = _dropOffController.text;
    final pickUpTimeApprox = _timePickUpController.text;
    final dropOffTime = _timeDropOffController.text;
    final singleDropOffDate = _dateDropOffController.text;
    final monDropOffDates = _monRepeatDatesController.text;
    final tuesDropOffDates = _tuesRepeatDatesController.text;
    final wedDropOffDates = _wedRepeatDatesController.text;
    final thursDropOffDates = _thursRepeatDatesController.text;
    final friDropOffDates = _friRepeatDatesController.text;
    final satDropOffDates = _satRepeatDatesController.text;
    final sunDropOffDates = _sunRepeatDatesController.text;

    List dates = [
      singleDropOffDate,
      monDropOffDates,
      tuesDropOffDates,
      wedDropOffDates,
      thursDropOffDates,
      friDropOffDates,
      satDropOffDates,
      sunDropOffDates,
    ];
    if (dates.isEmpty) {}

    // List days = [_daysSelectedController.text];

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

    await _ridesService.updateSingleRide(
      documentId: ride.documentId,
      locationPickup: pickUp,
      locationDropOff: dropOff,
      timePickUp: "$pickUpTimeApprox (approx). We'll confirm shortly.",
      timeDropOff: dropOffTime,
      datesDropOff: dates,
      // cancellationStatus: false,
      // repeatBooking: typeString,
      // numOfRides: count,
      // daysSelected: days,
    );
  }

  void _setupTextControllerListener() {
    _pickUpController.removeListener(_pickUpDropOffControllerListener);
    _pickUpController.addListener(_pickUpDropOffControllerListener);
    _dropOffController.removeListener(_pickUpDropOffControllerListener);
    _dropOffController.addListener(_pickUpDropOffControllerListener);
    _timeDropOffController.removeListener(_pickUpDropOffControllerListener);
    _timeDropOffController.addListener(_pickUpDropOffControllerListener);
    _dateDropOffController.removeListener(_pickUpDropOffControllerListener);
    _dateDropOffController.addListener(_pickUpDropOffControllerListener);
    _monRepeatDatesController.removeListener(_pickUpDropOffControllerListener);
    _monRepeatDatesController.addListener(_pickUpDropOffControllerListener);
    _tuesRepeatDatesController.removeListener(_pickUpDropOffControllerListener);
    _tuesRepeatDatesController.addListener(_pickUpDropOffControllerListener);
    _wedRepeatDatesController.removeListener(_pickUpDropOffControllerListener);
    _wedRepeatDatesController.addListener(_pickUpDropOffControllerListener);
    _thursRepeatDatesController
        .removeListener(_pickUpDropOffControllerListener);
    _thursRepeatDatesController.addListener(_pickUpDropOffControllerListener);
    _friRepeatDatesController.removeListener(_pickUpDropOffControllerListener);
    _friRepeatDatesController.addListener(_pickUpDropOffControllerListener);
    _satRepeatDatesController.removeListener(_pickUpDropOffControllerListener);
    _satRepeatDatesController.addListener(_pickUpDropOffControllerListener);
    _sunRepeatDatesController.removeListener(_pickUpDropOffControllerListener);
    _sunRepeatDatesController.addListener(_pickUpDropOffControllerListener);
    _daysSelectedController.removeListener(_pickUpDropOffControllerListener);
    _daysSelectedController.addListener(_pickUpDropOffControllerListener);
    _bookingBoolController.removeListener(_pickUpDropOffControllerListener);
    _bookingBoolController.addListener(_pickUpDropOffControllerListener);
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
                        Switch.adaptive(
                            value: _repeatBooking,
                            onChanged: (bool value) {
                              setState(() => _repeatBooking = value);
                              _bookingBoolController.text =
                                  _repeatBooking.toString();
                            }),
                        Stack(
                          children: [
                            if (_repeatBooking == true &&
                                _inputPickUpController.text.isNotEmpty &&
                                _inputDropOffController.text.isNotEmpty)
                              Positioned(
                                // top: 0,
                                // bottom: 0,
                                // left: 0,
                                // right: 0,
                                child: Center(
                                  child: filterChipsDays(),
                                ),
                              ),
                            if (_repeatBooking == true &&
                                _inputPickUpController.text.isNotEmpty &&
                                _inputDropOffController.text.isNotEmpty)
                              gettingDatesBasedOnDaysSelected(),
                            if (_repeatBooking == false &&
                                _inputPickUpController.text.isNotEmpty &&
                                _inputDropOffController.text.isNotEmpty)
                              SizedBox(
                                height: 150,
                                child: Column(
                                  children: [
                                    dateCupertinoField(),
                                    const SizedBox(
                                      height: 25,
                                    ),
                                    timeCupertinoField(),
                                    const SizedBox(
                                      height: 25,
                                    ),
                                  ],
                                ),
                              ),
                            if (applicationBloc.searchResults.isNotEmpty)
                              Container(
                                  height: 300.0,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
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
                        _monSelectedDates.toString();
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
                        _tuesSelectedDates.toString();
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
                        _wedSelectedDates.toString();
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
                        _thursSelectedDates.toString();
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
                        _friSelectedDates.toString();
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
                        _satSelectedDates.toString();
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
                        _sunSelectedDates.toString();
                  }

                  return Stack(
                    children: [
                      if (count > remaining)
                        Text(
                            "You are trying to book $absOverage more than it is available."),
                      if (someElement == "Mo")
                        Positioned(
                          // top: 70,
                          child: Center(
                            child: Text("$_monSelectedDates"),
                          ),
                        ),
                      if (someElement == "Tu")
                        Positioned(
                          child: Center(
                            child: Text("$_tuesSelectedDates"),
                          ),
                        ),
                      if (someElement == "We")
                        Positioned(
                          child: Center(
                            child: Text("$_wedSelectedDates"),
                          ),
                        ),
                      if (someElement == "Th")
                        Positioned(
                          child: Center(
                            child: Text("$_thursSelectedDates"),
                          ),
                        ),
                      if (someElement == "Fr")
                        Positioned(
                          child: Center(
                            child: Text("$_friSelectedDates"),
                          ),
                        ),
                      if (someElement == "Sa")
                        Positioned(
                          child: Center(
                            child: Text("$_satSelectedDates"),
                          ),
                        ),
                      if (someElement == "Su")
                        Positioned(
                          child: Center(
                            child: Text("$_sunSelectedDates"),
                          ),
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

  Row filterChipsDays() {
    _dateDropOffController.clear();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }

  tempAutoCompleteList(ApplicationBloc applicationBloc) {
    return SizedBox(
      child: Scrollbar(
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
      ),
    );
  }

  SizedBox timeCupertinoField() {
    return SizedBox(
      width: 275,
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


      // key: _scaffoldKey,
      // appBar: AppBar(
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back),
      //     onPressed: () {
      //       _ridesService.deleteRide(
      //         documentId: _ride?.documentId,
      //       );
      //       Navigator.of(
      //         context,
      //       ).pop(
      //         homeRoute,
      //       );
      //     },
      //   ),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0.0,
      //   automaticallyImplyLeading: false,
      // ),