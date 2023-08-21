import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bodyPart.dart';
import 'package:flutter_application_1/history.dart';
import 'package:flutter_application_1/landing/charts.dart';
import 'package:flutter_application_1/notes.dart';
import 'package:flutter_application_1/session.dart';
import 'package:flutter_application_1/widgets/slider.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

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

  final Color textColor = const Color.fromARGB(255, 42, 5, 77);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 100,
          elevation: 0,
          centerTitle: true,
          title: Column(
            children: [
              Text(excercise.name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  )),
              Text(
                "${strDigits(duration.inHours.remainder(60))}h ${strDigits(duration.inMinutes.remainder(60))}m ${strDigits(duration.inSeconds.remainder(60))}s",
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor, size: 28),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: Container(
          child: ActionSlider.dual(
            borderWidth: 0,
            actionThresholdType: ThresholdType.release,
            backgroundBorderRadius: BorderRadius.circular(8.0),
            foregroundBorderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, 2), // changes position of shadow
              ),
            ],
            width: MediaQuery.of(context).size.width * 0.6,
            toggleColor: Colors.blue,
            backgroundColor: Colors.white,
            startChild: const Text('Remove',
                style: TextStyle(fontWeight: FontWeight.w700)),
            endChild: const Text('Save',
                style: TextStyle(fontWeight: FontWeight.w700)),
            successIcon: const Icon(Icons.check, color: Colors.white),
            failureIcon: const Icon(Icons.close, color: Colors.white),
            icon: Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: Transform.rotate(
                  angle: 0.0 * 3.14,
                  child: const Icon(Icons.arrow_forward_ios_outlined,
                      color: Colors.white, size: 18.0)),
            ),
            startAction: (controller) async {
              controller.success(); //starts success animation
              await Future.delayed(const Duration(seconds: 1));
              setState(() {
                addExcerciseInfo(excerciseInfo, true);
                checkApplied(false);
              });
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
              controller.reset();
            },
            endAction: (controller) async {
              controller.success(); //starts success animation
              await Future.delayed(const Duration(seconds: 1));
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
              controller.reset();
            },
          ),
        ),
      ),
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
                  excercise: [excercise],
                )
              : NotesWidget(name: excercise.name),
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
  int numberOfReps = 10;
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
        numberOfSets = excercise.sets.length;
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
    if (category == "Barbell" || category == "Dumbbell") return 2.5;
    if (category == "Machine") return 10;
    if (category == "Cable" || category == 'Bodyweight') return 5;
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
            child: Column(
              children: [
                Hero(
                  tag: 'excerciseIcon${excercise.excercise.name}',
                  child: SizedBox(
                    height: 175,
                    child: Image.network(excercise.excercise.getIconUrlColored),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 20)),
                InkWell(
                  onTap: () => {
                    showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.white,
                        builder: (context) {
                          return CustomBottomSlider(
                            init: numberOfSets.toDouble(),
                            max: 12,
                            formatUnit: (unit) => unit.toInt(),
                            min: 1,
                            label: 'Sets',
                            onChange: (val) {
                              setState(() {
                                numberOfSets = val.toInt();
                                if (numberOfSets < sets.length) {
                                  sets.removeRange(numberOfSets, sets.length);
                                }
                                selectEachRep = false;
                                selectEachWeight = false;
                                handleEachRep();
                                handleEachWeight();
                              });
                            },
                          );
                        })
                  },
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sets',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          numberOfSets.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.edit, color: Colors.white)
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 32,
                  color: Colors.grey[400],
                ),
                InkWell(
                  onTap: () => {
                    showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.white,
                        builder: (context) {
                          return CustomBottomSlider(
                            init: numberOfReps.toDouble(),
                            max: 30,
                            formatUnit: (unit) => unit.toInt(),
                            min: 1,
                            label: 'Reps',
                            onChange: (val) {
                              setState(() {
                                numberOfReps = val.toInt();
                                handleEachRep();
                              });
                            },
                          );
                        })
                  },
                  child: !selectEachRep
                      ? Ink(
                          padding: const EdgeInsets.only(
                              left: 18, right: 14, top: 14, bottom: 14),
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Reps',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                numberOfReps.toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectEachRep = !selectEachRep;
                                          handleEachRep();
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(
                                          selectEachRep
                                              ? Icons.view_agenda
                                              : Icons.view_agenda_outlined,
                                          color: Colors.white,
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  const Icon(Icons.edit, color: Colors.white),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            for (int i = 0; i < sets.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: InkWell(
                                    onTap: () => {
                                          showModalBottomSheet(
                                              context: context,
                                              backgroundColor: Colors.white,
                                              builder: (context) {
                                                return CustomBottomSlider(
                                                  init: sets[i].reps.toDouble(),
                                                  max: 30,
                                                  formatUnit: (unit) =>
                                                      unit.toInt(),
                                                  min: 1,
                                                  label: 'Reps',
                                                  onChange: (val) {
                                                    setState(() {
                                                      sets[i].reps =
                                                          val.toInt();
                                                    });
                                                  },
                                                );
                                              })
                                        },
                                    child: Ink(
                                      padding: const EdgeInsets.only(
                                          left: 18,
                                          right: 14,
                                          top: 14,
                                          bottom: 14),
                                      decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            i == 0
                                                ? 'Reps'
                                                : '${i + 1}${i == 1 ? 'nd' : i == 2 ? 'rd' : 'th'}',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            sets[i].reps.toString(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Row(
                                            children: [
                                              i == 0
                                                  ? InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          selectEachRep =
                                                              !selectEachRep;
                                                          handleEachRep();
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(6.0),
                                                        child: Icon(
                                                          selectEachRep
                                                              ? Icons
                                                                  .view_agenda
                                                              : Icons
                                                                  .view_agenda_outlined,
                                                          color: Colors.white,
                                                        ),
                                                      ))
                                                  : const SizedBox(
                                                      width: 22,
                                                    ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              const Icon(Icons.edit,
                                                  color: Colors.white),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )),
                              )
                          ],
                        ),
                ),
                Divider(
                  height: 32,
                  color: Colors.grey[400],
                ),
                InkWell(
                  onTap: () => {
                    showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.white,
                        builder: (context) {
                          return CustomBottomSlider(
                            init: numberOfWeight!,
                            max: getMax().toInt(),
                            formatUnit: (unit) => unit,
                            min: getMin().toInt(),
                            interval: 0.5,
                            label: 'kg',
                            onChange: (val) {
                              setState(() {
                                numberOfWeight = val;
                                handleEachWeight();
                              });
                            },
                          );
                        })
                  },
                  child: !selectEachWeight
                      ? Ink(
                          padding: const EdgeInsets.only(
                              left: 18, right: 14, top: 14, bottom: 14),
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Weight',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                numberOfWeight.toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectEachWeight = !selectEachWeight;
                                          handleEachWeight();
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(
                                          selectEachWeight
                                              ? Icons.view_agenda
                                              : Icons.view_agenda_outlined,
                                          color: Colors.white,
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  const Icon(Icons.edit, color: Colors.white),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            for (int i = 0; i < sets.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: InkWell(
                                    onTap: () => {
                                          showModalBottomSheet(
                                              context: context,
                                              backgroundColor: Colors.white,
                                              builder: (context) {
                                                return CustomBottomSlider(
                                                  init: sets[i].weight,
                                                  max: getMax().toInt(),
                                                  formatUnit: (unit) => unit,
                                                  min: getMin().toInt(),
                                                  label: 'kg',
                                                  interval: 0.5,
                                                  onChange: (val) {
                                                    setState(() {
                                                      sets[i].weight = val;
                                                    });
                                                  },
                                                );
                                              })
                                        },
                                    child: Ink(
                                      padding: const EdgeInsets.only(
                                          left: 18,
                                          right: 14,
                                          top: 14,
                                          bottom: 14),
                                      decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            i == 0
                                                ? 'Weight'
                                                : '${i + 1}${i == 1 ? 'nd' : i == 2 ? 'rd' : 'th'}',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            sets[i].weight.toString(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Row(
                                            children: [
                                              i == 0
                                                  ? InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          selectEachWeight =
                                                              !selectEachWeight;
                                                          handleEachWeight();
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(6.0),
                                                        child: Icon(
                                                          selectEachWeight
                                                              ? Icons
                                                                  .view_agenda
                                                              : Icons
                                                                  .view_agenda_outlined,
                                                          color: Colors.white,
                                                        ),
                                                      ))
                                                  : const SizedBox(
                                                      width: 22,
                                                    ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              const Icon(Icons.edit,
                                                  color: Colors.white),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )),
                              )
                          ],
                        ),
                )
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
            )),
        SizedBox(
          height: latestWorkout == null ? 0 : 100,
        )
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

  static Future<void> updateNotes(String newNotes, String name) async {
    final db = await database;
    if (db == null) return;
    await db.insert(
        'Notes',
        {
          'excerciseName': name,
          'note': newNotes,
          'date': DateTime.now().millisecondsSinceEpoch
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<String> excerciseNotes(String name) async {
    final db = await database;
    if (db == null) return '';
    final List<Map<String, dynamic>> nMap = await db.query(
      'Notes',
      where: 'excerciseName = ?',
      whereArgs: [name],
    );

    String notes = '';
    for (var item in nMap) {
      notes += item['note'] ?? '';
    }
    return notes;
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

  //create a function that returns the date in a string format
  static String getDate(int ms) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${date.hour}:${date.minute}';
  }

  static Future<ExcerciseSpikeLine?> getExcercisesEffort(String sName) async {
    final db = await database;
    if (db == null) return Future.value(null);
    List<ExcerciseChart> fr = await excercisesFrequent();
    final List<Map<String, dynamic>> sMap = await db.query('Session');
    ExcerciseSpikeLine? line;
    for (var item in sMap) {
      final List<Map<String, dynamic>> eMap = await db.query('excerciseInfo',
          where: 'sessionId = ?', whereArgs: [item['id']]);
      for (var eItem in eMap) {
        List<String> words = eItem['excerciseName'].toString().split(' ');
        String name = words.sublist(0, min(5, words.length)).join(' ');
        if (!fr.any((element) => element.name == name) || name != sName) {
          continue;
        }
        final List<Map<String, dynamic>> setMap = await db.query('Sets',
            where: 'excerciseInfoId = ?', whereArgs: [eItem['id']]);
        double effort = 0;
        double weight = 0;
        double reps = 0;
        for (var s in setMap) {
          effort += (s['reps'] * 0.75) * s['weight'];
          weight += s['weight'];
          reps += s['reps'];
        }
        line ??= ExcerciseSpikeLine(name);
        line.weeklyInfo.add(ExcerciseSpikeLineWeeklyInfo(item['date'], effort,
            weight / setMap.length, reps / setMap.length));
      }
    }

    return line;
  }

  static Future<List<ExcerciseChart>> excercisesFrequent() async {
    final db = await database;
    if (db == null) return [];
    final List<Map<String, dynamic>> eMap = await db.query('excerciseInfo');
    Map<String, int> dataMap = {};
    for (var item in eMap) {
      List<String> words = item['excerciseName'].toString().split(' ');
      String name = words.sublist(0, min(5, words.length)).join(' ');
      if (!dataMap.containsKey(name)) {
        dataMap.putIfAbsent(name, () => 1);
        continue;
      }
      dataMap.update(name, (value) => value + 1);
    }
    if (dataMap.length > 5) {
      List<MapEntry<String, int>> li = dataMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return li
          .sublist(0, 5)
          .map((e) => ExcerciseChart(e.key, e.value))
          .toList();
    }
    return dataMap.entries.map((e) => ExcerciseChart(e.key, e.value)).toList();
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
