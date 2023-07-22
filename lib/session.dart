import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/bodyPart.dart';
import 'package:flutter_application_1/database.dart' as db;
import 'package:flutter_application_1/excercise.dart';
import 'package:flutter_application_1/main.dart';

class Session extends StatefulWidget {
  const Session({super.key, required this.selectedBodyParts});

  final List<String> selectedBodyParts;

  static String getAgo(int millis) {
    DateTime date = DateTime.now();
    int timePassed = ((date.millisecondsSinceEpoch - millis) / 1000).round();
    String lastWorkout = '';

    int hoursPassed = (timePassed / 3600).round();
    if (hoursPassed < 24) {
      return '${hoursPassed}h ago';
    }
    int daysPassed = (hoursPassed / 24).round();
    if (daysPassed < 7) {
      return '${daysPassed}d ago';
    }
    int weeksPassed = (daysPassed / 7).round();
    if (weeksPassed < 4) {
      return '${weeksPassed}w ago';
    }
    return lastWorkout;
  }

  @override
  State<Session> createState() => _SessionState();
}

String strDigits(int n) => n.toString().padLeft(2, '0');

class _SessionState extends State<Session> {
  List<String> get selectedBodyParts => widget.selectedBodyParts;
  List<BodyPartData> bodyPartData = [];
  List<ExcerciseInfo> excerciseInfo = [];
  Timer? timer;
  bool dialogOpen = false;
  Duration duration = const Duration(seconds: 0);
  @override
  void initState() {
    super.initState();
    duration = const Duration(seconds: 0);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        duration += const Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void addExcerciseInfo(ExcerciseInfo newExcerciseInfo, bool cancel) {
    setState(() {
      int index = excerciseInfo.indexWhere(
          (element) => element.excercise == newExcerciseInfo.excercise);
      if (index != -1) {
        if (cancel == true) {
          excerciseInfo.removeAt(index);
          return;
        }
        excerciseInfo[index] = newExcerciseInfo;
        return;
      }
      if (cancel == true) return;
      excerciseInfo.add(newExcerciseInfo);
    });
  }

  void addBodyPartData(BodyPartData newBodyPartData) {
    if (bodyPartData.contains(newBodyPartData)) {
      return;
    }
    bodyPartData.add(newBodyPartData);
  }

  List<Widget> getTabs() {
    List<Widget> tabs = [];
    for (var i = 0; i < selectedBodyParts.length; i++) {
      int totalExcercises = 0;
      if (bodyPartData.length > i) {
        for (var element in bodyPartData[i].excercises) {
          if (excerciseInfo.any((excerciseInfo) =>
              excerciseInfo.excercise.name == element.name)) {
            totalExcercises++;
          }
        }
      }
      String addon = '';
      if (totalExcercises > 0) {
        addon = '($totalExcercises)';
      }
      tabs.add(Tab(
        text: '${selectedBodyParts[i]} $addon',
      ));
    }
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: selectedBodyParts.length,
      animationDuration: const Duration(milliseconds: 500),
      initialIndex: 0,
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 100,
            elevation: 2,
            centerTitle: true,
            title: Column(
              children: [
                const Text(
                  "Session has started",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "${strDigits(duration.inHours.remainder(60))}h ${strDigits(duration.inMinutes.remainder(60))}m ${strDigits(duration.inSeconds.remainder(60))}s",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.stop, color: Colors.white),
                onPressed: () {
                  // Navigator.of(context).pop();
                  showAlertDialog(context, excerciseInfo, duration.inSeconds);
                },
              ),
            ],
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(45),
                child: Column(
                  children: [
                    TabBar(
                      tabs: <Widget>[
                        ...getTabs(),
                      ],
                      isScrollable: true,
                      labelPadding: EdgeInsets.symmetric(
                          horizontal:
                              (MediaQuery.of(context).size.width / 6) - 20),
                      indicatorColor: Colors.white,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withOpacity(0.7),
                      indicator: UnderlineTabIndicator(
                        borderSide:
                            const BorderSide(color: Colors.white, width: 2.25),
                        insets: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width / 4 - 30,
                            vertical: 0),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20)),
                      ),
                    )
                  ],
                )),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            backgroundColor: Colors.blue,
          ),
          body: TabBarView(
            children: <Widget>[
              for (var bodyPart in selectedBodyParts)
                BodyPart(
                    title: bodyPart,
                    duration: duration,
                    excerciseInfo: excerciseInfo,
                    addExcerciseInfo: addExcerciseInfo,
                    addBodyPartData: addBodyPartData,
                    bodyPartData: bodyPartData.firstWhere(
                        (element) => element.bodyPart == bodyPart,
                        orElse: () =>
                            BodyPartData(bodyPart: '', excercises: []))),
            ],
          )),
    );
  }

  showAlertDialog(
      BuildContext context, List<ExcerciseInfo> data, int duration) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget removeButton = TextButton(
      child: const Text("Remove"),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
    Widget saveButton = TextButton(
      child: const Text("Save"),
      onPressed: () {
        db.Session session = db.Session(
            date: DateTime.now().millisecondsSinceEpoch, duration: duration);
        session.excerciseInfo = data;
        db.Session.insertSession(session);
        print(session);
        setState(() {
          sessions.add(session);
        });
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Session Workout"),
      content: const Text(
          "You can choose to save the workout or remove it from the history."),
      actions: [
        cancelButton,
        removeButton,
        saveButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    // show the dialog
  }
}
