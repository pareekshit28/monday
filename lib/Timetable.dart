import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:online_class_reminder/Links.dart';
import 'package:online_class_reminder/Services.dart';
import 'package:online_class_reminder/Settings.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
import 'package:url_launcher/url_launcher.dart';

class Timetable extends StatefulWidget {
  final User user;
  final String day;
  final refreshController = RefreshController(initialRefresh: true);
  Timetable(this.user, this.day);

  @override
  _TimetableState createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Services>(builder: (context, services, child) {
      return SafeArea(
          child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.black,
          title: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              widget.day,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.normal),
            ),
          ),
          actions: [
            IconButton(
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
            SizedBox(
              width: 28,
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 0,
          backgroundColor: Colors.white,
          onPressed: () {
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => Links(widget.user, widget.day)));
          },
          child: Icon(
            Icons.link,
            color: Colors.black,
          ),
        ),
        body: SmartRefresher(
          enablePullDown: true,
          controller: widget.refreshController,
          onRefresh: () => onRefresh(widget.user),
          child: services.todayList.length > 0
              ? Timeline.builder(
                  lineColor: Colors.black,
                  position: TimelinePosition.Left,
                  itemCount: services.todayList.length,
                  itemBuilder: (context, index) => TimelineModel(
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        color: Color.fromRGBO(25, 25, 25, 1),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                services.todayList[index]['title'],
                                style: TextStyle(
                                    color: Colors.white, fontSize: 28),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text: 'Link:  ',
                                          style: TextStyle(fontSize: 18)),
                                      TextSpan(
                                        text: services.todayList[index]['link'],
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            if (await canLaunch(services
                                                .todayList[index]['link'])) {
                                              await launch(services
                                                  .todayList[index]['link']);
                                            } else {
                                              Scaffold.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Cannot open this link!'),
                                                backgroundColor: Color.fromRGBO(
                                                    25, 25, 25, 1),
                                              ));
                                            }
                                          },
                                        style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize: 18),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  'Password:  ${services.todayList[index]['password']}',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  'Time:  ' +
                                      '${services.todayList[index]['time']}'
                                          .substring(10, 15) +
                                      ' Hrs',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.white,
                      ),
                      iconBackground: Colors.black,
                      position: TimelineItemPosition.right),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No Meetings Today',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        ':)',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
        ),
      ));
    });
  }

  void onRefresh(User user) async {
    await Future.delayed(Duration(milliseconds: 2000));
    Provider.of<Services>(context, listen: false).addToToday(user);
    Provider.of<Services>(context, listen: false).deleteUseless(user);
    widget.refreshController.refreshCompleted();
  }
}
