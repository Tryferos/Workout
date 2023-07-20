import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/bodyPart.dart';
import 'package:flutter_application_1/history.dart';
import 'package:flutter_application_1/notes.dart';
import 'package:flutter_application_1/session.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

class ExcerciseWidget extends StatefulWidget {
  const ExcerciseWidget(
      {super.key,
      required this.excercise,
      required this.duration,
      required this.addExcerciseInfo,
      required this.checkApplied,
      required this.excerciseInfo});
  final Excercise excercise;
  final Duration duration;
  final void Function(bool) checkApplied;
  final void Function(ExcerciseInfo, bool) addExcerciseInfo;
  final ExcerciseInfo excerciseInfo;

  @override
  State<ExcerciseWidget> createState() => _ExcerciseWidgetState();
}

class _ExcerciseWidgetState extends State<ExcerciseWidget> {
  Excercise get excercise => widget.excercise;
  Duration get prevDuration => widget.duration;
  ExcerciseInfo get excerciseInfo => widget.excerciseInfo;
  void Function(ExcerciseInfo, bool) get addExcerciseInfo =>
      widget.addExcerciseInfo;
  void Function(bool) get checkApplied => widget.checkApplied;
  Duration duration = const Duration(seconds: 0);
  int currentIndex = 0;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    duration = prevDuration;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        duration += const Duration(seconds: 1);
      });
    });
  }

  void editSets(List<Set> newSets) {
    setState(() {
      addExcerciseInfo(
          ExcerciseInfo(excercise: excercise, sets: newSets), false);
      checkApplied(newSets.isNotEmpty);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 2,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              excercise.name,
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              "${strDigits(duration.inHours.remainder(60))}h ${strDigits(duration.inMinutes.remainder(60))}m ${strDigits(duration.inSeconds.remainder(60))}s",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.blue,
      ),
      persistentFooterButtons: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        addExcerciseInfo(excerciseInfo, true);
                        checkApplied(false);
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Remove',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    )),
              ],
            ),
          ),
        ),
      ],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 4,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedFontSize: 15,
        unselectedFontSize: 13,
        backgroundColor: Colors.blue,
        currentIndex: currentIndex,
        onTap: (index) {
          currentIndex = index;
        },
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 30),
        unselectedIconTheme:
            const IconThemeData(color: Colors.white70, size: 26),
        items: const [
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.sports_gymnastics_sharp),
            label: 'Sets',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.notes_sharp), label: 'Notes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_sharp), label: 'History'),
        ],
      ),
      body: currentIndex == 0
          ? ExcerciseInputs(
              category: excercise.category,
              editSets: editSets,
              excercise: excerciseInfo)
          : currentIndex == 2
              ? ExcerciseHistoryWidget(
                  excercise: excercise,
                )
              : const NotesWidget(),
    );
  }
}

class ExcerciseInputs extends StatefulWidget {
  const ExcerciseInputs(
      {super.key,
      required this.excercise,
      required this.category,
      required this.editSets});

  final ExcerciseInfo excercise;
  final String category;
  final void Function(List<Set>) editSets;

  @override
  State<ExcerciseInputs> createState() => _ExcerciseInputsState();
}

class _ExcerciseInputsState extends State<ExcerciseInputs> {
  ExcerciseInfo get excercise => widget.excercise;
  void Function(List<Set>) get editSets => widget.editSets;
  List<Set> sets = [];
  int numberOfSets = 4;
  double? numberOfWeight;
  int numberOfReps = 12;
  bool selectEachRep = false;
  bool selectEachWeight = false;
  String get category => widget.category;
  ExcerciseInfo? latestWorkout;

  @override
  void initState() {
    super.initState();
    try {
      latestWorkout = sessions
          .where((el) => el.excerciseInfo!
              .where((element) =>
                  element.excercise.name == excercise.excercise.name)
              .isNotEmpty)
          .first
          .excerciseInfo!
          .where(
              (element) => element.excercise.name == excercise.excercise.name)
          .first;
    } catch (e) {
      latestWorkout = null;
    }
    setState(() {
      if (excercise.sets.isNotEmpty) {
        numberOfReps = excercise.sets[0].reps;
        numberOfWeight = excercise.sets[0].weight;
      } else {
        numberOfWeight = getMin();
      }
      selectEachRep = excercise.eachRepIsDifferent;
      if (excercise.eachRepIsDifferent == true ||
          excercise.eachWeightIsDifferent == true) {
        sets = excercise.sets;
      }
      selectEachWeight = excercise.eachWeightIsDifferent;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handleEachRep() {
    if (selectEachRep == true) {
      for (var i = 0; i < numberOfSets; i++) {
        if (i >= sets.length) {
          sets.add(Set(reps: numberOfReps, weight: numberOfWeight!));
        }
      }
    } else {
      for (var i = 0; i < numberOfSets; i++) {
        if (sets.length <= i) {
          sets.add(Set(reps: numberOfReps, weight: numberOfWeight!));
        }
        sets[i].reps = numberOfReps;
      }
    }
    editSets(sets);
  }

  void handleEachWeight() {
    if (selectEachWeight == true) {
      for (var i = 0; i < numberOfSets; i++) {
        if (i >= sets.length) {
          sets.add(Set(reps: numberOfReps, weight: numberOfWeight!));
        }
      }
    } else {
      for (var i = 0; i < numberOfSets; i++) {
        if (sets.length <= i) {
          sets.add(Set(reps: numberOfReps, weight: numberOfWeight!));
        }
        sets[i].weight = numberOfWeight!;
      }
    }
    editSets(sets);
  }

  double getIncrement() {
    if (category == "Barbell" ||
        category == "Bodyweight" ||
        category == "Dumbbell") return 2.5;
    if (category == "Machine") return 10;
    if (category == "Cable") return 5;
    return 1;
  }

  double getMax() {
    if (category == "Dumbbell") return 25;
    if (category == "Machine") return 100;
    if (category == "Cable") return 60;
    if (category == "Bodyweight") return 50;
    if (category == "Barbell") return 100;
    return 1;
  }

  double getMin() {
    if (category == "Dumbbell") return 5;
    if (category == "Machine") return 20;
    if (category == "Cable") return 5;
    if (category == "Bodyweight") return 0;
    if (category == "Barbell") return 10;
    return 1;
  }

  List<DropdownMenuItem<double>> getWeight() {
    List<DropdownMenuItem<double>> weight = [];
    double increment = getIncrement();
    for (var i = getMin(); i <= getMax(); i += increment) {
      weight.add(DropdownMenuItem(
        value: i,
        child: Text(i.toString()),
      ));
    }
    return weight;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      addAutomaticKeepAlives: false,
      scrollDirection: Axis.vertical,
      children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
            decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: Colors.grey, width: 0.3))),
            child: Column(
              children: [
                const Text(
                  'Select number of Sets',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  numberOfSets.toString(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Slider(
                  min: 1,
                  max: 12,
                  thumbColor: Colors.blue,
                  activeColor: Colors.blue.withOpacity(0.7),
                  value: numberOfSets.toDouble(),
                  onChanged: (val) {
                    setState(() {
                      numberOfSets = val.toInt();
                    });
                  },
                ),
              ],
            )),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.3)),
            child: Column(
              children: [
                const Text(
                  'Select number of reps',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                selectEachRep == true
                    ? Center(
                        child: GridView.count(
                          crossAxisCount: 5,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 4,
                          shrinkWrap: true,
                          children: [
                            for (var i = 0; i < numberOfSets; i++)
                              DropdownButton(
                                items: [
                                  for (var i = 4; i < 16; i++)
                                    DropdownMenuItem(
                                      value: i,
                                      child: Text(i.toString()),
                                    )
                                ],
                                onChanged: (newVal) {
                                  setState(() {
                                    sets[i].reps = newVal as int;
                                    editSets(sets);
                                  });
                                },
                                value: sets[i].reps,
                              ),
                          ],
                        ),
                      )
                    : DropdownButton(
                        items: [
                          for (var i = 4; i < 16; i++)
                            DropdownMenuItem(
                              value: i,
                              child: Text(i.toString()),
                            )
                        ],
                        onChanged: (newVal) {
                          setState(() {
                            numberOfReps = newVal as int;
                            handleEachRep();
                          });
                        },
                        value: numberOfReps,
                      ),
                Container(
                    alignment: Alignment.bottomRight,
                    transform: Matrix4.translationValues(10, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Select reps for each set',
                            style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 141, 138, 138))),
                        Checkbox(
                          checkColor: Colors.white,
                          fillColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.blue),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: const BorderSide(color: Colors.blue)),
                          value: selectEachRep,
                          onChanged: (n) {
                            setState(() {
                              selectEachRep = n!;
                              handleEachRep();
                            });
                          },
                        ),
                      ],
                    ))
              ],
            )),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.3)),
            child: Column(
              children: [
                const Text(
                  'Select weight in kg',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                selectEachWeight == true
                    ? Center(
                        child: GridView.count(
                          crossAxisCount: 5,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 4,
                          shrinkWrap: true,
                          children: [
                            for (var i = 0; i < numberOfSets; i++)
                              DropdownButton(
                                items: <DropdownMenuItem<double>>[
                                  ...getWeight()
                                ],
                                onChanged: (newVal) {
                                  setState(() {
                                    sets[i].weight = newVal as double;
                                  });
                                },
                                value: sets[i].weight,
                              )
                          ],
                        ),
                      )
                    : DropdownButton(
                        items: <DropdownMenuItem<double>>[...getWeight()],
                        onChanged: (newVal) {
                          setState(() {
                            numberOfWeight = newVal as double;
                            handleEachWeight();
                          });
                        },
                        value: numberOfWeight,
                      ),
                Container(
                    alignment: Alignment.bottomRight,
                    transform: Matrix4.translationValues(10, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Select weight for each set',
                            style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 141, 138, 138))),
                        Checkbox(
                          checkColor: Colors.white,
                          fillColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.blue),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: const BorderSide(color: Colors.blue)),
                          value: selectEachWeight,
                          onChanged: (n) {
                            setState(() {
                              selectEachWeight = n!;
                              handleEachWeight();
                            });
                          },
                        ),
                      ],
                    ))
              ],
            )),
        Opacity(
            opacity: latestWorkout == null ? 0 : 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                icon: const Icon(Icons.settings, color: Colors.blue),
                label: const Text("Select latest workout's preset",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
                onPressed: () {
                  setState(() {
                    sets = latestWorkout!.sets;
                    numberOfSets = sets.length;
                    numberOfReps = sets[0].reps;
                    numberOfWeight = sets[0].weight;
                    selectEachRep = latestWorkout!.eachRepIsDifferent;
                    selectEachWeight = latestWorkout!.eachWeightIsDifferent;
                    editSets(sets);
                  });
                },
              ),
            ))
      ],
    );
  }
}

class ExcerciseHistory {
  ExcerciseHistory({required this.date, required this.sets});
  final List<Set> sets;
  final int date;
}

class ExcerciseInfo {
  final Excercise excercise;
  final List<Set> sets;
  final bool isDone = false;
  ExcerciseInfo({required this.excercise, required this.sets});
  bool get eachRepIsDifferent {
    if (sets.length <= 1) return false;
    for (var i = 0; i < sets.length; i++) {
      for (var set in sets) {
        if (set == sets[i]) continue;
        if (set.reps != sets[i].reps) return true;
      }
    }
    return false;
  }

  static bool isEachRepDifferent(List<Set> sets) {
    if (sets.length <= 1) return false;
    for (var i = 0; i < sets.length; i++) {
      for (var set in sets) {
        if (set == sets[i]) continue;
        if (set.reps != sets[i].reps) return true;
      }
    }
    return false;
  }

  static bool isEachWeightDifferent(List<Set> sets) {
    if (sets.length <= 1) return false;
    for (var i = 0; i < sets.length; i++) {
      for (var set in sets) {
        if (set == sets[i]) continue;
        if (set.weight != sets[i].weight) return true;
      }
    }
    return false;
  }

  bool get eachWeightIsDifferent {
    if (sets.length <= 1) return false;
    for (var i = 0; i < sets.length; i++) {
      for (var set in sets) {
        if (set == sets[i]) continue;
        if (set.weight != sets[i].weight) return true;
      }
    }
    return false;
  }

  Map<String, dynamic> toMap(int sessionId) {
    return {
      'excerciseName': excercise.name,
      'sessionId': sessionId,
    };
  }

  static Future<Excercise> fetchExcercise(String name) async {
    final res = await http.get(Uri.parse(
        'https://strengthlevel.com/api/exercises?limit=64&exercise.fields=category,name_url,bodypart,name,count,aliases,icon_url&name=$name&standard=yes'));
    if (res.statusCode == 200) {
      Excercise data = Excercise.fromJson(jsonDecode(res.body));
      return data;
    } else {
      throw Exception('Failed to load excercise data');
    }
  }

  static Future<List<ExcerciseHistory>> excercisesInfoHistory(
      String name) async {
    final db = await database;
    if (db == null) return [];
    final List<Map<String, dynamic>> eMap = await db.query(
      'excerciseInfo',
      where: 'excerciseName = ?',
      whereArgs: [name],
    );

    List<ExcerciseHistory> excerciseHistory = [];

    for (var e in eMap) {
      final List<Map<String, dynamic>> smap = await db
          .query('session', where: 'id = ?', whereArgs: [e['sessionId']]);
      print(smap);
      final List<Map<String, dynamic>> setMap = await db
          .query('Sets', where: 'excerciseInfoId = ?', whereArgs: [e['id']]);
      int date = setMap.isNotEmpty ? smap[0]['date'] : 0;
      List<Set> sets = [];
      for (var s in setMap) {
        sets.add(Set(reps: s['reps'], weight: s['weight']));
      }
      excerciseHistory.add(ExcerciseHistory(date: date, sets: sets));
    }
    return excerciseHistory;
  }

  static Future<List<ExcerciseInfo>> excercisesInfo(int sessionId) async {
    final db = await database;
    if (db == null) return [];
    final List<Map<String, dynamic>> eMap = await db
        .query('excerciseInfo', where: 'sessionId = ?', whereArgs: [sessionId]);

    List<ExcerciseInfo> excercisesInfo = [];

    for (var e in eMap) {
      Excercise excercise = await fetchExcercise(e['excerciseName']);
      final List<Map<String, dynamic>> setMap = await db
          .query('Sets', where: 'excerciseInfoId = ?', whereArgs: [e['id']]);
      List<Set> sets = [];
      for (var s in setMap) {
        sets.add(Set(reps: s['reps'], weight: s['weight']));
      }
      excercisesInfo.add(ExcerciseInfo(excercise: excercise, sets: sets));
    }
    return excercisesInfo;
  }

  @override
  String toString() {
    return "ExcerciseInfo: ${excercise.name}, ${sets.toString()}";
  }
}

class Set {
  int reps;
  double weight;
  final int? rest;
  Set({required this.reps, required this.weight, this.rest});

  Map<String, dynamic> toMap(int excerciseInfoId) {
    return {
      'reps': reps,
      'weight': weight,
      'excerciseInfoId': excerciseInfoId,
    };
  }

  @override
  String toString() {
    return "Set: $reps reps, $weight kg";
  }
}
