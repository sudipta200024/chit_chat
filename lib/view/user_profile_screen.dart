import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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
          actions: [
            IconButton(
              onPressed: () async {
                Dialogs.showProgressBar(context);
                await Apis.updateActiveStatus(false);//update inactive
                await Apis.auth.signOut();//signout from firebase
                await GoogleSignIn().signOut();
                Navigator.pop(context); // dismiss progress bar
                // Apis.auth = FirebaseAuth.instance; //if Apis.auth= null uncomment
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false, //removes all the routes from the stack
                  //deletes login home and profile route
                );
              },
              icon: Icon(Icons.logout,color: Colors.deepOrangeAccent),
            ),
          ],
        ),

        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: Column(
              children: [
                SizedBox(height: mq.height * 0.02),

                _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              mq.width * .2,
                            ),
                            // ← half of .5 below
                            child: Image.file(
                              File(_image!),
                              width: mq.width * .4,
                              height: mq.width * .4,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(
                              mq.width * .2,
                            ),
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


                SizedBox(height: mq.height * 0.02),

                Text(
                  widget.user.email,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),

                SizedBox(height: mq.height * 0.04),

                SizedBox(height: mq.height * 0.04),
                SizedBox(height: mq.height * 0.09),
                ElevatedButton.icon(
                  onPressed: () {

                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 6,
                    backgroundColor: Colors.blue,
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(
                      horizontal: mq.width * .3,
                      vertical: mq.height * .01,
                    ),
                  ),
                  icon: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(Icons.edit, color: Colors.white, size: 20),
                  ),
                  label: Text(
                    'Update',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
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
                      source: ImageSource.gallery,imageQuality: 80
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
                      source: ImageSource.camera,imageQuality: 80
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
