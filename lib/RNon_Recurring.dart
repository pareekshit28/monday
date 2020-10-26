import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:online_class_reminder/Services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RNonReccuring extends StatelessWidget {
  final User user;
  final rid;

  RNonReccuring(this.user, this.rid);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
            color: Color.fromRGBO(25, 25, 25, 1),
            child: ListTile(
              leading: Icon(
                Icons.info,
                color: Colors.white,
              ),
              title: Text(
                'Expired Non Recurring links will stay up to a maximum of 2 days in Cloud.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 4,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
            ),
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(rid)
                    .collection('links')
                    .where('type', isEqualTo: 'nonRecurring')
                    .snapshots(),
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
                                        .get('title')
                                        .toString()
                                        .split(' ')[0],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.normal),
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
                                                Provider.of<Services>(context,
                                                            listen: false)
                                                        .isAdmin
                                                    ? showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            shape: RoundedRectangleBorder(
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
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    MaterialButton(
                                                                  color: Colors
                                                                      .redAccent,
                                                                  child: Text(
                                                                      'Delete'),
                                                                  onPressed:
                                                                      () {
                                                                    Provider.of<Services>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .deleteRNonRecurring(
                                                                      rid,
                                                                      snapshot
                                                                          .data
                                                                          .docs
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
                                                      )
                                                    : Scaffold.of(context)
                                                        .showSnackBar(SnackBar(
                                                            backgroundColor:
                                                                Color.fromRGBO(
                                                                    25,
                                                                    25,
                                                                    25,
                                                                    1),
                                                            content: Text(
                                                              'Only admins can add links!',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            )));
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
                                          text: 'Link: ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
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
                                                await launch(snapshot.data.docs
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
                                                              Color.fromRGBO(25,
                                                                  25, 25, 1),
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
                                                              Color.fromRGBO(25,
                                                                  25, 25, 1),
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
                                            color: Colors.white, fontSize: 18),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        'Date:' +
                                            "  " +
                                            '${snapshot.data.docs.elementAt(index).get('date')}'
                                                .split(' ')[0],
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
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
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          })
                      : Center(
                          child: Text(
                            'Nothing Here',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                }),
          ),
        ),
      ],
    );
  }
}
