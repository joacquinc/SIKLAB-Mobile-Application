class Item {
  final String addressRep;
  final String timeStamp;
  final String longitudeRep;
  final String latitudeRep;

  Item({required this.addressRep, required this.timeStamp, required this.longitudeRep, required this.latitudeRep});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      addressRep: json['addressRep'] as String,
      timeStamp: json['timeStamp'] as String,
      longitudeRep: json['longitudeRep'] as String,
      latitudeRep: json['latitudeRep'] as String,
    );
  }
}
