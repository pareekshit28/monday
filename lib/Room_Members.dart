import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_class_reminder/Services.dart';
import 'package:provider/provider.dart';

class RoomMembers extends StatefulWidget {
  final title;
  final rid;

  RoomMembers(this.title, this.rid);

  @override
  _RoomMembersState createState() => _RoomMembersState();
}

class _RoomMembersState extends State<RoomMembers> {
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    Provider.of<Services>(context, listen: false).checkAdmin(widget.rid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.black,
          title: Text(widget.title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.normal)),
        ),
        body: Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 28,
              ),
              title: Text(
                'Admins',
                style: TextStyle(color: Colors.white, fontSize: 26),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18),
              child: Divider(
                color: Colors.white,
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('rooms')
                      .doc(widget.rid)
                      .collection('admins')
                      .snapshots(),
                  builder: (context, snapshot) => snapshot.hasData
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.size,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Image.network(
                                  snapshot.data.docs
                                      .elementAt(index)
                                      .get('userphoto'),
                                  scale: 2.8,
                                ),
                              ),
                              title: Text(
                                snapshot.data.docs
                                    .elementAt(index)
                                    .get('username'),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              trailing: snapshot.data.size > 1
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.remove,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Services().removeAdmin(
                                          widget.rid,
                                          snapshot.data.docs
                                              .elementAt(index)
                                              .get('uid'),
                                          snapshot.data.docs
                                              .elementAt(index)
                                              .get('username'),
                                          snapshot.data.docs
                                              .elementAt(index)
                                              .get('userphoto')))
                                  : null,
                            );
                          })
                      : Center(
                          child: CircularProgressIndicator(),
                        )),
            ),
            ListTile(
              leading: Icon(
                Icons.people_outline,
                color: Colors.white,
                size: 28,
              ),
              title: Text(
                'Non-Admins',
                style: TextStyle(color: Colors.white, fontSize: 26),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18),
              child: Divider(
                color: Colors.white,
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('rooms')
                      .doc(widget.rid)
                      .collection('non-admins')
                      .snapshots(),
                  builder: (context, snapshot) => snapshot.hasData
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.size,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Image.network(
                                  snapshot.data.docs
                                      .elementAt(index)
                                      .get('userphoto'),
                                  scale: 2.8,
                                ),
                              ),
                              title: Text(
                                snapshot.data.docs
                                    .elementAt(index)
                                    .get('username'),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              trailing:
                                  Provider.of<Services>(context, listen: false)
                                          .isAdmin
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                          onPressed: () => Services().addAdmin(
                                              widget.rid,
                                              snapshot.data.docs
                                                  .elementAt(index)
                                                  .get('uid'),
                                              snapshot.data.docs
                                                  .elementAt(index)
                                                  .get('username'),
                                              snapshot.data.docs
                                                  .elementAt(index)
                                                  .get('userphoto')))
                                      : null,
                            );
                          })
                      : Center(
                          child: CircularProgressIndicator(),
                        )),
            )
          ],
        ));
  }
}
