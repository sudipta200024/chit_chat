import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/chat_user.dart';
import '../view/auth/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser chatUser;//declaring chatUser model as its a passing data

  const ChatUserCard({super.key, required this.chatUser});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {


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
            MaterialPageRoute(builder: (_) => ChatScreen(chatUser: widget.chatUser,)),//need widget as chatUser is outside the class
          );
        },
        child: ListTile(
          // leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * .07),
            child: CachedNetworkImage(
              width: mq.width * .14,
              height: mq.height * .14,
              fit: BoxFit.cover,
              imageUrl: widget.chatUser.image,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(CupertinoIcons.person),
            ),
          ),

          title: Text(
            widget.chatUser.name,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            widget.chatUser.about,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              color: widget.chatUser.isOnline ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
