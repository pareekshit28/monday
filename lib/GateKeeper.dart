import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:online_class_reminder/Authentication.dart';
import 'package:online_class_reminder/Timetable.dart';

enum SignedState { signedIn, notSignedIn }

class GateKeeper extends StatefulWidget {
  @override
  _GateKeeperState createState() => _GateKeeperState();
}

class _GateKeeperState extends State<GateKeeper> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User user;
  SignedState signedState;
  @override
  void initState() {
    super.initState();
    checkIfUserIsSignedIn();
    currentUser();
  }

  void checkIfUserIsSignedIn() async {
    var userSignedIn = await _googleSignIn.isSignedIn();

    setState(() {
      signedState =
          userSignedIn ? SignedState.signedIn : SignedState.notSignedIn;
    });
  }

  void currentUser() {
    var currentUser = _auth.currentUser;
    setState(() {
      user = currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (signedState == SignedState.signedIn) {
      if (user.uid != null) {
        return Timetable(user, todayDay());
      } else {
        return Center(child: CircularProgressIndicator());
      }
    } else {
      return Authentication();
    }
  }

  String todayDay() {
    if (DateTime.now().weekday == 1) {
      return 'Monday';
    }
    if (DateTime.now().weekday == 2) {
      return 'Tuesday';
    }
    if (DateTime.now().weekday == 3) {
      return 'Wednesday';
    }
    if (DateTime.now().weekday == 4) {
      return 'Thursday';
    }
    if (DateTime.now().weekday == 5) {
      return 'Friday';
    }
    if (DateTime.now().weekday == 6) {
      return 'Saturday';
    }
    if (DateTime.now().weekday == 7) {
      return 'Sunday';
    }
  }
}
