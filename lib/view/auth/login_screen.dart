import 'dart:developer';
import 'dart:io';

import 'package:chit_chat/helper/dialogs.dart';
import 'package:chit_chat/main.dart';
import 'package:chit_chat/view/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../api/apis.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimated = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(microseconds: 500), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  Future<void> _handleGoogleBtnClick() async {
    //start progress bar
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      //dismiss progress bar
      Navigator.pop(context);

      if (user != null) {
        log('\nUser:${user.user}');
        log('\nUserAdditionalInfo:${user.additionalUserInfo}');
        if (await Apis.userExist()){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        }else{
          await Apis.createUser();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        }
      }
    }
    );
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await Apis.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n _signInWithGoogle: $e');
      Dialogs.showSnackBar(context, 'Something Went Wrong (Check Internet)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          //welcome Message
          AnimatedPositioned(
            top: mq.height * 0.09,
            right: _isAnimated ? mq.width * .19 : -mq.width * 0.60,
            width: mq.width * 0.60,
            duration: Duration(seconds: 1),
            child: Text(
              "Welcome\nLets start chatting",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
            ),
          ),
          //APP_icon animation
          AnimatedPositioned(
            curve: Curves.easeIn,
            top: mq.height * 0.35,
            width: mq.width * 0.60,
            left: _isAnimated ? mq.width * 0.22 : -mq.width * 0.60,
            duration: Duration(seconds: 1),
            child: Image.asset('assets/images/icons/app_icon.png'),
          ),
          //login Button
          AnimatedPositioned(
            duration: Duration(seconds: 1),
            curve: Curves.bounceIn,
            bottom: _isAnimated ? mq.height * 0.1 : -mq.width * 0.75,
            width: mq.width * 0.75,
            left: mq.width * .13,
            child: ElevatedButton.icon(
              onPressed: () {
                _handleGoogleBtnClick();
              },
              icon: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 10,
                  top: 10,
                  bottom: 10,
                ),
                child: Image.asset(
                  'assets/images/icons/google.png',
                  width: mq.width * .09,
                ),
              ),
              label: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Login with ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: 'Google',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
