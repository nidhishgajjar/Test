import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uniqart/models/places/places.dart';
import 'package:uniqart/models/places/places_search.dart';
import 'package:uniqart/services/place/places_service.dart';

class ApplicationBloc with ChangeNotifier {
  final placesService = PlacesService();

  //Variables

  List<PlaceSearch> searchResults;
  // PickUpPlace selectedLocationStatic;
  // List<PickUpPlace> placeResults;
  StreamController<PickUpPlace> selectedPickupLocation =
      StreamController<PickUpPlace>.broadcast();

  StreamController<DropOffPlace> selectedDropOffLocation =
      StreamController<DropOffPlace>.broadcast();

  ApplicationBloc() : searchResults = [];

  searchPickUpPlaces(String searchTerm) async {
    searchResults = await placesService.getAutocomplete(searchTerm);
    notifyListeners();
  }

  searchDropOffPlaces(String searchTerm) async {
    searchResults = await placesService.getAutocomplete(searchTerm);
    notifyListeners();
  }

  setSelectedPickUpLocation(String placeId) async {
    selectedPickupLocation.add(await placesService.getPickUpPlace(placeId));
    notifyListeners();
  }

  setSelectedDropOffLocation(String placeId) async {
    selectedDropOffLocation.add(await placesService.getDropOffPlace(placeId));
    notifyListeners();
  }

  clearSelectedPickupLocation() {
    searchResults.clear();
    notifyListeners();
  }

  clearSelectedDropOffLocation() {
    searchResults.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    selectedPickupLocation.close();
    selectedDropOffLocation.close();
    super.dispose();
  }
}
