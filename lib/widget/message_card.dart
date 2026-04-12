import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/api/apis.dart';
import 'package:chit_chat/models/chat_message_model.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/chat_user.dart';

class MessageCard extends StatefulWidget {
  final ChatMessageModel chatMessageModel;
  final ChatUser chatUser;


  const MessageCard({super.key, required this.chatMessageModel, required this.chatUser});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return Apis.currentUser.uid == widget.chatMessageModel.fromId //if message is from current id then show green and if not then its frnds msg(logic)
        ? _greenMessage()
        : _whiteMessage();
  }

  Widget _greenMessage() {
    // my msg
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: mq.width * 0.75),
              padding: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04,
                vertical: mq.height * 0.01,
              ),
              margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.02,
                vertical: mq.height * 0.005,
              ),
              decoration: BoxDecoration(
                color: Color(0xFFDCF8C6), // WhatsApp theme color green
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4), // pointy tail side
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.chatMessageModel.msg,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.chatMessageModel.sent, // message timestamp field
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 11,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.done_all, size: 16, color: Color(0xFF53BDEB)), // blue ticks
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _whiteMessage() {
    // friend's msg
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(left: mq.width * 0.02, bottom: 2),
          child: CircleAvatar(
            radius: 14,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: widget.chatUser.image.isNotEmpty
                ? CachedNetworkImageProvider(widget.chatUser.image)
                : null,
            child: widget.chatUser.image.isEmpty
                ? Icon(Icons.person, size: 16, color: Colors.grey)
                : null,//if no image then shows this icon
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: mq.width * 0.75),
              padding: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04,
                vertical: mq.height * 0.01,
              ),
              margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.02,
                vertical: mq.height * 0.005,
              ),
              decoration: BoxDecoration(
                color: Colors.white, // WhatsApp received bubble white
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4), // pointy tail side
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chatMessageModel.msg,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.chatMessageModel.sent, // Message timestamp field
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
