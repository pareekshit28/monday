import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Services with ChangeNotifier {
  final db = FirebaseFirestore.instance;
  bool recurring = false;
  final uuid = Uuid();
  List<QueryDocumentSnapshot> todayList = [];
  bool isAdmin;
  bool loading = false;
  void changeRecurring(bool newValue) {
    recurring = newValue;
    notifyListeners();
  }

  void checkAdmin(String rid) {
    String uid = FirebaseAuth.instance.currentUser.uid;
    FirebaseFirestore.instance
        .collection('rooms')
        .doc(rid)
        .collection('admins')
        .where('uid', isEqualTo: uid)
        .get()
        .then((value) {
      value.docs.length == 0 ? isAdmin = false : isAdmin = true;
      notifyListeners();
    });
  }

  void addToToday(User user) {
    loading = true;
    notifyListeners();
    List roomList = [];
    db
        .collection('users')
        .doc(user.uid)
        .collection('rooms')
        .get()
        .then((value) {
      todayList.clear();
      roomList = value.docs;
      for (QueryDocumentSnapshot room in roomList) {
        db
            .collection('rooms')
            .doc(room.data()['id'])
            .collection('links')
            .where('type', isEqualTo: [DateTime.now().weekday, 'recurring'])
            .get()
            .then((value) {
              for (var doc in value.docs) {
                todayList.add(doc);
              }
              loading = false;
              notifyListeners();
            })
            .whenComplete(() {
              db
                  .collection('rooms')
                  .doc(room.data()['id'])
                  .collection('links')
                  .where('date',
                      isEqualTo: DateTime.now().toString().split(' ')[0])
                  .get()
                  .then((value) {
                for (var doc in value.docs) {
                  todayList.add(doc);
                }
                loading = false;
                notifyListeners();
              });
            })
            .whenComplete(() {
              db
                  .collection('users')
                  .doc(user.uid)
                  .collection('links')
                  .where('type',
                      isEqualTo: [DateTime.now().weekday, 'recurring'])
                  .get()
                  .then((value) {
                    for (var doc in value.docs) {
                      todayList.add(doc);
                    }
                    loading = false;
                    notifyListeners();
                  });
            })
            .whenComplete(() {
              db
                  .collection('users')
                  .doc(user.uid)
                  .collection('links')
                  .where('date',
                      isEqualTo: DateTime.now().toString().split(' ')[0])
                  .get()
                  .then((value) {
                for (var doc in value.docs) {
                  todayList.add(doc);
                }
                loading = false;
                notifyListeners();
              });
            })
            .whenComplete(() {
              todayList.sort((a, b) => a
                  .data()['time']
                  .toString()
                  .compareTo(b.data()['time'].toString()));
              loading = false;
              notifyListeners();
            });
      }
    });
    loading = false;
    notifyListeners();
  }

  void createRoom(User user, String name) {
    var id = uuid.v4();
    var created = DateTime.now().toString();
    db
        .collection('rooms')
        .doc(id)
        .collection('details')
        .doc('details')
        .set({'name': name, 'created': created, 'id': id});
    joinAsAdmin(user, id);
  }

  void leaveRoom(String rid, User user) {
    db.collection('users').doc(user.uid).collection('rooms').doc(rid).delete();
    db.collection('rooms').doc(rid).collection('admins').doc(user.uid).delete();
    db
        .collection('rooms')
        .doc(rid)
        .collection('non-admins')
        .doc(user.uid)
        .delete();
  }

  void joinAsAdmin(User user, String id) {
    var name;
    var created;
    db
        .collection('rooms')
        .doc(id)
        .collection('details')
        .doc('details')
        .get()
        .then((value) {
      name = value.get('name');
      created = value.get('created');
    }).then((value) {
      db
          .collection('users')
          .doc(user.uid)
          .collection('rooms')
          .doc(id)
          .set({'id': id, 'name': name, 'created': created});

      db.collection('rooms').doc(id).collection('admins').doc(user.uid).set({
        'uid': user.uid,
        'username': user.displayName,
        'userphoto': user.photoURL
      });
    });
  }

  void joinAsNonAdmin(User user, String id) {
    var name;
    var created;
    db
        .collection('rooms')
        .doc(id)
        .collection('details')
        .doc('details')
        .get()
        .then((value) {
      name = value.get('name');
      created = value.get('created');
    }).then((value) {
      db
          .collection('users')
          .doc(user.uid)
          .collection('rooms')
          .doc(id)
          .set({'id': id, 'name': name, 'created': created});

      db
          .collection('rooms')
          .doc(id)
          .collection('non-admins')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'username': user.displayName,
        'userphoto': user.photoURL
      });
    });
  }

  void addAdmin(String rid, String uid, String displayName, String photoUrl) {
    db.collection('rooms').doc(rid).collection('non-admins').doc(uid).delete();
    db
        .collection('rooms')
        .doc(rid)
        .collection('admins')
        .doc(uid)
        .set({'uid': uid, 'username': displayName, 'userphoto': photoUrl});
  }

  void removeAdmin(
      String rid, String uid, String displayName, String photoUrl) {
    db.collection('rooms').doc(rid).collection('admins').doc(uid).delete();
    db
        .collection('rooms')
        .doc(rid)
        .collection('non-admins')
        .doc(uid)
        .set({'uid': uid, 'username': displayName, 'userphoto': photoUrl});
  }

  void addDateToRoom(String rid, User user, String title, String link,
      String password, DateTime date, TimeOfDay time) {
    var id = uuid.v4();
    db.collection('rooms').doc(rid).collection('links').doc(id).set({
      'title': title,
      'link': link,
      'password': password == '' ? 'N/A' : password,
      'date': date.toString().split(' ')[0],
      'day': date.weekday,
      'time': time.toString(),
      'id': id,
      'type': 'nonRecurring'
    });
  }

  void addDate(User user, String title, String link, String password,
      DateTime date, TimeOfDay time) {
    var id = uuid.v4();
    db.collection('users').doc(user.uid).collection('links').doc(id).set({
      'title': title,
      'link': link,
      'password': password == '' ? 'N/A' : password,
      'date': date.toString().split(' ')[0],
      'day': date.weekday,
      'time': time.toString(),
      'id': id,
      'type': 'nonRecurring'
    });
  }

  void addDayToRoom(
    String rid,
    String title,
    String link,
    String password,
    int day,
    TimeOfDay time,
  ) {
    var id = uuid.v4();
    db
      ..collection('rooms').doc(rid).collection('links').doc(id).set({
        'title': title,
        'link': link,
        'password': password == '' ? 'N/A' : password,
        'day': day,
        'time': time.toString(),
        'id': id,
        'type': [day, 'recurring']
      });
  }

  void addDay(
    User user,
    String title,
    String link,
    String password,
    int day,
    TimeOfDay time,
  ) {
    var id = uuid.v4();
    db.collection('users').doc(user.uid).collection('links').doc(id).set({
      'title': title,
      'link': link,
      'password': password == '' ? 'N/A' : password,
      'day': day,
      'time': time.toString(),
      'id': id,
      'type': [day, 'recurring']
    });
  }

  void deleteUselessInRoom(String rid) {
    String yesterday =
        DateTime.now().subtract(Duration(days: 2)).toString().split(' ')[0];

    db.collection('rooms').doc(rid).collection('links').get().then((value) {
      for (var doc in value.docs) {
        if (doc.data()['date'].toString().split(' ')[0].compareTo(yesterday) ==
            -1) {
          doc.reference.delete();
        }
      }
    });
  }

  void deleteUseless(User user) {
    String yesterday =
        DateTime.now().subtract(Duration(days: 1)).toString().split(' ')[0];

    db
        .collection('users')
        .doc(user.uid)
        .collection('links')
        .get()
        .then((value) {
      for (var doc in value.docs) {
        if (doc.data()['date'].toString().split(' ')[0].compareTo(yesterday) ==
            -1) {
          doc.reference.delete();
        }
      }
    });
  }

  void deleteRRecurring(String rid, String id) {
    db.collection('rooms').doc(rid).collection('links').doc(id).delete();
  }

  void deleteRecurring(User user, String id) {
    db.collection('users').doc(user.uid).collection('links').doc(id).delete();
  }

  void deleteRNonRecurring(String rid, String id) {
    db.collection('rooms').doc(rid).collection('links').doc(id).delete();
  }

  void deleteNonRecurring(
    User user,
    String id,
  ) {
    db.collection('users').doc(user.uid).collection('links').doc(id).delete();
  }
}
