import 'package:flutter/material.dart';
import '../firebase_util.dart';
import './home_screen.dart';
import './name_screen.dart';
import './enroll_screen.dart';
import '../authenticate.dart';

class LoginPage extends StatelessWidget {
  static const routeName = '/login-page';

  // Used for Google Authentication Login
  void onGoogleSignIn(BuildContext context) async {
    var user = await FireBaseAuthenticationService.authenticator();
    print(user.email);
    var user_id = await FirestoreManager.getPersonID(user.email);
    print(user_id);
    if (user_id != null) {
      bool enrolled = await FirestoreManager.getPersonEnrolled(user.email);
      if (enrolled) {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ));
      } else {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnrollPage(),
            ));
      }
    } else {
      await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NamePage(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double screenHeight = size.height;

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Spacer(),
              Align(
                alignment: Alignment.center,
                child: Container(
                    height: screenHeight * 0.5,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Image.asset(
                            'assets/output.png',
                            width: screenHeight * 0.3,
                          ),
                        ),
                        Text(
                          "HearMe",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                          ),
                        ),
                      ],
                    )),
              ),
              Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 70),
                  child: TextButton(
                    child: Text(
                      'Log in with Google',
                    ),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Colors.pink,
                    ),
                    onPressed: () {
                      onGoogleSignIn(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
