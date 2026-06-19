import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/api/apis.dart';
import 'package:chit_chat/models/chat_message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import '../helper/time_format.dart';
import '../main.dart';
import '../models/chat_user.dart';

class MessageCard extends StatefulWidget {
  final ChatMessageModel chatMessageModel;
  final ChatUser chatUser;
  //hi

  const MessageCard({
    super.key,
    required this.chatMessageModel,
    required this.chatUser,
  });

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  void initState() {
    super.initState();
    if (widget.chatMessageModel.read.isEmpty) {
      Apis.updateReadMessageStatus(widget.chatMessageModel);
    }
  }
  Widget build(BuildContext context) {
    bool isMe = Apis.currentUser.uid == widget.chatMessageModel.fromId;
    //if message is from current id then show green and if not then its frnds msg(logic)
    return InkWell(
      onLongPress: () async{
        FocusScope.of(context).unfocus();//close keyboard
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _whiteMessage(),
    );
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
                  widget.chatMessageModel.type == Type.image
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              // ← tap to full screen
                              context,
                              MaterialPageRoute(
                                builder: (_) => Scaffold(
                                  backgroundColor: Colors.black,
                                  appBar: AppBar(
                                    backgroundColor: Colors.black,
                                    iconTheme: IconThemeData(
                                      color: Colors.white,
                                    ),
                                  ),
                                  body: Center(
                                    child: CachedNetworkImage(
                                      imageUrl: widget.chatMessageModel.msg,
                                      fit: BoxFit.contain, // ← full image
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: widget.chatMessageModel.msg,
                                width: mq.width * 0.35,
                                // ← reduced from 0.55 to 0.35
                                height: mq.width * 0.35,
                                // ← fixed height too
                                fit: BoxFit.cover,
                                placeholder: (context, url) => SizedBox(
                                  width: mq.width * 0.35,
                                  height: mq.width * 0.35,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.image_not_supported, size: 40),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          widget.chatMessageModel.msg,
                          style: TextStyle(color: Colors.black87, fontSize: 15),
                        ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        TimeFormat.getLastMessageTime(
                          context: context,
                          time: widget.chatMessageModel.sent,
                        ),
                        // message timestamp field
                        style: TextStyle(color: Colors.black45, fontSize: 11),
                      ),
                      SizedBox(width: 4),
                      widget.chatMessageModel.read.isNotEmpty
                          ? Icon(
                              Icons.done_all,
                              size: 16,
                              color: Color(0xFF53BDEB),
                            )
                          : Icon(Icons.done_all, size: 16, color: Colors.grey),
                      // blue ticks
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
    //update read while enters
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
                : null, //if no image then shows this icon
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
                  widget.chatMessageModel.type == Type.image
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              // ← tap to full screen
                              context,
                              MaterialPageRoute(
                                builder: (_) => Scaffold(
                                  backgroundColor: Colors.black,
                                  appBar: AppBar(
                                    backgroundColor: Colors.black,
                                    iconTheme: IconThemeData(
                                      color: Colors.white,
                                    ),
                                  ),
                                  body: Center(
                                    child: CachedNetworkImage(
                                      imageUrl: widget.chatMessageModel.msg,
                                      fit: BoxFit.contain, // ← full image
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: widget.chatMessageModel.msg,
                                width: mq.width * 0.35,
                                // ← reduced from 0.55 to 0.35
                                height: mq.width * 0.35,
                                // ← fixed height too
                                fit: BoxFit.cover,
                                placeholder: (context, url) => SizedBox(
                                  width: mq.width * 0.35,
                                  height: mq.width * 0.35,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.image_not_supported, size: 40),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          widget.chatMessageModel.msg,
                          style: TextStyle(color: Colors.black87, fontSize: 15),
                        ),
                  SizedBox(height: 4),
                  Text(
                    TimeFormat.getLastMessageTime(
                      context: context,
                      time: widget.chatMessageModel.sent,
                    ),
                    // Message timestamp field
                    style: TextStyle(color: Colors.black45, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(mq.width * .05),
          topRight: Radius.circular(mq.width * .05),
        ),
      ),
      context: context,
      builder: (sheetContext) {
        return ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(
            vertical: mq.height * .02,
            horizontal: mq.width * .03,
          ),
          children: [
            // Text(
            //   'Select Profile Picture',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            // ),
            SizedBox(height: mq.height * .04),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (isMe) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext); //closes model sheet

                      final TextEditingController editMsgController =
                          TextEditingController(
                            text: widget.chatMessageModel.msg,
                          );
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Text('Edit Message'),
                          content: TextField(
                            controller: editMsgController,
                            maxLines: null,
                            autofocus: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final newText = editMsgController.text.trim();
                                if (newText.isNotEmpty &&
                                    newText != widget.chatMessageModel.msg) {
                                  await Apis.updateMessage(
                                    widget.chatMessageModel,
                                    newText,
                                  );
                                  Navigator.pop(dialogContext);
                                }
                              },
                              child: Text('Update'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.edit),
                    label: Text('Edit'),
                  ),

                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Text('Delete Message'),
                          content: Text('Are you sure you want to delete this message?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext); // close confirm dialog only
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(dialogContext); // close confirm dialog
                                Navigator.pop(sheetContext);  // close bottom sheet

                                await Apis.deleteMessage(widget.chatMessageModel);

                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Message deleted!')),
                                );
                              },
                              child: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.delete),
                    label: Text('Delete'),
                  ),
                ],
                if (widget.chatMessageModel.type == Type.image)
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await Gal.requestAccess();

                        final response = await http.get(
                          Uri.parse(widget.chatMessageModel.msg),
                        );

                        if (response.statusCode != 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to download image!'),
                            ),
                          );
                          return;
                        }

                        await Gal.putImageBytes(response.bodyBytes);

                        Navigator.pop(sheetContext);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Image saved to gallery!')),
                        );
                      } catch (e) {
                        print('Error: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to save image!')),
                        );
                      }
                    },
                    icon: Icon(Icons.download), //download image
                    label: Text('Download'),
                  )
                else
                  (ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: widget.chatMessageModel.msg),
                      );
                      Navigator.pop(context); // close model sheet
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Message copied!')),
                      );
                    },
                    icon: Icon(Icons.copy),
                    label: Text('Copy'),
                  )),
              ],
            ),
            SizedBox(height: mq.height * .02),
            // Sent time
            ListTile(
              leading: Icon(Icons.remove_red_eye, color: Colors.blue),
              title: Text('Sent'),
              trailing: Text(
                TimeFormat.getLastMessageTime(
                  context: context,
                  time: widget.chatMessageModel.sent,
                ),
                style: TextStyle(color: Colors.black54),
              ),
            ),

            // Read time
            ListTile(
              leading: Icon(Icons.remove_red_eye, color: Colors.green),
              title: Text('Read'),
              trailing: Text(
                widget.chatMessageModel.read.isNotEmpty
                    ? TimeFormat.getLastMessageTime(
                        context: context,
                        time: widget.chatMessageModel.read,
                      )
                    : 'Not read yet',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        );
      },
    );
  }
}
