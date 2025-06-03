import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/message.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/to_rent/send_message2.dart';
import 'package:revivals/shared/styled_text.dart';

class MyMessage extends StatefulWidget {
  const MyMessage(this.myMessage, {super.key});

  final Message myMessage;

  @override
  State<MyMessage> createState() => _MyMessageState();
}

class _MyMessageState extends State<MyMessage> {
  bool isDateSentToday = false;
  bool replyPressed = false;

  @override
  void initState() {
    super.initState();
  }

  setReplyPressedToFalse() {
    setState(() {
      replyPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    // Get all messages from your provider
    final allMessages = Provider.of<ItemStoreProvider>(context, listen: false).messages;

    // Filter messages linked to this message
    final linkedMessages = allMessages
        .where((msg) => msg.linkedId == widget.myMessage.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        title: StyledTitle(widget.myMessage.subject),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(width * 0.1, 0, width * 0.1, 0),
        child: Column(
          children: [
            Row(
              children: [
                const StyledBody('FROM: '),
                SizedBox(width: width * 0.05),
                StyledBody(widget.myMessage.author,
                    weight: FontWeight.normal),
              ],
            ),
            SizedBox(height: width * 0.02),
            Row(
              children: [
                const StyledBody('SENT: '),
                SizedBox(width: width * 0.05),
                StyledBody(
                  DateFormat('d MMM, y HH:mm')
                      .format(DateTime.parse(widget.myMessage.dateSent)),
                  weight: FontWeight.normal,
                ),
              ],
            ),
            Divider(
              indent: width * 0.02,
              endIndent: width * 0.02,
            ),
            StyledBody(
              widget.myMessage.body,
              weight: FontWeight.normal,
            ),
            Divider(
              indent: width * 0.02,
              endIndent: width * 0.02,
            ),
            // Show all linked messages
            if (linkedMessages.isNotEmpty)
              ...linkedMessages.map((msg) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  StyledBody('Reply from: ${msg.author}', weight: FontWeight.bold),
                  StyledBody(msg.body, weight: FontWeight.normal),
                  StyledBody(
                    DateFormat('d MMM, y HH:mm').format(DateTime.parse(msg.dateSent)),
                    weight: FontWeight.w300,
                  ),
                ],
              )),
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      widget.myMessage.status = 'deleted';
                      Provider.of<ItemStoreProvider>(context, listen: false)
                          .saveMessage(widget.myMessage);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.delete_outlined, size: width * 0.05)),
                SizedBox(width: width * 0.1),
                if (replyPressed != true)
                  IconButton(
                      onPressed: () {
                        setState(() {
                          replyPressed = true;
                        });
                      },
                      icon: Icon(Icons.reply_outlined, size: width * 0.05)),
                if (replyPressed)
                  Expanded(
                      child: SendMessage2(Provider.of<ItemStoreProvider>(context,
                                  listen: false).renter.name,
                          widget.myMessage.author,
                          're: ${widget.myMessage.subject}',
                          widget.myMessage.id,))
              ],
            ),
          ],
        ),
      ));
  }
}
