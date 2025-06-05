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
}