import 'package:chit_chat/view/auth/login_screen.dart';
import 'package:chit_chat/main.dart';
import 'package:chit_chat/view/profile_screen.dart';
import 'package:chit_chat/widget/chat_user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../models/chat_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _dataList = []; //getter list
  final List<ChatUser> _searchList = [];
  late bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    Apis.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.home_outlined),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
            icon: _isSearching
                ? Icon(CupertinoIcons.clear_circled)
                : Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen(user: Apis.me)),
              );
            },
            icon: Icon(Icons.more_vert_outlined),
          ),
        ],
        title: _isSearching
            ? TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'name,email..',
                  hintStyle: TextStyle(fontSize: 16, letterSpacing: 1.5),
                ),
                autofocus: true,
                //search Logic
                onChanged: (val){
                  _searchList.clear();
                  for(var i in _dataList){
                    if(i.name.toLowerCase().contains(val.toLowerCase()) || i.email.toLowerCase().contains(val.toLowerCase())){
                      _searchList.add(i);
                      setState(() {
                        _searchList;
                      });
                    }
                  }
                }
              )
            : Text('Chit Chat'),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 90, right: 5),
        child: FloatingActionButton(
          onPressed: () async {
            Dialogs.showProgressBar(context);
            await FirebaseAuth.instance.signOut();
            await GoogleSignIn().signOut();
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            );
          },
          child: Icon(Icons.add_circle_outline_rounded),
        ),
      ),
      body: StreamBuilder(
        stream: Apis.getAllUser(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            //connection loading
            case ConnectionState.waiting:
            case ConnectionState.none:
              return Center(child: CircularProgressIndicator());

            //connection loaded
            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot
                  .data
                  ?.docs; // final data = snapshot.data?.docs[0].data();
              _dataList =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                  []; //for loop inside the data mapping
              if (_dataList.isNotEmpty) {
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.only(top: mq.height * 0.02),
                  itemCount: _isSearching?_searchList.length:_dataList.length,
                  itemBuilder: (context, index) {
                    return ChatUserCard(user:_isSearching?_searchList[index]: _dataList[index]);
                    // return Text('name: ${list[index]}');
                  },
                );
              } else {
                return Center(
                  child: Text(
                    'No Connection Found!!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                );
              }
          }
        },
      ),
    );
  }
}
