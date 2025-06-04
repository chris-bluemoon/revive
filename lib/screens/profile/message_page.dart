import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  final dynamic user;
  final dynamic item;
  const MessagePage({required this.user, required this.item, super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final item = widget.item;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black, size: width * 0.08),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.user.name,
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
              backgroundImage: (widget.user.profilePicUrl != null && widget.user.profilePicUrl.isNotEmpty)
                  ? NetworkImage(widget.user.profilePicUrl)
                  : null,
              child: (widget.user.profilePicUrl == null || widget.user.profilePicUrl.isEmpty)
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
            if (item != null)
              Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dress image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (item.imageId != null && item.imageId.isNotEmpty)
                          ? (item.imageId[0] is String &&
                                  (item.imageId[0].startsWith('http://') ||
                                      item.imageId[0].startsWith('https://')))
                              ? Image.network(
                                  item.imageId[0],
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                )
                              : (item.imageId[0] is Map &&
                                      item.imageId[0]['url'] != null &&
                                      (item.imageId[0]['url'] as String).startsWith('http'))
                                  ? Image.network(
                                      item.imageId[0]['url'],
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 48,
                                      height: 48,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image, color: Colors.white),
                                    )
                          : Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, color: Colors.white),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.type}  |  Size: ${item.size}',
                            style: TextStyle(color: Colors.grey[700] ?? Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                    onPressed: () {
                      // Implement send logic here
                      FocusScope.of(context).unfocus();
                      _controller.clear();
                    },
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