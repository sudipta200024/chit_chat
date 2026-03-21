import 'package:chit_chat/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';


class Apis {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static User get user => auth.currentUser!;


//declaring list from firebase store
  static List<ChatUser> allUsers = [];

  //current user filtered from the list using query
  static ChatUser get currentAuthUser => allUsers.firstWhere((e) => e.id == user.uid);
  static void logCurrentUser(){
    logger.d('currentUser:$currentAuthUser');//checking if it works
  }

  static Future<bool> userExist() async {
    return (await firestore
        .collection('users')
        .doc(user.uid)
        .get()).exists;//Firestore  ◄─── fromJson() ───  Map  ◄─── get() ────  Firestore DB

  }

  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        name: user.displayName!,
        about: 'Hey there I am using Chit Chat',
        createdAt: time,
        id: user.uid,
        lastActive: time,
        isOnline: false,
        pushToken: '',
        email: user.email!.toString()
    );
    return await firestore.collection('users').doc(user.uid).set(chatUser.toJson());
  //Firestore  ──── toJson() ────►  Map  ──── set() ────►  Firestore DB
  }


}