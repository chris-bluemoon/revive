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
    required this.verified,
    required this.imagePath,
    required this.creationDate,
    required this.location,
    required this.bio,
    required this.followers,
    required this.following,
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
  String verified;
  String imagePath;
  String creationDate;
  String location;
  String bio;
  List<String> followers;
  List<String> following;

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
      'verified': verified,
      'imagePath': imagePath,
      'creationDate': creationDate,
      'location': location,
      'bio': bio,
      'followers': followers,
      'following': following,
    };
  }

  // character from firestore
  factory Renter.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
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
      verified: data['verified'],
      imagePath: data['imagePath'],
      creationDate: data['creationDate'],
      location: data['location'] ?? '',
      bio: data['bio'] ?? '',
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
    );

    return renter;
  }

  String get profilePicUrl {
    if (imagePath.isNotEmpty && (imagePath.startsWith('http://') || imagePath.startsWith('https://'))) {
      return imagePath;
    }
    return '';
  }
}
