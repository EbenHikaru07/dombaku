import 'package:dombaku/dashboard/dashboard.dart';
import 'package:dombaku/session/user_session.dart';
import 'package:dombaku/starting/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  bool loggedIn = await UserSession.isLoggedIn();

  runApp(MyApp(isLoggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DombaKu',
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? DashboardPage() : SplashScreen(),
    );
  }
}
