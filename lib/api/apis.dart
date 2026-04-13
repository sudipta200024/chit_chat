import 'package:chit_chat/models/chat_message_model.dart';
import 'package:chit_chat/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';

class Apis {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //cloudinary access
  static final CloudinaryPublic cloudinary = CloudinaryPublic(
    'dd4kuty1f',
    'chitchat_images',
    cache: false,
  );

  static User get currentUser => auth.currentUser!; //logged in user

  //declaring a static variable chatUser model
  static late ChatUser me;

  //get self info from firestore
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(currentUser.uid).get().then((
      user,
    ) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<bool> userExist() async {
    return (await firestore.collection('users').doc(currentUser.uid).get())
        .exists;
    //Firestore  <- fromJson() <-  Map  <- get() <-  Firestore DB
  }

  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      image: currentUser.photoURL.toString(),
      name: currentUser.displayName!,
      about: 'Hey there I am using Chit Chat',
      createdAt: time,
      id: currentUser.uid,
      lastActive: time,
      isOnline: false,
      pushToken: '',
      email: currentUser.email!.toString(),
    );
    return await firestore
        .collection('users')
        .doc(currentUser.uid)
        .set(chatUser.toJson());
    //Firestore -> toJson() ->  Map  -> set() ->  Firestore DB
  }

  ///get all the users
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser() {
    //could have used future builder but i want snapshot of data
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: currentUser.uid)
        .snapshots();
  }

  static Future<void> updateUserInfo() async {
    return await firestore.collection('users').doc(currentUser.uid).update({
      'name': me.name, //saved info from textfield inside ChatUser model
      'about': me.about,
    });
  }

  //update profile picture using cloudinary
  static Future<String?> updateProfilePicture(String imagePath) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        //this is going to cloudinary
        CloudinaryFile.fromFile(
          imagePath, //imagePath = _image(from Xfile gallery or camera)step 1
          resourceType: CloudinaryResourceType.Image,
          folder: 'profile_pictures',
        ),
      );
      String imageUrl = response.secureUrl; //this is coming from cloudinary
      //update image url inside firestore(step 2)
      await firestore.collection('users').doc(currentUser.uid).update({
        'image': imageUrl,
        //saving url from cloudinary to firebaseStore(shows the image of the url not direct picture)
      });
      me.image =
          imageUrl; //saving the url inside ChatUser model so ChatUser model new image value 'image'='imageUrl' instantly updated
      logger.i('Image url: $imageUrl');
      return imageUrl;
    } catch (e) {
      logger.e('Cloudinary error: $e');
    }
    return null;
  }


                                            //apis for sending and receiving messages

  //chats(collection)->conversationID(doc)->messages(collection)->message(doc)

  static String getConversationID(String id) {
    //gets the id that will be passed from getAllMessage
    //always creates unique and same id for both at same time cause it sorts the id
    if (currentUser.uid.compareTo(id) < 0) {
      //if current id is smaller than userId (id,passing parameter of chatUser id)then currentuid_userID
      return '${currentUser.uid}_$id';
    } else {
      return '${id}_${currentUser.uid}'; //if current id is bigger than userId (id,passing parameter of chatUser id)then userID_currentuid

      // You open chat:    compareTo() → "AAA_BBB" ✅
      // userId or Friend opens chat: compareTo() → "AAA_BBB" ✅ same!
    }
  }

  //get all messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser chatUser,) {
    //passing the parameter of chatUser id cause current id wants to sent to chatUser
    //gets the id that will be passed from messageCard
    return firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages')
        .snapshots();
  }
//send message logic
  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    try {
      final time = DateTime.now().millisecondsSinceEpoch.toString();

      final ChatMessageModel chatMessageModel = ChatMessageModel(
        msg: msg,//text editing controllers message
        toId: chatUser.id, //passing parameter of chatUser id cause current id wants to sent to chatUser
        read: '',
        type: Type.text,
        sent: time,
        fromId: currentUser.uid,
      );

      await firestore
          .collection('chats/${getConversationID(chatUser.id)}/messages')
          .doc(time)
          .set(chatMessageModel.toJson());
      logger.i('message sent$msg');
    } catch (e) {
      logger.e(' sendMessage error: $e');
    }
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
