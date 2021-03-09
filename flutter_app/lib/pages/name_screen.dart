import 'package:flutter/material.dart';
import 'package:flutter_app/azure_util.dart';
import 'package:flutter_app/pages/enroll_screen.dart';
import 'package:flutter_app/pages/login_screen.dart';
import './home_screen.dart';

// Google Firebase/store utils
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_util.dart';
import '../authenticate.dart';

class NamePage extends StatefulWidget {
  static const routeName = '/name-page';

  @override
  _NamePageState createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  String user_email = "";
  String user_name = "";
  Firestore firestore = Firestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('HearMe'),
          backgroundColor: Colors.black,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                FireBaseAuthenticationService.logOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  LoginPage.routeName,
                  (Route<dynamic> route) => false,
                );
              }),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text(
             "Hello there",
             style: TextStyle(color:Colors.white, fontSize: 55, fontWeight: FontWeight.bold),
             textAlign: TextAlign.left,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 70, horizontal: 30),
              child: TextField(
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send, color:Colors.pink[300]),
                      onPressed: () async {
                        String user_email =
                            await FireBaseAuthenticationService.getCurrentUser()
                                .then((user) => user.email);
                        String userID = await AzureManager.addProfile();
                        await FirestoreManager.addPerson(
                            user_email, userID, user_name);
                        await Navigator.pushNamedAndRemoveUntil(
                          context,
                          EnrollPage.routeName,
                          (Route<dynamic> route) => false,
                        );
                      },
                    ), 
                    border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.white)
                    ),
                    enabledBorder: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.pink[300], width: 1.0),
                    ),
                    focusedBorder: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.pink[300], width: 1.5),
                    ),
                    hintText: 'Enter your name:',
                    helperText: 'This is what we assume others call you by',
                    helperStyle: TextStyle(color:Colors.grey),
                    hintStyle: TextStyle(color:Colors.grey)),
                style: TextStyle(color:Colors.white, fontSize: 25),
                onChanged: (text) {
                  user_name = text;
                  // Pass this text to firebase
                  print("Name entered: $text");
                },
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
