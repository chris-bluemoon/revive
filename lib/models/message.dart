import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String text;
  final DateTime time;
  final List<String> participants; // List of user IDs in the conversation
  final bool isSent; // true if sent by current user, false if received
  final bool isRead; // true if the message has been read

  Message({
    required this.text,
    required this.time,
    required this.participants,
    this.isSent = true,
    this.isRead = false,
  });

  // Firestore: fromFirestore (same format as review.dart)
  factory Message.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Message(
      text: data['text'] ?? '',
      time: (data['time'] as Timestamp).toDate(),
      participants: List<String>.from(data['participants'] ?? []),
      isSent: data['isSent'] ?? true,
      isRead: data['isRead'] ?? false,
    );
  }

  // Firestore: toFirestore
  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'time': time,
      'participants': participants,
      'isSent': isSent,
      'isRead': isRead,
    };
  }
}