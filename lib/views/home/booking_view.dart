import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:test/consants/routes.dart';
import 'package:test/services/auth/auth_service.dart';
import 'package:test/services/cloud/rides/cloud_rides.dart';
import 'package:test/services/cloud/rides/firebase_cloud_storage_rides.dart';
import 'package:test/services/place/bloc/application_bloc.dart';

class BookingView extends StatefulWidget {
  const BookingView({super.key});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  CloudRide? _ride;

  late DateTime date = DateTime.now().add(const Duration(days: 1));
  late DateTime time = DateTime.now();
  late DateTime datetime = DateTime.now();
  late final currentDate = DateFormat.MMMEd().format(datetime);
  late final currentTime = DateFormat.jm().format(datetime);
  late StreamSubscription locationPickUpSubscription;
  late StreamSubscription locationDropOffSubscription;
  late final FirebaseRidesCloudStorage _ridesService;
  late final TextEditingController _pickUpController;
  late final TextEditingController _inputPickUpController;
  late final TextEditingController _dropOffController;
  late final TextEditingController _inputDropOffController;
  late final TextEditingController _timePickUpController;
  late final TextEditingController _timeDropOffController;
  late final TextEditingController _dateDropOffController;

  late Future<CloudRide> bookingRequest;
  late final _formKey = GlobalKey<FormState>();
  late FocusNode pickupNode;
  late FocusNode dropoffNode;

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

    pickupNode = FocusNode();
    dropoffNode = FocusNode();
    bookingRequest = createABookingRequest(context);
  }

  void _pickUpDropOffControllerListener() async {
    final ride = _ride;
    if (ride == null) {
      return;
    }

    final pickUp = _pickUpController.text;
    final dropOff = _dropOffController.text;
    final pickUpTimeApprox = _timePickUpController.text;
    final dropOffTime = _timeDropOffController.text;
    final dropOffDate = _dateDropOffController.text;

    await _ridesService.updateRide(
      documentId: ride.documentId,
      locationPickup: pickUp,
      locationDropOff: dropOff,
      timePickUp: "$pickUpTimeApprox (approx). Will confirm shortly.",
      timeDropOff: dropOffTime,
      dateDropOff: dropOffDate,
      cancellationStatus: false,
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
                        Stack(
                          children: [
                            SizedBox(
                              height: 300,
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


// TextFormField(
//                       controller: _password,
//                       enableSuggestions: false,
//                       obscureText: !_passwordVisible,
//                       autocorrect: false,
//                       keyboardType: TextInputType.visiblePassword,
//                       style:
//                           const TextStyle(fontSize: 14, color: uniqartOnSurface
//                               // color: Colors.black54,
//                               ),
//                       decoration: InputDecoration(
//                         // helperText: "min 8 characters long",
//                         focusColor: CupertinoColors.activeBlue,
//                         contentPadding: const EdgeInsets.all(0),
//                         prefixIcon: const Icon(Icons.password),
//                         label: const Text("Password"),
//                         hintText: "enter your password",
//                         filled: true,
//                         fillColor: CupertinoColors.lightBackgroundGray,
//                         border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(7),
//                             borderSide: BorderSide.none),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _passwordVisible
//                                 ? CupertinoIcons.eye_fill
//                                 : CupertinoIcons.eye_slash_fill,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _passwordVisible = !_passwordVisible;
//                             });
//                           },
//                         ),
//                       ),
//                     ),

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