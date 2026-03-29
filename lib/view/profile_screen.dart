import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/models/chat_user.dart';
import 'package:chit_chat/view/auth/login_screen.dart';
import 'package:chit_chat/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required ChatUser user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey =
      GlobalKey<FormState>(); //ensures which state form fields are in

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          actions: [
            IconButton(
              onPressed: () async {
                Dialogs.showProgressBar(context);
                await Apis.auth.signOut();
                await GoogleSignIn().signOut();
                Navigator.pop(context); // dismiss progress bar
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false, //removes all the routes from the stack
                  //deletes login home and profile route
                );
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        // floatingActionButton: Padding(
        //   padding: EdgeInsets.only(bottom: 90, right: 5),
        //   child: FloatingActionButton.extended(
        //     icon: Icon(Icons.logout),
        //     label: Text('Logout'),
        //     onPressed: () async {
        //       Dialogs.showProgressBar(context);
        //       await FirebaseAuth.instance.signOut();
        //       await GoogleSignIn().signOut();
        //       Navigator.pop(context);
        //       Navigator.pushReplacement(
        //         context,
        //         MaterialPageRoute(builder: (_) => LoginScreen()),
        //       );
        //     },
        //   ),
        // ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: Column(
                children: [
                  SizedBox(height: mq.height * 0.03, width: mq.width),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(mq.width * .2),
                        // ← half of .5 below
                        child: CachedNetworkImage(
                          width: mq.width * .4,
                          height: mq.width * .4,
                          fit: BoxFit.cover,
                          imageUrl: Apis.me.image,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(CupertinoIcons.person),
                        ),
                      ),

                      Positioned(
                        bottom: 5,
                        right: -5,
                        child: MaterialButton(
                          elevation: 0,
                          onPressed: () {},
                          shape: CircleBorder(),
                          color: Colors.white,
                          child: Icon(Icons.edit, color: Colors.black),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: mq.height * 0.02),

                  Text(
                    Apis.me.email,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),

                  SizedBox(height: mq.height * 0.04),

                  TextFormField(
                    onSaved: (val) => Apis.me.name = val ?? '',
                    //saves the new name input inside the me model
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    initialValue: Apis.me.email,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(CupertinoIcons.person),
                      hintText: 'Ex. John Doe',
                      label: Text('Name'),
                    ),
                  ),
                  SizedBox(height: mq.height * 0.04),
                  TextFormField(
                    onSaved: (val) => Apis.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    initialValue: Apis.me.about,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(CupertinoIcons.info),
                      hintText: 'Ex. Hey there I am using Chit Chat',
                      label: Text('about'),
                    ),
                  ),
                  SizedBox(height: mq.height * 0.09),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        FocusScope.of(context).unfocus();
                        _formKey.currentState!.save();
                        Apis.updateUserInfo();
                        Dialogs.showSnackBar(
                          context,
                          'Profile Updated Successfully',
                        );
                      }
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
      ),
    );
  }
}
