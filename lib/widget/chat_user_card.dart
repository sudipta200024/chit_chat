import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/chat_user.dart';

class ChatUserCard extends StatefulWidget {

  ChatUser user;

  ChatUserCard({super.key , required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width*0.04, vertical: mq.height*0.01),
      color: Colors.white60,
      elevation: 5,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: ListTile(
          // leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height*.07),
            child: CachedNetworkImage(
              width: mq.width*.14,
              height: mq.height*.14,
              imageUrl: widget.user.image,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(CupertinoIcons.person),
            ),
          ),
          
          title: Text(
            widget.user.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            )
          ),
          subtitle: Text(
            widget.user.about,maxLines: 1,overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              color: widget.user.isOnline ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            )
          ),
        ),
      ),
    );
  }
}
