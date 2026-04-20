import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/api/apis.dart';
import 'package:chit_chat/helper/time_format.dart';
import 'package:chit_chat/main.dart';
import 'package:chit_chat/models/chat_message_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/chat_user.dart';
import '../view/auth/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser chatUser; //declaring chatUser model as its passing data

  const ChatUserCard({super.key, required this.chatUser});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  ChatMessageModel? _chatMessageModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: mq.width * 0.04,
        vertical: mq.height * 0.01,
      ),
      color: Colors.white60,
      elevation: 5,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                chatUser: widget.chatUser,
              ), //this is the selected user only with its data using the model
            ), //need widget as chatUser is outside the class
          );
        },
        child: StreamBuilder(
          stream: Apis.getLastMessage(widget.chatUser),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final _lastMsgList =
                data
                    ?.map((e) => ChatMessageModel.fromJson(e.data()))
                    .toList() ??
                [];
            if (_lastMsgList.isNotEmpty) {
              _chatMessageModel = _lastMsgList[0];
            }
            return ListTile(
              // leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .07),
                child: CachedNetworkImage(
                  width: mq.width * .14,
                  height: mq.height * .14,
                  fit: BoxFit.cover,
                  imageUrl: widget.chatUser.image,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      Icon(CupertinoIcons.person),
                ),
              ),

              title: Text(
                widget.chatUser.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                _chatMessageModel != null
                    ? _chatMessageModel!.msg
                    : //if lastMessageList empty then _chatMessageModel empty
                      widget
                          .chatUser
                          .about, //if lastMsg is empty then show about
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: _chatMessageModel == null
                  ? null
                  : _chatMessageModel!.read.isEmpty && Apis.currentUser.uid != _chatMessageModel!.fromId
              //logic
              // show green dot only if:
              // 1) message is unread (read is empty)
              // 2) we are not the sender (fromId is the other person)
              // same chatMessageModel, but currentUser.uid differs per device
              // so Joe sees no dot (he sent it), we see dot (we received it)
                  ? Container(
                      //new msg indicator
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    )
                  : Text(TimeFormat().getLastMessageTime(_chatMessageModel!.sent),style: TextStyle(
                color: Colors.black26,
                fontSize: 12,
              ),),
            );
          },
        ),
      ),
    );
  }
}
