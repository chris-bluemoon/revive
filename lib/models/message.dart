class Message {
  final String text;
  final DateTime time;
  final String senderId;
  final String receiverId;
  final bool isSent; // true if sent by current user, false if received

  Message({
    required this.text,
    required this.time,
    required this.senderId,
    required this.receiverId,
    this.isSent = true,
  });
}