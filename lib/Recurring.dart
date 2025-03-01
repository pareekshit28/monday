import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:online_class_reminder/Services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Recurring extends StatefulWidget {
  final User user;

  Recurring(this.user);

  @override
  _RecurringState createState() => _RecurringState();
}

class _RecurringState extends State<Recurring> {
  int day = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
      ),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 8),
              child: DropdownButton(
                  elevation: 0,
                  value: day,
                  items: [
                    DropdownMenuItem(
                      child: Text('Monday'),
                      value: 1,
                    ),
                    DropdownMenuItem(
                      child: Text('Tuesday'),
                      value: 2,
                    ),
                    DropdownMenuItem(
                      child: Text('Wednesday'),
                      value: 3,
                    ),
                    DropdownMenuItem(
                      child: Text('Thursday'),
                      value: 4,
                    ),
                    DropdownMenuItem(
                      child: Text('Friday'),
                      value: 5,
                    ),
                    DropdownMenuItem(
                      child: Text('Saturday'),
                      value: 6,
                    ),
                    DropdownMenuItem(
                      child: Text('Sunday'),
                      value: 7,
                    ),
                  ],
                  onChanged: (_value) {
                    setState(() {
                      day = _value;
                    });
                  }),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.user.uid)
                    .collection('links')
                    .where('type', isEqualTo: [day, 'recurring']).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  return snapshot.data.size > 0
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.size,
                          itemBuilder: (context, index) {
                            return Card(
                                color: Color.fromRGBO(25, 25, 25, 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    title: Text(
                                      snapshot.data.docs
                                          .elementAt(index)
                                          .get('title'),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 28),
                                    ),
                                    trailing: PopupMenuButton(
                                        elevation: 0,
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: Colors.white,
                                        ),
                                        color: Colors.white,
                                        itemBuilder: (context) => [
                                              PopupMenuItem(
                                                  child: InkWell(
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                        title: Text(
                                                            'Are you sure?'),
                                                        content: Text(
                                                          'This will delete the event permanently!',
                                                        ),
                                                        actions: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child:
                                                                MaterialButton(
                                                              color: Colors
                                                                  .redAccent,
                                                              child: Text(
                                                                  'Delete'),
                                                              onPressed: () {
                                                                Provider.of<Services>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .deleteRecurring(
                                                                  widget.user,
                                                                  snapshot
                                                                      .data.docs
                                                                      .elementAt(
                                                                          index)
                                                                      .get(
                                                                          'id'),
                                                                );
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                          )
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.delete,
                                                      color: Colors.redAccent,
                                                    ),
                                                    SizedBox(
                                                      width: 12,
                                                    ),
                                                    Text('Delete')
                                                  ],
                                                ),
                                              ))
                                            ]),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 4,
                                        ),
                                        RichText(
                                            text: TextSpan(children: [
                                          TextSpan(
                                              text: 'Link:  ',
                                              style: TextStyle(fontSize: 18)),
                                          TextSpan(
                                            text: snapshot.data.docs
                                                .elementAt(index)
                                                .get('link'),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () async {
                                                if (await canLaunch(snapshot
                                                    .data.docs
                                                    .elementAt(index)
                                                    .get('link'))) {
                                                  await launch(snapshot
                                                      .data.docs
                                                      .elementAt(index)
                                                      .get('link'));
                                                  FlutterClipboard.copy(snapshot
                                                          .data.docs
                                                          .elementAt(index)
                                                          .get('link'))
                                                      .then((value) =>
                                                          Scaffold.of(context)
                                                              .showSnackBar(
                                                                  SnackBar(
                                                            content: Text(
                                                                'Copied to clipboard'),
                                                            backgroundColor:
                                                                Color.fromRGBO(
                                                                    25,
                                                                    25,
                                                                    25,
                                                                    1),
                                                          )));
                                                } else {
                                                  FlutterClipboard.copy(snapshot
                                                          .data.docs
                                                          .elementAt(index)
                                                          .get('link'))
                                                      .then((value) =>
                                                          Scaffold.of(context)
                                                              .showSnackBar(
                                                                  SnackBar(
                                                            content: Text(
                                                                'Copied to clipboard'),
                                                            backgroundColor:
                                                                Color.fromRGBO(
                                                                    25,
                                                                    25,
                                                                    25,
                                                                    1),
                                                          )));
                                                }
                                              },
                                            style: TextStyle(
                                                color: Colors.blueAccent,
                                                fontSize: 18),
                                          )
                                        ])),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Password:  ${snapshot.data.docs.elementAt(index).get('password')}',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Time:' +
                                              "  " +
                                              '${snapshot.data.docs.elementAt(index).get('time')}'
                                                  .substring(10, 15) +
                                              ' Hrs',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                ));
                          })
                      : Center(
                          child: Text(
                            'Nothing Here',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                }),
          ),
        ],
      ),
    );
  }
}
