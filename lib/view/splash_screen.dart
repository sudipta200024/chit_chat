import 'package:chit_chat/api/apis.dart';
import 'package:chit_chat/view/auth/login_screen.dart';
import 'package:chit_chat/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    //ui design
    _initializeSystemUI();

    // Navigate after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (Apis.auth.currentUser != null) {
        logger.i('User already logged in: ${Apis.auth.currentUser!.email}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  // Method for Clean System UI setup
  void _initializeSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        // Transparent is better with edgeToEdge
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        // Dark icons (good for light splash)
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          //APP_icon animation
          Positioned(
            top: mq.height * 0.35,
            width: mq.width * 0.60,
            left: mq.width * 0.22,
            child: Image.asset('assets/images/icons/app_icon.png'),
          ),
          // Text
          Positioned(
            bottom: mq.height * 0.1,
            width: mq.width * 0.75,
            left: mq.width * .15,
            child: const Text(
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
