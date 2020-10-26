import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:online_class_reminder/RLinks.dart';
import 'package:online_class_reminder/Room_Members.dart';
import 'package:online_class_reminder/Services.dart';
import 'package:provider/provider.dart';

class Room extends StatelessWidget {
  final joinController = TextEditingController();
  final createController = TextEditingController();
  final User user;
  Room(this.user);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('rooms')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else
            return Scaffold(
              backgroundColor: Colors.black,
              floatingActionButton: SpeedDial(
                elevation: 0,
                overlayOpacity: 0,
                animatedIcon: AnimatedIcons.menu_close,
                children: [
                  SpeedDialChild(
                    child: Icon(Icons.add),
                    label: 'Join',
                    onTap: () {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          backgroundColor: Color.fromRGBO(25, 25, 25, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8))),
                          context: context,
                          builder: (context) {
                            return Padding(
                              padding: MediaQuery.of(context).viewInsets,
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Wrap(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        autofocus: true,
                                        controller: createController,
                                        cursorColor: Colors.white,
                                        style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          labelText: 'Code',
                                          labelStyle:
                                              TextStyle(color: Colors.white),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white)),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white70)),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(child: SizedBox()),
                                          MaterialButton(
                                            color: Colors.white,
                                            child: Text(
                                              'Join',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Provider.of<Services>(context,
                                                      listen: false)
                                                  .joinAsNonAdmin(user,
                                                      createController.text);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.create),
                    label: 'Create',
                    onTap: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Color.fromRGBO(25, 25, 25, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8))),
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: MediaQuery.of(context).viewInsets,
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Wrap(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                      autofocus: true,
                                      controller: createController,
                                      cursorColor: Colors.white,
                                      style: TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        labelText: 'Name',
                                        labelStyle:
                                            TextStyle(color: Colors.white),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white70)),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        Expanded(child: SizedBox()),
                                        MaterialButton(
                                          color: Colors.white,
                                          child: Text(
                                            'Create',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Provider.of<Services>(context,
                                                    listen: false)
                                                .createRoom(user,
                                                    createController.text);
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              body: snapshot.data.size > 0
                  ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListView.builder(
                        itemCount: snapshot.data.size,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Card(
                                color: Color.fromRGBO(25, 25, 25, 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    title: Text(
                                      snapshot.data.docs
                                          .elementAt(index)
                                          .get('name'),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 28),
                                    ),
                                    subtitle: Text(
                                      'Created:  ' +
                                          snapshot.data.docs
                                              .elementAt(index)
                                              .get('created')
                                              .toString()
                                              .split('.')[0],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontStyle: FontStyle.italic),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                          CupertinoPageRoute(
                                              builder: (context) => RLinks(
                                                  user,
                                                  snapshot
                                                      .data.docs
                                                      .elementAt(index)
                                                      .get('name'),
                                                  snapshot.data.docs
                                                      .elementAt(index)
                                                      .get('id'))));
                                    },
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
                                                  FlutterClipboard.copy(snapshot
                                                          .data.docs
                                                          .elementAt(index)
                                                          .get('id'))
                                                      .then((result) {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            'Copied to Clipboard!',
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            Colors.white,
                                                        textColor: Colors.black,
                                                        fontSize: 16.0);
                                                  });
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.content_copy,
                                                      color: Colors.black,
                                                    ),
                                                    SizedBox(
                                                      width: 12,
                                                    ),
                                                    Text('Copy room Id')
                                                  ],
                                                ),
                                              )),
                                              PopupMenuItem(
                                                  child: InkWell(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  Navigator.of(context).push(
                                                      CupertinoPageRoute(
                                                          builder: (context) =>
                                                              RoomMembers(
                                                                  snapshot
                                                                      .data.docs
                                                                      .elementAt(
                                                                          index)
                                                                      .get(
                                                                          'name'),
                                                                  snapshot
                                                                      .data.docs
                                                                      .elementAt(
                                                                          index)
                                                                      .get(
                                                                          'id'))));
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.person_outline,
                                                      color: Colors.black,
                                                    ),
                                                    SizedBox(
                                                      width: 12,
                                                    ),
                                                    Text('Members')
                                                  ],
                                                ),
                                              )),
                                              PopupMenuItem(
                                                  child: InkWell(
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                  Services().leaveRoom(
                                                      snapshot.data.docs
                                                          .elementAt(index)
                                                          .get('id'),
                                                      user);
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.exit_to_app,
                                                      color: Colors.black,
                                                    ),
                                                    SizedBox(
                                                      width: 12,
                                                    ),
                                                    Text('Leave room')
                                                  ],
                                                ),
                                              )),
                                            ]),
                                  ),
                                ),
                              ),
                              if (index == 13)
                                SizedBox(
                                  height: 65,
                                )
                            ],
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Text(
                        'Create or Join a room',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            );
        });
  }
}
