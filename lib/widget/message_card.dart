import 'package:chit_chat/api/apis.dart';
import 'package:chit_chat/models/chat_message_model.dart';
import 'package:flutter/material.dart';

class MessageCard extends StatefulWidget {
  final ChatMessageModel chatMessageModel;

  const MessageCard({super.key, required this.chatMessageModel});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return Apis.currentUser.uid == widget.chatMessageModel.fromId //if message is from current id then show green and if not then its frnds msg(logic)
        ? _greenMessage()
        : _blackMessage();
  }

  Widget _greenMessage() {
    //my msg
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.only(),
      ),
      child: Text(
        'msg: ${widget.chatMessageModel.msg}',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _blackMessage() {
    //frnds msg
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(),
      ),
      child: Text(
        'msg: ${widget.chatMessageModel.msg}',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
