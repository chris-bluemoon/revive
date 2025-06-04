import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:revivals/models/fitting_renter.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/models/ledger.dart';
import 'package:revivals/models/message.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/models/review.dart';

class FirestoreService {
  static final refLedger = FirebaseFirestore.instance
      .collection('ledger')
      .withConverter(
          fromFirestore: Ledger.fromFirestore,
          toFirestore: (Ledger d, _) => d.toFirestore());

  static final refItem = FirebaseFirestore.instance
      .collection('item')
      .withConverter(
          fromFirestore: Item.fromFirestore,
          toFirestore: (Item d, _) => d.toFirestore());

  static final refRenter = FirebaseFirestore.instance
      .collection('renter')
      .withConverter(
          fromFirestore: Renter.fromFirestore,
          toFirestore: (Renter d, _) => d.toFirestore());

  static final refItemRenter = FirebaseFirestore.instance
      .collection('itemRenter')
      .withConverter(
          fromFirestore: ItemRenter.fromFirestore,
          toFirestore: (ItemRenter d, _) => d.toFirestore());

  static final refFittingRenter = FirebaseFirestore.instance
      .collection('fittingRenter')
      .withConverter(
          fromFirestore: FittingRenter.fromFirestore,
          toFirestore: (FittingRenter d, _) => d.toFirestore());

  static final refReview = FirebaseFirestore.instance
      .collection('review') // Collection for reviews
      .withConverter(
          fromFirestore: (snapshot, _) => Review.fromFirestore(snapshot),
          toFirestore: (Review r, _) => r.toFirestore());

  // add a new message
  static Future<void> addLedger(Ledger ledger) async {
    await refLedger.doc(ledger.id).set(ledger);
  }

  // add a new item
  static Future<void> addItem(Item item) async {
    await refItem.doc(item.id).set(item);
  }

  // get item once
  static Future<QuerySnapshot<Item>> getItemsOnce() {
    return refItem.get();
  }

  // add a new renter
  static Future<void> addRenter(Renter renter) async {
    await refRenter.doc(renter.id).set(renter);
  }

  // Update renter
  static Future<void> updateRenter(Renter renter) async {
    await refRenter.doc(renter.id).update({
      'address': renter.address,
      'phoneNum': renter.phoneNum,
      'favourites': renter.favourites,
      'verified': renter.verified,
      'imagePath': renter.imagePath,
      'location': renter.location,
      'bio': renter.bio,
      'followers': renter.followers,
      'following': renter.following,
    });
  }

  // get renters once
  static Future<QuerySnapshot<Renter>> getRentersOnce() {
    return refRenter.get();
  }

  // add a new renterItem
  static Future<void> addItemRenter(ItemRenter itemRenter) async {
    await refItemRenter.doc(itemRenter.id).set(itemRenter);
  }

  static Future<void> addFittingRenter(FittingRenter fittingRenter) async {
    await refFittingRenter.doc(fittingRenter.id).set(fittingRenter);
  }

  static Future<QuerySnapshot<Ledger>> getLedgersOnce() {
    return refLedger.get();
  }

  static Future<QuerySnapshot<ItemRenter>> getItemRentersOnce() {
    return refItemRenter.get();
  }

  static Future<QuerySnapshot<FittingRenter>> getFittingRentersOnce() {
    return refFittingRenter.get();
  }

  // Update itemrenter
  // Update itemrenter
  static Future<void> updateItemRenter(ItemRenter itemRenter) async {
    await refItemRenter.doc(itemRenter.id).update({
      'status': itemRenter.status,
    });
  }

  static Future<void> updateFittingRenter(FittingRenter fittingRenter) async {
    await refFittingRenter.doc(fittingRenter.id).update({
      'status': fittingRenter.status,
    });
  }

  static Future<void> updateItem(Item item) async {
    await refItem.doc(item.id).update({
      'status': item.status,
    });
  }

  static deleteLedgers() {
    FirebaseFirestore.instance.collection('ledger').get().then((snapshot) {
      for (DocumentSnapshot i in snapshot.docs) {
        i.reference.delete();
      }
    });
  }

  static deleteItems() {
    FirebaseFirestore.instance.collection('item').get().then((snapshot) {
      for (DocumentSnapshot i in snapshot.docs) {
        i.reference.delete();
      }
    });
  }

  static deleteItemRenters() {
    FirebaseFirestore.instance.collection('itemRenter').get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  static deleteFittingRenters() {
    FirebaseFirestore.instance
        .collection('fittingRenter')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  // Add a new review (expects a Map or your Review model's toMap())
  static Future<void> addReview(Review review) async {
    // Always use the review's id as the document id
    await refReview.doc(review.id).set(review);
  }

  // Optionally, get reviews for a renter
  static Future<QuerySnapshot<Review>> getReviewsForRenter(String renterId) {
    return refReview.where('renterId', isEqualTo: renterId).get();
  }
  
  // Optionally, get reviews for an itemRenter
  static Future<QuerySnapshot<Review>> getReviewsForItemRenter(String itemRenterId) {
    return refReview.where('itemRenterId', isEqualTo: itemRenterId).get();
  }

  // Get all reviews once
  static Future<QuerySnapshot<Review>> getReviewsOnce() {
    return refReview.get();
  }
}
