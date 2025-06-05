import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageConversationPage extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final dynamic otherUser; // Pass user object or fetch in this page
  const MessageConversationPage({
    required this.currentUserId,
    required this.otherUserId,
    this.otherUser,
    super.key,
  });

  @override
  State<MessageConversationPage> createState() => _MessageConversationPageState();
}

class _MessageConversationPageState extends State<MessageConversationPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final now = DateTime.now();

    final participants = [widget.currentUserId, widget.otherUserId];

    await FirebaseFirestore.instance.collection('messages').add({
      'text': text,
      'time': now,
      'isSent': true,
      'isRead': false,
      'participants': participants,
    });

    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final otherUser = widget.otherUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black, size: width * 0.08),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          otherUser != null ? (otherUser['name'] ?? widget.otherUserId) : widget.otherUserId,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        actions: [
          if (otherUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: CircleAvatar(
                radius: width * 0.06,
                backgroundColor: Colors.grey[300],
                backgroundImage: (otherUser['profilePicUrl'] != null && otherUser['profilePicUrl'].isNotEmpty)
                    ? NetworkImage(otherUser['profilePicUrl'])
                    : null,
                child: (otherUser['profilePicUrl'] == null || otherUser['profilePicUrl'].isEmpty)
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
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .where('participants', arrayContains: widget.currentUserId)
                    .orderBy('time', descending: true) // reverse order
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Filter only messages between these two users
                  final docs = snapshot.data!.docs.where((doc) {
                    final participants = List<String>.from(doc['participants'] ?? []);
                    return participants.contains(widget.otherUserId) && participants.contains(widget.currentUserId);
                  }).toList();

                  return ListView.builder(
                    reverse: true, // puts messages at the bottom and scrolls up
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                data['text'] ?? '',
                                style: const TextStyle(color: Colors.black, fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['time'] != null
                                  ? DateFormat('HH:mm').format((data['time'] as Timestamp).toDate())
                                  : '',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
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