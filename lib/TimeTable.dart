import 'dart:ui';

import 'package:clipboard/clipboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:online_class_reminder/AdManager.dart';
import 'package:online_class_reminder/Services.dart';
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
  void initState() {
    super.initState();
    AdManager.initializeAd();
    AdManager.showBannerAd();
  }

  @override
  void dispose() {
    AdManager.hideBannerAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Services>(builder: (context, services, child) {
      return SmartRefresher(
        enablePullDown: true,
        controller: widget.refreshController,
        onRefresh: () => onRefresh(widget.user),
        child: services.loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : services.todayList.length > 0
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
                                  services.todayList[index].data()['title'],
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
                                          text: services.todayList[index]
                                              .data()['link'],
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              if (await canLaunch(services
                                                  .todayList[index]
                                                  .data()['link'])) {
                                                await launch(services
                                                    .todayList[index]
                                                    .data()['link']);
                                                FlutterClipboard.copy(services
                                                        .todayList[index]
                                                        .data()['link'])
                                                    .then((value) =>
                                                        Scaffold.of(context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          content: Text(
                                                              'Copied to clipboard'),
                                                          backgroundColor:
                                                              Color.fromRGBO(25,
                                                                  25, 25, 1),
                                                        )));
                                              } else {
                                                FlutterClipboard.copy(services
                                                        .todayList[index]
                                                        .data()['link'])
                                                    .then((value) =>
                                                        Scaffold.of(context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          content: Text(
                                                              'Copied to clipboard'),
                                                          backgroundColor:
                                                              Color.fromRGBO(25,
                                                                  25, 25, 1),
                                                        )));
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
                                    'Password:  ${services.todayList[index].data()['password']}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    'Time:  ' +
                                        '${services.todayList[index].data()['time']}'
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
      );
    });
  }

  void onRefresh(User user) async {
    await Future.delayed(Duration(milliseconds: 1000));
    Provider.of<Services>(context, listen: false).addToToday(user);
    Provider.of<Services>(context, listen: false).deleteUseless(user);
    widget.refreshController.refreshCompleted();
  }
}
