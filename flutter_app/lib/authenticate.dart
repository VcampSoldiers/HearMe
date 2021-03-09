import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

class FireBaseAuthenticationService {
  static Future<FirebaseUser> authenticator() async {
    FirebaseUser user;
    // Checks if user is signed in already.
    bool isSignedIn = await _googleSignIn.isSignedIn();
    if (isSignedIn) {
      user = await _auth.currentUser();
    } else {
      print('section1');
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      print('section2');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('section3');
      final AuthCredential credential = await GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      user = (await _auth.signInWithCredential(credential)).user;
    }

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return user;
  }

  static Future<FirebaseUser> getCurrentUser() async {
    final FirebaseUser user = await _auth.currentUser();
    return user;
  }

  static void logOut() async {
    await _googleSignIn.signOut();
    print("Successfully Signed Out");
  }
}
