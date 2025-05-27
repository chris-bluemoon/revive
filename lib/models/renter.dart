import 'package:cloud_firestore/cloud_firestore.dart';

class Renter {
  Renter({
    required this.id,
    required this.email,
    required this.name,
    required this.type,
    required this.size,
    required this.address,
    required this.countryCode,
    required this.phoneNum,
    required this.favourites,
    required this.fittings,
    required this.settings,
    required this.verified,
    required this.imagePath,
    required this.creationDate,
  });

  String id;
  String email;
  String name;
  String type;
  int size;
  String address;
  String countryCode;
  String phoneNum;
  List favourites;
  List fittings;
  List settings;
  String verified;
  String imagePath;
  String creationDate;

  // item to firestore (map)
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'type': type,
      'size': size,
      'address': address,
      'countryCode': countryCode,
      'phoneNum': phoneNum,
      'favourites': favourites,
      'fittings': fittings,
      'settings': settings,
      'verified': verified,
      'imagePath': imagePath,
      'creationDate': creationDate,
    };
  }

  // character from firestore
  factory Renter.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    // get data from snapshot
    final data = snapshot.data()!;
    // make character instance
    Renter renter = Renter(
      id: snapshot.id,
      email: data['email'],
      name: data['name'],
      type: data['type'] ?? 'USER',
      size: data['size'],
      address: data['address'],
      countryCode: data['countryCode'],
      phoneNum: data['phoneNum'],
      favourites: data['favourites'],
      fittings: data['fittings'],
      settings: data['settings'],
      verified: data['verified'],
      imagePath: data['imagePath'],
      creationDate: data['creationDate'],
    );

    return renter;
  }

  String get profilePicUrl {
    // Return a valid image URL if imagePath is a URL, otherwise return an empty string or a placeholder
    if (imagePath.isNotEmpty && (imagePath.startsWith('http://') || imagePath.startsWith('https://'))) {
      return imagePath;
    }
    // You can set a default placeholder image URL here if needed
    return '';
  }

  String get bio {
    // Return a bio if available in settings, otherwise return an empty string
    if (settings.isNotEmpty && settings[0] is Map && settings[0]['bio'] != null) {
      return settings[0]['bio'] as String;
    }
    return '';
  }
}
