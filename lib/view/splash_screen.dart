import 'package:chit_chat/api/apis.dart';
import 'package:chit_chat/view/auth/login_screen.dart';
import 'package:chit_chat/main.dart';
import 'package:chit_chat/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        //exist fullscreen mode
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(systemNavigationBarColor: Colors.white),
        );
        //if authenticated then keep in the home
        if (Apis.auth.currentUser != null) {
          logger.i('\n${Apis.auth.currentUser}');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          //APP_icon animation
          Positioned(
            top: mq.height * 0.35,
            width: mq.width * 0.60,
            left: mq.width * 0.22,
            child: Image.asset('assets/images/icons/app_icon.png'),
          ),
          //login Button
          Positioned(
            bottom: mq.height * 0.1,
            width: mq.width * 0.75,
            left: mq.width * .15,
            child: Text(
              "Lets Chit Chat",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
