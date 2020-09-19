import 'package:day_selector/day_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:online_class_reminder/Non_Recurring.dart';
import 'package:online_class_reminder/Recurring.dart';
import 'package:online_class_reminder/Services.dart';
import 'package:provider/provider.dart';

class Links extends StatefulWidget {
  final User user;
  final day;
  Links(this.user, this.day);

  @override
  _LinksState createState() => _LinksState();
}

class _LinksState extends State<Links> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    List _children = [
      Recurring(widget.user, widget.day),
      NonReccuring(widget.user),
    ];
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.black,
          title: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              'Links',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.normal),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
            showUnselectedLabels: false,
            backgroundColor: Color.fromRGBO(25, 25, 25, 1),
            currentIndex: _currentIndex,
            onTap: onTabTapped,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.repeat,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Recurring',
                    style: TextStyle(color: Colors.white),
                  )),
              BottomNavigationBarItem(
                  icon: Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  title: Text(
                    'Non Recurring',
                    style: TextStyle(color: Colors.white),
                  )),
            ]),
        body: _children[_currentIndex],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          elevation: 0,
          backgroundColor: Colors.white,
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddLinks(widget.user)));
          },
          child: Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

class AddLinks extends StatefulWidget {
  final User user;

  AddLinks(this.user);
  @override
  _AddLinksState createState() => _AddLinksState();
}

class _AddLinksState extends State<AddLinks> {
  final titleController = TextEditingController();
  final linkController = TextEditingController();
  final passwordController = TextEditingController();
  bool recurring = false;
  DateTime initialDate = DateTime.now();
  Map<String, dynamic> selectedDate = {};
  List<Map<String, dynamic>> selectedDays = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.black,
        title: Text(
          'Add',
          style: TextStyle(
              color: Colors.white, fontSize: 42, fontWeight: FontWeight.normal),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {
          if (recurring == false) {
            Provider.of<Services>(context, listen: false).addDate(
                widget.user,
                titleController.text,
                linkController.text,
                passwordController.text,
                selectedDate['date'],
                selectedDate['time']);

            Navigator.of(context).pop();
          }
          if (recurring == true) {
            for (Map map in selectedDays) {
              Provider.of<Services>(context, listen: false).addDay(
                  widget.user,
                  titleController.text,
                  linkController.text,
                  passwordController.text,
                  map['day'],
                  map['dDay'],
                  map['time'],
                  map['week']);
            }
            Provider.of<Services>(context, listen: false)
                .addToToday(widget.user);
            Navigator.of(context).pop();
          }
        },
        backgroundColor: Colors.white,
        child: Icon(
          Icons.done,
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Theme(
                  data: ThemeData(unselectedWidgetColor: Colors.white),
                  child: CheckboxListTile(
                    activeColor: Colors.white,
                    checkColor: Colors.black,
                    value: recurring,
                    onChanged: (bool newValue) {
                      setState(() {
                        recurring = newValue;
                      });
                    },
                    title: Text(
                      'Recurring Meeting',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: titleController,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(color: Colors.white),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: linkController,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Link',
                      labelStyle: TextStyle(color: Colors.white),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: passwordController,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password (Optional)',
                      labelStyle: TextStyle(color: Colors.white),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70)),
                    ),
                  ),
                ),
                if (!recurring)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: MaterialButton(
                        onPressed: () => _selectDate(context),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.black,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              if (selectedDate.length == 0)
                                Text(
                                  'Select Date and Time',
                                  style: TextStyle(fontSize: 16),
                                ),
                              if (selectedDate.length > 0)
                                Text(
                                  "${selectedDate['date'].toLocal()}"
                                          .split(' ')[0] +
                                      '  |  ' +
                                      "${selectedDate['time']}"
                                          .split('(')[1]
                                          .split(')')[0],
                                  style: TextStyle(fontSize: 16),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (recurring)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: MaterialButton(
                        onPressed: () => _selectDay(context),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: Colors.black,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                'Add Day and Time',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (selectedDays.length > 0)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectedDays.length,
                    itemBuilder: (context, index) => Center(
                      child: MaterialButton(
                        onPressed: () {},
                        color: Colors.white,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "${selectedDays[index]['day']}" +
                                  '  |  ' +
                                  "${selectedDays[index]['time']}"
                                      .split('(')[1]
                                      .split(')')[0],
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ]),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: initialDate,
        lastDate: DateTime(2101));

    final TimeOfDay pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedDate != null && pickedTime != null) {
      setState(() {
        selectedDate['date'] = pickedDate;
        selectedDate['time'] = pickedTime;
      });
    }
  }

  Future<void> _selectDay(BuildContext context) async {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
        backgroundColor: Color.fromRGBO(240, 240, 240, 1),
        elevation: 2,
        context: context,
        builder: (context) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Select a Day',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Theme(
                        data: ThemeData(accentColor: Colors.white),
                        child: DaySelector(
                          value: null,
                          mode: DaySelector.modeFull,
                          color: Colors.white,
                          onChange: (value) async {
                            Navigator.pop(context);
                            final TimeOfDay pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (value != null && pickedTime != null) {
                              String day;
                              Day dDay;
                              int week;
                              if (DaySelector.monday & value ==
                                  DaySelector.monday) {
                                day = 'Monday';
                                dDay = Day.Monday;
                                week = 1;
                              }
                              if (DaySelector.tuesday & value ==
                                  DaySelector.tuesday) {
                                day = 'Tuesday';
                                dDay = Day.Tuesday;
                                week = 2;
                              }
                              if (DaySelector.wednesday & value ==
                                  DaySelector.wednesday) {
                                day = 'Wednesday';
                                dDay = Day.Wednesday;
                                week = 3;
                              }
                              if (DaySelector.thursday & value ==
                                  DaySelector.thursday) {
                                day = 'Thursday';
                                dDay = Day.Thursday;
                                week = 4;
                              }
                              if (DaySelector.friday & value ==
                                  DaySelector.friday) {
                                day = 'Friday';
                                dDay = Day.Friday;
                                week = 5;
                              }
                              if (DaySelector.saturday & value ==
                                  DaySelector.saturday) {
                                day = 'Saturday';
                                dDay = Day.Saturday;
                                week = 6;
                              }
                              if (DaySelector.sunday & value ==
                                  DaySelector.sunday) {
                                day = 'Sunday';
                                dDay = Day.Sunday;
                                week = 7;
                              }
                              setState(() {
                                selectedDays.add({
                                  'day': day,
                                  'time': pickedTime,
                                  'dDay': dDay,
                                  'week': week
                                });
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }
}
