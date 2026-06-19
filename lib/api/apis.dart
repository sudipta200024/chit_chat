import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chit_chat/models/chat_message_model.dart';
import 'package:chit_chat/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Type;
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../main.dart';
import 'api_keys.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Apis {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //cloudinary access
  static final CloudinaryPublic cloudinary = CloudinaryPublic(
    ApiKeys.cloudinaryCloudName,
    ApiKeys.cloudinaryUploadPreset,
    cache: false,
  );

  //current user from firebase auth
  static User get currentUser => auth.currentUser!; //logged in user

  //declaring a static variable chatUser model
  //current user from firebase firestore
  static late ChatUser me;

  //for firebase messaging Access
  static FirebaseMessaging fireMessaging = FirebaseMessaging.instance;

  //notification

  static Future<void> syncPushToken() async {
    await fireMessaging.requestPermission();

    // get OneSignal ID
    await Future.delayed(Duration(seconds: 2));
    logger.i('Device OneSignal ID: ${OneSignal.User.pushSubscription.id}');
    final osId = OneSignal.User.pushSubscription
        .id; // here is onesignal id created with device ipaddress and other address

    if (osId != null) {
      me.pushToken = osId;
      await firestore.collection('users').doc(currentUser.uid).update({
        'push_token': osId,
      });
      logger.i('OneSignal ID: $osId');
    }

    // used for token changes
    OneSignal.User.pushSubscription.addObserver((state) async {
      final newId = state.current.id;
      if (newId != null && newId != me.pushToken) {
        me.pushToken = newId;
        await firestore.collection('users').doc(currentUser.uid).update({
          'push_token': newId,
        });
        logger.i('OneSignal ID updated: $newId');
      }
    });
  }

  static Future<void> sendPushNotification(ChatUser chatUser,
      String msg,) async {
    try {
      logger.i('Sending token to receiver: ${chatUser.pushToken}');
      final body = {
        "app_id": ApiKeys.oneSignalAppId,
        "include_player_ids": [chatUser.pushToken],
        // receiver's OneSignal ID not current id
        "headings": {"en": me.name},
        "contents": {"en": msg},
        //notification pop settings
        "priority": 10,
        "android_visibility": 1,
        "ttl": 259200,
        "isAndroidBackground": true,
      };
      final response = await http.post(
        Uri.parse("https://onesignal.com/api/v1/notifications"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Basic ${ApiKeys.oneSignalRestApiKey}",
        },
        body: jsonEncode(body),
      );
      logger.i('Notification response: ${response.body}');
    } catch (e) {
      logger.e('Notification error: $e');
    }
  }

  static final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await localNotifications.initialize(settings: settings);
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'chit_chat_channel',
      'Chit Chat Messages',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await localNotifications.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  //get self info from firestore
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(currentUser.uid).get().then((
        user,) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await syncPushToken(); //for firebase messaging gets token after getting user info 'me'
        updateActiveStatus(true);
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
    final time = DateTime
        .now()
        .microsecondsSinceEpoch
        .toString();
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

  //to get info about users online offline data and active time
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser,) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  //update online offline and time activity status
  static Future<void> updateActiveStatus(bool isOnline) async {
    return await firestore.collection('users').doc(currentUser.uid).update({
      'is_online': isOnline,
      'last_active': DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
      'push_token': me.pushToken,
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
      return '${id}_${currentUser
          .uid}'; //if current id is bigger than userId (id,passing parameter of chatUser id)then userID_currentuid

      // You open chat:    compareTo() → "AAA_BBB" ✅
      // userId or Friend opens chat: compareTo() → "AAA_BBB" ✅ same!
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllImageMessages(
      ChatUser chatUser,) {
    return firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages')
        .snapshots();
  }

  //get all messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser chatUser,) {
    return firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //send message logic
  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    try {
      final time = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();

      final ChatMessageModel chatMessageModel = ChatMessageModel(
        msg: msg,
        //text editing controllers message
        toId: chatUser.id,
        //passing parameter of chatUser id cause current id wants to sent to chatUser
        read: '',
        type: Type.text,
        sent: time,
        fromId: currentUser.uid,
      );

      await firestore
          .collection(
        'chats/${getConversationID(chatUser.id)}/messages',
      ) //senders ID
          .doc(time)
          .set(chatMessageModel.toJson());
      logger.i('message sent$msg');
      //send push notification
      await sendPushNotification(chatUser, msg);
    } catch (e) {
      logger.e(' sendMessage error: $e');
    }
  }


  //update message read status with blue tik
  static Future<void> updateReadMessageStatus(
      ChatMessageModel chatMessageModel,) async {
    logger.e(chatMessageModel.fromId);
    await firestore
        .collection(
      'chats/${getConversationID(
          chatMessageModel.fromId)}/messages', //senders id
      // chatMessageModel.fromId = sender’s UID (John’s ID here)
      // chatMessageModel.toId   = receiver’s UID (my ID here, since I received it)
    )
        .doc(chatMessageModel.sent)
        .update({
      'read': DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
    }); //update read = current time
  }

  //update msg
  static Future<void> updateMessage(ChatMessageModel chatMessageModel,
      String updatedMsg) async {
    try {
      await firestore.collection(
          'chats/${getConversationID(chatMessageModel.fromId == currentUser.uid ? chatMessageModel.toId : chatMessageModel.fromId)}/messages').doc(
          chatMessageModel.sent).update({'msg': updatedMsg});
    }catch(e){
      logger.e('updateMessage error: $e');
    }
  }
  //delete msg
  //delete msg
  static Future<void> deleteMessage(ChatMessageModel chatMessageModel) async {
    try {
      await firestore.collection(
          'chats/${getConversationID(chatMessageModel.fromId == currentUser.uid ? chatMessageModel.toId : chatMessageModel.fromId)}/messages').doc(
          chatMessageModel.sent).delete();
    }catch(e){
      logger.e('deleteMessage error: $e');
    }
  }


  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser chatUser,) {
    //passing the parameter of chatUser id cause current id wants to sent to chatUser
    //gets the id that will be passed from messageCard
    return firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages')
        .orderBy(
      'sent',
      descending: true,
    ) //descending order to get the latest message
        .limit(1) //only get the latest message for less load time
        .snapshots();
  }

  //send chat images

  static Future<String?> sendChatImage(ChatUser chatUser,
      String imagePath,) async {
    //just like sendMsg + upload picture together
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        //this is going to cloudinary
        CloudinaryFile.fromFile(
          imagePath, //imagePath = _image(from Xfile gallery or camera)step 1
          resourceType: CloudinaryResourceType.Image,
          folder: 'chat_images',
        ),
      );
      String imageUrl = response.secureUrl; //this is coming from cloudinary
      final time = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(); //for creating msg id

      final ChatMessageModel chatMessageModel = ChatMessageModel(
        msg: imageUrl,
        //cloudinary uploaded picture url goes to chatMsgModel
        //text editing controllers message
        toId: chatUser.id,
        //passing parameter of chatUser id cause current id wants to sent to chatUser
        read: '',
        type: Type.image,
        sent: time,
        fromId: currentUser.uid,
      );
      //update image url inside firestore(step 2)
      await firestore
          .collection(
        'chats/${getConversationID(chatUser.id)}/messages',
      ) //senders ID
          .doc(time)
          .set(chatMessageModel.toJson());
      logger.i('message sent$imageUrl');
      await sendPushNotification(chatUser, '📷 Image');
      return imageUrl;
    } catch (e) {
      logger.e('Cloudinary error: $e');
    }
    return null;
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
