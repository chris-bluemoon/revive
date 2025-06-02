import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  Item({
    required this.id,
    required this.owner,
    required this.type,
    required this.bookingType,
    required this.occasion,
    required this.dateAdded,
    required this.style,
    required this.name,
    required this.brand,
    required this.colour,
    required this.size,
    required this.rentPriceDaily,
    required this.rentPriceWeekly,
    required this.rentPriceMonthly,
    required this.buyPrice,
    required this.rrp,
    required this.description,
    required this.longDescription,
    required this.imageId,
    required this.status,
  });

  String id;
  String owner;
  String type;
  String bookingType;
  List occasion;
  String dateAdded;
  String style;
  String name;
  String brand;
  List colour;
  String size; // Now a String
  int rentPriceDaily;
  int rentPriceWeekly;
  int rentPriceMonthly;
  int buyPrice;
  int rrp;
  String description;
  String longDescription;
  List imageId;
  String status;

  Map<String, dynamic> toFirestore() {
    return {
      'owner': owner,
      'type': type,
      'bookingType': bookingType,
      'occasion': occasion,
      'dateAdded': dateAdded,
      'style': style,
      'name': name,
      'brand': brand,
      'colour': colour,
      'size': size,
      'rentPriceDaily': rentPriceDaily,
      'rentPriceWeekly': rentPriceWeekly,
      'rentPriceMonthly': rentPriceMonthly,
      'buyPrice': buyPrice,
      'rrp': rrp,
      'description': description,
      'longDescription': longDescription,
      'imageId': imageId,
      'status': status,
    };
  }

  factory Item.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    Item item = Item(
      id: snapshot.id,
      owner: data['owner'],
      type: data['type'],
      bookingType: data['bookingType'],
      dateAdded: data['dateAdded'],
      occasion: data['occasion'],
      style: data['style'],
      name: data['name'],
      brand: data['brand'],
      colour: data['colour'],
      size: data['size'], // Now expects a String
      rentPriceDaily: data['rentPriceDaily'],
      rentPriceWeekly: data['rentPriceWeekly'] ?? 0,
      rentPriceMonthly: data['rentPriceMonthly'] ?? 0,
      buyPrice: data['buyPrice'],
      rrp: data['rrp'],
      description: data['description'],
      longDescription: data['longDescription'],
      imageId: data['imageId'],
      status: data['status'],
    );
    return item;
  }
}
