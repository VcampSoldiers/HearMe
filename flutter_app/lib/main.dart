import 'package:flutter/material.dart';
import 'package:flutter_app/pages/enroll_screen.dart';

// Pages
import 'pages/login_screen.dart';
import 'pages/name_screen.dart';
import 'pages/home_screen.dart';
import 'pages/friends_screen.dart';
import 'pages/enroll_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HearMe',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.black,
        accentColor: Colors.white,
      ),
      home: LoginPage(),
      routes: {
        LoginPage.routeName: (ctx) => LoginPage(),
        NamePage.routeName: (ctx) => NamePage(),
        HomePage.routeName: (ctx) => HomePage(),
        EnrollPage.routeName: (ctx) => EnrollPage(),
      },
    );
  }
}
