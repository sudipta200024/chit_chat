import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/helper/time_format.dart';
import 'package:chit_chat/models/chat_user.dart';
import 'package:chit_chat/view/auth/login_screen.dart';
import 'package:chit_chat/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../models/chat_message_model.dart';

class UserProfileScreen extends StatefulWidget {
  final ChatUser user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.user.name),
          
        ),

        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: mq.height * 0.02, width: mq.width),
              _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(mq.width * .2),
                      child: Image.file(
                        File(_image!),
                        width: mq.width * .4,
                        height: mq.width * .4,
                        fit: BoxFit.cover,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(mq.width * .2),
                      // ← half of .5 below
                      child: CachedNetworkImage(
                        width: mq.width * .4,
                        height: mq.width * .4,
                        fit: BoxFit.cover,
                        imageUrl: widget.user.image,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            Icon(CupertinoIcons.person),
                      ),
                    ),

              SizedBox(height: mq.height * 0.03),

              Text(
                widget.user.email,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),

              SizedBox(height: mq.height * 0.02),

              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'About: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: widget.user.about,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: mq.height * 0.04),
              StreamBuilder(
                stream: Apis.getAllImageMessages(widget.user),
                builder: (context, snapshot) {
                  final data = snapshot.data?.docs;
                  final images = data?.map((e) => ChatMessageModel.fromJson(e.data())).where((e) => e.msg.startsWith('http'))
                      .toList() ?? [];

                  if (images.isEmpty) return SizedBox();

                  return SizedBox(
                    height: mq.height * 0.2,
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.85),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: images[index].msg,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.image_not_supported),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: mq.height * 0.2),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Joined: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: TimeFormat.getJoinedTime(
                        time: widget.user.createdAt,
                      ),
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: mq.height * 0.09),
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(mq.width * .05),
          topRight: Radius.circular(mq.width * .05),
        ),
      ),
      context: context,
      builder: (_) {
        return ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(
            vertical: mq.height * .02,
            horizontal: mq.width * .03,
          ),
          children: [
            Text(
              'Select Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: mq.height * .04),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: CircleBorder(),
                    fixedSize: Size(mq.width * .3, mq.width * .3),
                    alignment: Alignment.center,
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      logger.i(
                        'image path: ${image.path}--Mimetype: ${image.mimeType}',
                      );
                      setState(() {
                        _image = image.path;
                      });
                      //hide bottom sheet
                      Navigator.pop(context);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/images/icons/add_image.png'),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: CircleBorder(),
                    fixedSize: Size(mq.width * .3, mq.width * .3),
                    alignment: Alignment.center,
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      logger.i(
                        'image path: ${image.path}--Mimetype: ${image.mimeType}',
                      );
                      setState(() {
                        _image = image.path;
                      });
                      Navigator.pop(context);
                    }
                    //hide bottom sheet
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/images/icons/photo_camera.png'),
                  ),
                ),
              ],
            ),
            SizedBox(height: mq.height * .02),
          ],
        );
      },
    );
  }

  Future<void> _uploadImageAndUpdate() async {
    Dialogs.showProgressBar(context);
    final imageUrl = await Apis.updateProfilePicture(_image!);
    Navigator.pop(context);
    if (imageUrl != null) {
      await Apis.updateUserInfo();
      setState(() {
        _image = null;
      });
      Dialogs.showSnackBar(context, 'Profile Updated Successfully');
    } else {
      Dialogs.showSnackBar(
        context,
        'Failed to upload image. Please try again.',
      );
    }
  }
}
