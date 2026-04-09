import 'package:chit_chat/view/splash_screen.dart';
import 'package:flutter/material.dart';
import "package:firebase_core/firebase_core.dart";
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'firebase_options.dart';

late Size mq; //media query Size declaration globally
Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    printEmojis: true,   // ← removes emojis
    colors: true,         // ← keeps colors
  ),
);
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //makes full screen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    _initializeFirebase();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(size: 30),
          centerTitle: true,
          elevation: 3,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(elevation: 6),
        ),
      ),
      home: SplashScreen(),
    );
  }
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
