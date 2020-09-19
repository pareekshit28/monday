import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:online_class_reminder/Authentication.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final User user;

  Settings(
    this.user,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.black,
        title: Text(
          'Settings',
          style: TextStyle(
              color: Colors.white, fontSize: 42, fontWeight: FontWeight.normal),
        ),
        actions: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: ClipRRect(
              child: Image(image: NetworkImage(user.photoURL, scale: 3)),
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          SizedBox(
            width: 28,
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ListTile(
            onTap: () async {
              if (await canLaunch('https://t.me/pareekshitdev')) {
                launch('https://t.me/pareekshitdev');
              } else
                Fluttertoast.showToast(
                    msg: 'Connection Error',
                    gravity: ToastGravity.BOTTOM,
                    textColor: Colors.black);
            },
            leading: Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
            ),
            title: Text(
              'Contact Developer',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
          ListTile(
            onTap: () {
              _auth.signOut().then((value) => _googleSignIn.signOut()).then(
                  (value) => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Authentication()),
                      ((Route route) => false)));
            },
            leading: Icon(
              Icons.power_settings_new,
              color: Colors.redAccent,
            ),
            title: Text(
              'Sign Out',
              style: TextStyle(color: Colors.redAccent, fontSize: 22),
            ),
          ),
        ],
      ),
    );
  }
}
