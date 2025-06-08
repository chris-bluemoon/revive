import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id; // Unique review id
  final String reviewerId; // The user who wrote the review
  final String reviewedUserId; // The user being reviewed
  final String itemRenterId; // Link to ItemRenter
  final String itemId; // Link to Item
  final int rating; // 1 to 5 stars
  final String title; // Review title
  final String text; // Review text
  final DateTime date; // Date of review

  Review({
    required this.id,
    required this.reviewerId,
    required this.reviewedUserId,
    required this.itemRenterId,
    required this.itemId,
    required this.rating,
    required this.title,
    required this.text,
    required this.date,
  });

  factory Review.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options) {
    final data = snapshot.data()!;
    return Review(
      id: doc.id,
      reviewerId: data['reviewerId'],
      itemRenterId: data['itemRenterId'],
      itemId: data['itemId'],
      rating: data['rating'],
      title: data['title'],
      text: data['text'],
      date: (data['date'] is Timestamp)
          ? (data['date'] as Timestamp).toDate()
          : DateTime.parse(data['date']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reviewerId': reviewerId,
      'reviewedUserId': reviewedUserId,
      'itemRenterId': itemRenterId,
      'itemId': itemId,
      'rating': rating,
      'title': title,
      'text': text,
      'date': date,
    };
  }
}
