import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../firebase_util.dart';
import './home_screen.dart';

void showToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM);
}

class FriendPage extends StatefulWidget {
  static const routeName = '/friend-page';

  String user_email = "";
  FriendPage({Key key, @required this.user_email}) : super(key: key);

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  static const routeName = '/friend-page';
  String friend_email = "";
  var _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Your Friends'),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  HomePage.routeName,
                  (Route<dynamic> route) => false,
                );
              }),
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text(
              //   user_email,
              //   style: TextStyle(
              //     color: Colors.white,
              //   ),
              // ),
              FutureBuilder(
                  future:
                      FirestoreManager.getPersonFriendsList(widget.user_email),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      print(snapshot.data);
                      var people = [];

                      for (var person in snapshot.data) {
                        people.add(person);
                      }
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: ListView.builder(
                            itemCount: people.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                  leading: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                  title: Text(people[index].name,
                                      style: TextStyle(color: Colors.white)),
                                  subtitle: Text(people[index].email,
                                      style: TextStyle(color: Colors.white)));
                            },
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      throw snapshot.error;
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                        controller: _controller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Input your friend\'s email:',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white)),
                          enabledBorder: new OutlineInputBorder(
                            borderSide: new BorderSide(
                                color: Colors.pink[300], width: 1.0),
                          ),
                          focusedBorder: new OutlineInputBorder(
                            borderSide: new BorderSide(
                                color: Colors.pink[300], width: 1.5),
                          ),
                        ),
                        onChanged: (text) {
                          friend_email = text;
                        })),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.pink[300], // background
                      onPrimary: Colors.white, // foreground
                    ),
                    onPressed: () async {
                      String user_name =
                          await FirestoreManager.getPersonName(friend_email);
                      var friends_email_list =
                          await FirestoreManager.getPersonFriendsEmailList(
                              widget.user_email);
                      if (user_name == null || user_name == "") {
                        showToast("Invalid e-mail address");
                      } else if (friends_email_list.contains(friend_email)) {
                        showToast("You are already connected to the user");
                      } else if (friend_email.compareTo(widget.user_email) ==
                          0) {
                        showToast("You cannot add yourself");
                      } else {
                        await FirestoreManager.addFriendsRelation(
                            widget.user_email, friend_email);
                        showToast("Successfully added friend");
                        _controller.clear();
                        setState(() {});
                      }
                    },
                    child: const Text('Add friend',
                        style: TextStyle(fontSize: 20)),
                    // color: Colors.blue,
                    // textColor: Colors.white,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
