import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/main.dart';
import 'package:chit_chat/widget/message_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../api/apis.dart';
import '../../models/chat_message_model.dart';
import '../../models/chat_user.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser chatUser;

  const ChatScreen({super.key, required this.chatUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessageModel> _msgList = [];
  final TextEditingController _messageController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // We control the back button
        backgroundColor: Colors.white38, // This removes the black status bar
        elevation: 1,
        flexibleSpace: SafeArea(
          // ← SafeArea ONLY here
          child: _appBar(),
        ),
      ),
      backgroundColor: Color(0xFFECE5DD),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: Apis.getAllMessages(widget.chatUser),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {//check connection state
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Center(child: CircularProgressIndicator());
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    logger.i(
                      'message: ${jsonEncode(data?.map((e) => e.data()).toList())}',
                    );
                    //now create a model for messageModel to put it in the msg list
                    final _msgList = data?.map((e) => ChatMessageModel.fromJson(e.data())).toList() ?? [];

                    if (_msgList.isNotEmpty) {
                      return ListView.builder(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.only(top: mq.height * 0.02),
                        itemCount: _msgList.length,
                        itemBuilder: (context, index) {
                          return MessageCard(
                            chatMessageModel: _msgList[index],//how many msg bubble
                            chatUser: widget.chatUser,//to see frnds profile icon
                          ); //two types of passing could have used same
                          // return Card(
                          //     child: ListTile()
                          //)
                          // return Text('message: ${_msgList[index].msg}');
                        },
                      );
                    } else {
                      return Center(
                        child: Text(
                          '👋 Wave to say Hi!!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                }
              },
            ),
          ),
          // Expanded(
          //   child: StreamBuilder(
          //     stream: null,
          //     builder: (context, snapshot) {
          //       switch (snapshot.connectionState) {
          //         //connection loading
          //         case ConnectionState.waiting:
          //         case ConnectionState.none:
          //           // return Center(child: CircularProgressIndicator());
          //
          //         //connection loaded
          //         case ConnectionState.active:
          //         case ConnectionState.done:
          //           // final data = snapshot.data?.docs; // final data = snapshot.data?.docs[0].data();
          //           // _dataList = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? []; //for loop inside the data mapping
          //           final _chatList = [];
          //           if (_chatList.isNotEmpty) {
          //             return ListView.builder(
          //               physics: BouncingScrollPhysics(),
          //               padding: EdgeInsets.only(top: mq.height * 0.02),
          //               itemCount: _chatList.length,
          //               itemBuilder: (context, index) {
          //                 return Text('message: ${_chatList[index]}');
          //               },
          //             );
          //           } else {
          //             return Center(
          //               child: Text(
          //                 'No Connection Found!!',
          //                 style: TextStyle(
          //                   fontSize: 18,
          //                   fontWeight: FontWeight.w500,
          //                 ),
          //               ),
          //             );
          //           }
          //       }
          //     },
          //   ),
          // ),
          _bottomChatInput(),
        ],
      ),
    );
  }

  Widget _bottomChatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: mq.width * 0.02,
        vertical: mq.height * 0.02,
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white70,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.emoji_emotions_outlined),
                  ), //emoji
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.image_outlined),
                  ), //gallery
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.camera_alt_outlined),
                  ), //camera
                ],
              ),
            ),
          ),
          IconButton(
            //send button
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                Apis.sendMessage(
                  widget.chatUser, //ChatUser(friends id) parameter pass
                  _messageController.text, //msg parameter pass
                );
                _messageController.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              shape: CircleBorder(),
            ),
            icon: Icon(Icons.send_outlined),
          ),
        ],
      ),
    );
  }

  Widget _appBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: kToolbarHeight,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          SizedBox(width: mq.width * 0.001),
          CircleAvatar(
            radius: mq.width * 0.05,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: widget.chatUser.image.isNotEmpty
                ? CachedNetworkImageProvider(widget.chatUser.image)
                : null,
            child: widget.chatUser.image.isEmpty
                ? const Icon(CupertinoIcons.person, size: 22)
                : null,
          ),
          SizedBox(width: mq.width * 0.02),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.chatUser.name,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: mq.height * 0.0001),
              Text(
                widget.chatUser.lastActive,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
