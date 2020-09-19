import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:online_class_reminder/GateKeeper.dart';
import 'package:online_class_reminder/Services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider<Services>(
      create: (context) => Services(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(accentColor: Colors.white, primaryColor: Colors.black),
        home: GateKeeper());
  }
}
