import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InboxPage extends StatefulWidget {
  // You may want to pass sender, receiver, and messages as arguments in real use
  final dynamic sender; // The user who sent the message
  final dynamic currentUser; // The logged-in user
  final List<dynamic> messages; // List of message objects

  const InboxPage({
    this.sender,
    this.currentUser,
    this.messages = const [],
    super.key,
  });

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final TextEditingController _controller = TextEditingController();
  final List<_ReceivedMessage> _messages = [
    // Example messages; replace with your actual message model and data
    _ReceivedMessage(
      text: "Hi! Is this dress available?",
      time: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    _ReceivedMessage(
      text: "Yes, it is! Let me know if you have any questions.",
      time: DateTime.now().subtract(const Duration(minutes: 7)),
      isMe: true,
    ),
    _ReceivedMessage(
      text: "Great! Can I rent it for next weekend?",
      time: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ReceivedMessage(
        text: text,
        time: DateTime.now(),
        isMe: true,
      ));
      _controller.clear();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final sender = widget.sender ?? {'name': 'Sender Name', 'profilePicUrl': ''};
    final currentUser = widget.currentUser ?? {'profilePicUrl': ''};

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black, size: width * 0.08),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          sender['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: width * 0.06,
              backgroundColor: Colors.grey[300],
              backgroundImage: (currentUser['profilePicUrl'] != null && currentUser['profilePicUrl'].isNotEmpty)
                  ? NetworkImage(currentUser['profilePicUrl'])
                  : null,
              child: (currentUser['profilePicUrl'] == null || currentUser['profilePicUrl'].isEmpty)
                  ? Icon(Icons.person, size: width * 0.06, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: const [
                  Text(
                    "All in-app rentals are monitored and are guaranteed on a case-by-case basis",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 18),
                  Text(
                    "All pricing is final. Negotiation is not allowed.",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 18),
                  Text(
                    "Revive will never ask you to verify or make payments outside of the app.",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Show messages
            if (_messages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Column(
                  children: _messages.map((msg) {
                    return Align(
                      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: msg.isMe ? Colors.black : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: msg.isMe ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('HH:mm').format(msg.time),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            // Message input row
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_upward, color: Colors.green, size: 32),
                    onPressed: _sendMessage,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type your message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceivedMessage {
  final String text;
  final DateTime time;
  final bool isMe;
  _ReceivedMessage({required this.text, required this.time, this.isMe = false});
}