import 'package:http/http.dart' as http;
import 'package:uniqart/models/places/places.dart';
import 'dart:convert' as convert;
import 'package:uniqart/models/places/places_search.dart';

class PlacesService {
  final key = "AIzaSyCEz0XTTWUBzbc3d016ile4hW4CrRMSejg";

  Future<List<PlaceSearch>> getAutocomplete(String search) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=geocode|establishment&location=43.4723%2C-80.5449&radius=3000&strictbounds=true&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }

  Future<PickUpPlace> getPickUpPlace(String placeId) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResult = json['result'] as Map<String, dynamic>;
    return PickUpPlace.fromJson(jsonResult);
  }

  Future<DropOffPlace> getDropOffPlace(String placeId) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResult = json['result'] as Map<String, dynamic>;
    return DropOffPlace.fromJson(jsonResult);
  }
}
