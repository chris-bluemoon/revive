import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:revivals/screens/messages/message_conversation_page.dart';

class InboxPage extends StatelessWidget {
  final String currentUserId; // Pass the current user's ID

  const InboxPage({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Inbox',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .where('participants', arrayContains: currentUserId)
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No messages'));
          }

          // Group messages by other participant to get the latest message per conversation
          final Map<String, QueryDocumentSnapshot> latestMessages = {};
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final participants = List<String>.from(data['participants'] ?? []);
            final otherUserId = participants.firstWhere(
              (id) => id != currentUserId,
              orElse: () => '',
            );
            if (otherUserId.isNotEmpty && !latestMessages.containsKey(otherUserId)) {
              latestMessages[otherUserId] = doc;
            }
          }

          final messagePreviews = latestMessages.entries.map((entry) {
            final doc = entry.value;
            final data = doc.data() as Map<String, dynamic>;
            final participants = List<String>.from(data['participants'] ?? []);
            final otherUserId = entry.key;
            return _MessagePreviewWithUserId(
              userId: otherUserId,
              latestMessage: data['text'] ?? '',
              time: data['time'] != null
                  ? (data['time'] as Timestamp).toDate().toLocal().toString().substring(0, 16)
                  : '',
            );
          }).toList();

          return ListView.separated(
            itemCount: messagePreviews.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final preview = messagePreviews[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('renter')
                    .doc(preview.userId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    // Don't show anything until the name is resolved
                    return const SizedBox.shrink();
                  }
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final displayName = userData['name'] ?? preview.userId;
                  final profilePic = userData['imagePath'] ?? '';
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profilePic.isNotEmpty
                          ? NetworkImage(profilePic)
                          : null,
                      backgroundColor: Colors.grey[300],
                      child: (profilePic.isEmpty)
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      preview.latestMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      preview.time,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MessageConversationPage(
                            currentUserId: currentUserId,
                            otherUserId: preview.userId,
                            otherUser: {
                              'name': displayName,
                              'profilePicUrl': profilePic,
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _MessagePreviewWithUserId {
  final String userId;
  final String latestMessage;
  final String time;

  _MessagePreviewWithUserId({
    required this.userId,
    required this.latestMessage,
    required this.time,
  });
}