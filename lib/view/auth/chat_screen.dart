import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/helper/time_format.dart';
import 'package:chit_chat/main.dart';
import 'package:chit_chat/view/user_profile_screen.dart';
import 'package:chit_chat/widget/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../models/chat_message_model.dart';
import '../../models/chat_user.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser chatUser;

  const ChatScreen({super.key, required this.chatUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<String> _selectedImages = []; // holds picked image path
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessageModel> _msgList = [];
  final TextEditingController _textEditingController = TextEditingController();
  bool _showEmoji = false;
  bool _isUploading = false;
  bool _initialScrollDone = false;

  @override
  void dispose() {
    _scrollController.dispose(); // ← dispose scroll controller
    _textEditingController.dispose(); // ← dispose text controller
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      // ← wait for list to update
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: false, // denied auto back button
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
          } else {
            Navigator.pop(context);
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            // We control the back button
            backgroundColor: Colors.white38,
            // This removes the black status bar
            elevation: 1,
            flexibleSpace: SafeArea(
              // ← SafeArea ONLY here
              child: _appBar(),
            ),
          ),
          backgroundColor: Color(0xFFECE5DD),

          body: Column(
            children: [
              _chatInput(),
              _bottomChatInput(),

              // Use with EmojiPicker if emoji press _showEmoji = true
              if (_showEmoji)
                SizedBox(
                  height: mq.height * .35,
                  child: EmojiPicker(
                    textEditingController: _textEditingController,
                    // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                    config: Config(
                      height: 256,
                      emojiViewConfig: EmojiViewConfig(
                        columns: 7,
                        emojiSizeMax:
                            28 *
                            (foundation.defaultTargetPlatform ==
                                    TargetPlatform.iOS
                                ? 1.20
                                : 1.0),
                      ),
                      bottomActionBarConfig: BottomActionBarConfig(
                        enabled: false,
                      ),
                      categoryViewConfig: CategoryViewConfig(
                        extraTab: CategoryExtraTab.BACKSPACE,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _chatInput() {
    return Expanded(
      child: StreamBuilder(
        stream: Apis.getAllMessages(widget.chatUser),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot.data?.docs;
              final _msgList =
                  data
                      ?.map((e) => ChatMessageModel.fromJson(e.data()))
                      .toList() ??
                  [];

              if (_msgList.isNotEmpty) {
                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.only(top: mq.height * 0.02),
                  itemCount: _msgList.length,
                  itemBuilder: (context, index) {
                    return MessageCard(
                      chatMessageModel: _msgList[index],
                      chatUser: widget.chatUser,
                    );
                  },
                );
              } else {
                return Center(
                  child: Text(
                    '👋 Wave to say Hi!!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                );
              }
          }
        },
      ),
    );
  }

  Widget _bottomChatInput() {
    return Padding(
      padding: EdgeInsets.only(
        left: mq.width * 0.02,
        right: mq.width * 0.02,
        top: mq.height * 0.01,
        bottom:
            mq.height * 0.01 +
            MediaQuery.of(context).padding.bottom, // ← adds safe area padding
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
                    onPressed: () {
                      setState(() {
                        FocusScope.of(context).unfocus();
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: Icon(Icons.emoji_emotions_outlined),
                  ), //emoji
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedImages.isNotEmpty)
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(_selectedImages[index]),
                                          height: 80,
                                          width: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: GestureDetector(
                                        onTap: () => setState(
                                          () => _selectedImages.removeAt(index),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        TextField(
                          onTap: () {
                            if (_showEmoji) {
                              setState(() => _showEmoji = !_showEmoji);
                            }
                          },
                          controller: _textEditingController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Type a message',
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final List<XFile> images = await picker.pickMultiImage(
                        imageQuality: 70,
                      );
                      if (images.isNotEmpty) {
                        setState(
                          () => _selectedImages.addAll(
                            images
                                .map((e) => e.path)
                                .toList(), // ← adds to existing list
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.image_outlined),
                  ), //gallery
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 70,
                      );
                      if (image != null) {
                        setState(
                          () => _selectedImages.add(image.path),
                        ); // ← just store
                      }
                    },
                    icon: Icon(Icons.camera_alt_outlined),
                  ), //camera
                ],
              ),
            ),
          ),
          // Replace the send IconButton with this
          _isUploading
              ? Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.green,
                    ),
                  ),
                )
              : IconButton(
                  onPressed: () async {
                    if (_selectedImages.isNotEmpty) {
                      setState(
                        () => _isUploading = true,
                      ); // show circle spinner in button
                      for (String imagePath in _selectedImages) {
                        await Apis.sendChatImage(widget.chatUser, imagePath);
                      }
                      setState(() {
                        _isUploading = false; //  hide spinner
                        _selectedImages = []; //  clear images
                      });
                      _scrollToBottom();
                    } else if (_textEditingController.text.isNotEmpty) {
                      Apis.sendMessage(
                        widget.chatUser,
                        _textEditingController.text,
                      );
                      _textEditingController.clear();
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
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (_)=>UserProfileScreen(user: widget.chatUser)));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: kToolbarHeight,
        child: StreamBuilder(
          stream: Apis.getUserInfo(widget.chatUser),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                []; //converted from json to dart to handle null safety
            return Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                SizedBox(width: mq.width * 0.001),
                CircleAvatar(
                  radius: mq.width * 0.05,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      (list.isNotEmpty ? list[0].image : widget.chatUser.image)
                          .isNotEmpty
                      ? CachedNetworkImageProvider(
                          list.isNotEmpty ? list[0].image : widget.chatUser.image,
                        )
                      : null,
                  child:
                      (list.isNotEmpty ? list[0].image : widget.chatUser.image)
                          .isEmpty
                      ? const Icon(CupertinoIcons.person, size: 22)
                      : null,
                ),
                SizedBox(width: mq.width * 0.02),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.isNotEmpty ? list[0].name : widget.chatUser.name,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: mq.height * 0.0001),
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                                ? 'Online'
                                : TimeFormat.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                          : TimeFormat.getLastActiveTime(context: context, lastActive: widget.chatUser.lastActive),//from_time format
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
