class PickUpPlace {
  final String name;
  final String address;

  PickUpPlace({
    required this.name,
    required this.address,
  });

  factory PickUpPlace.fromJson(Map<String, dynamic> json) {
    return PickUpPlace(
      name: json['name'],
      address: json["formatted_address"],
    );
  }
}

class DropOffPlace {
  final String name;
  final String address;

  DropOffPlace({required this.name, required this.address});

  factory DropOffPlace.fromJson(Map<String, dynamic> json) {
    return DropOffPlace(
      name: json['name'],
      address: json["formatted_address"],
    );
  }
}
