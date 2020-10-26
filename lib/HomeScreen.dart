import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:online_class_reminder/Links.dart';
import 'package:online_class_reminder/Room.dart';
import 'package:online_class_reminder/Settings.dart';
import 'package:online_class_reminder/TimeTable.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final List weeks = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  HomeScreen(
    this.user,
  );
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List _children = [
      Timetable(widget.user, widget.weeks[DateTime.now().weekday]),
      Room(widget.user),
      Links(widget.user)
    ];
    List _title = [
      Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 18, right: 18),
        child: Text(
          widget.weeks[DateTime.now().weekday - 1],
          style: TextStyle(
              color: Colors.white, fontSize: 42, fontWeight: FontWeight.normal),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 18, right: 18),
        child: Text(
          'Rooms',
          style: TextStyle(
              color: Colors.white, fontSize: 42, fontWeight: FontWeight.normal),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 18, right: 18),
        child: Text(
          'Personal',
          style: TextStyle(
              color: Colors.white, fontSize: 42, fontWeight: FontWeight.normal),
        ),
      ),
    ];
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.black,
        title: _title[_currentIndex],
        actions: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: IconButton(
                icon: Icon(
                  Icons.settings,
                  size: 38,
                ),
                onPressed: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) => Settings(
                            widget.user,
                          )));
                }),
          )
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Color.fromRGBO(25, 25, 25, 1),
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8),
            child: Column(
              children: [
                ListTile(
                  leading: Image.asset(
                    'assets/images/app_logo.png',
                    scale: 5.5,
                  ),
                  title: Text(
                    'Monday',
                    style: TextStyle(color: Colors.white, fontSize: 28),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12),
                  child: Divider(
                    color: Colors.white,
                    thickness: 0.2,
                  ),
                ),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(28),
                          bottomRight: Radius.circular(28))),
                  color: _currentIndex == 0
                      ? Colors.lightBlue.withOpacity(0.2)
                      : Colors.transparent,
                  child: ListTile(
                    leading: Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Today',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      onTabTapped(0);
                    },
                  ),
                ),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(28),
                          bottomRight: Radius.circular(28))),
                  color: _currentIndex == 1
                      ? Colors.lightBlue.withOpacity(0.2)
                      : Colors.transparent,
                  child: ListTile(
                    leading: Icon(
                      Icons.group,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Meeting Rooms',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      onTabTapped(1);
                    },
                  ),
                ),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(28),
                          bottomRight: Radius.circular(28))),
                  color: _currentIndex == 2
                      ? Colors.lightBlue.withOpacity(0.2)
                      : Colors.transparent,
                  child: ListTile(
                    leading: Icon(
                      Icons.account_box,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Personal',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      onTabTapped(2);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _children[_currentIndex],
    ));
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
