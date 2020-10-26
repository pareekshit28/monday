import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:online_class_reminder/HomeScreen.dart';

class Authentication extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/app_logo.png'),
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.1),
                    BlendMode.dstATop,
                  ),
                  fit: BoxFit.cover)),
          child: Padding(
            padding: const EdgeInsets.all(26.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 28,
                ),
                Text(
                  'Log in',
                  style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: 50,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  'To',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  'Continue..',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: SizedBox()),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  onPressed: () {
                                    onGoogleSignIn(context);
                                  },
                                  color: Colors.white,
                                  splashColor: Colors.grey,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          'assets/images/google_logo.png',
                                          scale: 20,
                                        ),
                                        SizedBox(
                                          width: 16,
                                        ),
                                        Text(
                                          'Sign in with Google',
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 70,
                      ),
                      Text(
                        'Made with ❤ in India     ',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<User> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken);

    User user = (await _auth.signInWithCredential(credential)).user;

    return user;
  }

  void onGoogleSignIn(BuildContext context) async {
    await signInWithGoogle().then((value) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen(value)),
          (route) => false);
    });
  }
}
