import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';

class Services with ChangeNotifier {
  final db = FirebaseFirestore.instance;
  bool recurring = false;
  final uuid = Uuid();
  List<Map> todayList = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  void changeRecurring(bool newValue) {
    recurring = newValue;
    notifyListeners();
  }

  void addToToday(User user) {
    String day;
    todayList.clear();
    if (DateTime.now().weekday == 1) {
      day = 'Monday';
    }
    if (DateTime.now().weekday == 2) {
      day = 'Tuesday';
    }
    if (DateTime.now().weekday == 3) {
      day = 'Wednesday';
    }
    if (DateTime.now().weekday == 4) {
      day = 'Thursday';
    }
    if (DateTime.now().weekday == 5) {
      day = 'Friday';
    }
    if (DateTime.now().weekday == 6) {
      day = 'Saturday';
    }
    if (DateTime.now().weekday == 7) {
      day = 'Sunday';
    }
    db
        .collection(user.uid)
        .doc('nonRecurring')
        .collection('dates')
        .get()
        .then((value) {
      for (var document in value.docs) {
        if (document.data()['date'].toString().split(' ')[0] ==
            DateTime.now().toString().split(' ')[0]) {
          todayList.add(document.data());
        }
      }
    }).whenComplete(() {
      db
          .collection(user.uid)
          .doc('recurring')
          .collection(day)
          .get()
          .then((value) {
        for (var document in value.docs) {
          todayList.add(document.data());
        }
        todayList.sort(
            (a, b) => a['time'].toString().compareTo(b['time'].toString()));
        notifyListeners();
      });
    });
  }

  void addDate(User user, String title, String link, String password,
      DateTime date, TimeOfDay time) {
    String string = date.month.toString() +
        date.day.toString() +
        time.hour.toString() +
        time.minute.toString();
    var nid = int.parse(string);
    db
        .collection(user.uid)
        .doc('nonRecurring')
        .collection('dates')
        .doc(date.toString() + time.toString())
        .set({
      'title': title,
      'link': link,
      'password': password == '' ? 'N/A' : password,
      'date': date.toString(),
      'time': time.toString(),
      'nid': nid
    });
    addToToday(user);
    showNotifOnce(nid, title, date, time);
  }

  void addDay(User user, String title, String link, String password, String day,
      Day dDay, TimeOfDay time, int week) {
    var id = uuid.v4();
    var string =
        week.toString() + time.hour.toString() + time.minute.toString();
    var nid = int.parse(string);
    db.collection(user.uid).doc('recurring').collection(day).doc(id).set({
      'title': title,
      'link': link,
      'password': password == '' ? 'N/A' : password,
      'day': day,
      'time': time.toString(),
      'id': id,
      'nid': nid
    });
    showNotifWeekly(nid, title, dDay, time);
  }

  void deleteUseless(User user) {
    String yesterday =
        DateTime.now().subtract(Duration(days: 1)).toString().split(' ')[0];
    db
        .collection(user.uid)
        .doc('nonRecurring')
        .collection('dates')
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

  void deleteRecurring(User user, String day, String id, int nid) {
    db.collection(user.uid).doc('recurring').collection(day).doc(id).delete();
    addToToday(user);
    FlutterLocalNotificationsPlugin().cancel(nid);
  }

  void deleteNonRecurring(User user, String id, int nid) {
    db
        .collection(user.uid)
        .doc('nonRecurring')
        .collection('dates')
        .doc(id)
        .delete();
    addToToday(user);
    FlutterLocalNotificationsPlugin().cancel(nid);
  }

  void init() {
    var androidInit = AndroidInitializationSettings('ic_stat_name');
    var iosInit = IOSInitializationSettings();
    var generalInitSettings = InitializationSettings(androidInit, iosInit);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(
      generalInitSettings,
    );
  }

  Future showNotifOnce(
    int id,
    String title,
    DateTime pickedDate,
    TimeOfDay pickedTime,
  ) async {
    init();
    var year = pickedDate.year;
    var month = pickedDate.month;
    var date = pickedDate.day;
    var hour = pickedTime.hour;
    var minute = pickedTime.minute;
    DateTime scheduledDateTime = DateTime(year, month, date, hour, minute);
    var androidDetails = AndroidNotificationDetails(
        'reminders', 'Reminders', 'Meeting Reminders',
        color: Colors.cyan,
        importance: Importance.High,
        priority: Priority.High,
        playSound: true,
        enableVibration: true);
    var iosDetails = IOSNotificationDetails();
    var generalDetails = NotificationDetails(androidDetails, iosDetails);

    await flutterLocalNotificationsPlugin.schedule(
        id, title, '$title is about Start', scheduledDateTime, generalDetails,
        androidAllowWhileIdle: true);
  }

  Future showNotifWeekly(
    int id,
    String title,
    Day dDay,
    TimeOfDay pickedTime,
  ) async {
    init();
    var hour = pickedTime.hour;
    var minute = pickedTime.minute;
    Time time = Time(hour, minute);
    var androidDetails = AndroidNotificationDetails(
        'reminders', 'Reminders', 'Meeting Reminders',
        color: Colors.cyan,
        importance: Importance.High,
        priority: Priority.High,
        playSound: true,
        enableVibration: true);
    var iosDetails = IOSNotificationDetails();
    var generalDetails = NotificationDetails(androidDetails, iosDetails);

    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
      id,
      title,
      'Click to Join',
      dDay,
      time,
      generalDetails,
    );
  }
}
