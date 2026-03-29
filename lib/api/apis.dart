import 'package:chit_chat/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';

class Apis {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static User get user => auth.currentUser!; //logged in user

  //declaring a static variable chatUser model
  static late ChatUser me;

  //get self info from firestore
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<bool> userExist() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
    //Firestore  <- fromJson() <-  Map  <- get() <-  Firestore DB
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
      email: user.email!.toString(),
    );
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
    //Firestore -> toJson() ->  Map  -> set() ->  Firestore DB
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser() {
    //could have used future builder but i want snapshot of data
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void>updateUserInfo() async {
    return await firestore.collection('users').doc(user.uid).update(
      {
        'name':me.name,
        'about':me.about,
      }
    );
  }
}

//firebase doc
// firestore/auth                          // ← start here always
//     .collection('users')             // ← which collection?
// .doc(user.uid)                   // ← which document? (optional)
//     .get()                           // ← what to do?
//     .set()                           // ← what to do?
//     .snapshots()                     // ← what to do?
//     .update()                        // ← what to do?
// .delete()                        // ← what to do?
