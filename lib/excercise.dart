import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/bodyPart.dart';
import 'package:flutter_application_1/session.dart';

class ExcerciseWidget extends StatefulWidget {
  const ExcerciseWidget(
      {super.key,
      required this.excercise,
      required this.duration,
      required this.addExcerciseInfo,
      required this.excerciseInfo});
  final Excercise excercise;
  final Duration duration;
  final void Function(ExcerciseInfo) addExcerciseInfo;
  final ExcerciseInfo excerciseInfo;

  @override
  State<ExcerciseWidget> createState() => _ExcerciseWidgetState();
}

class _ExcerciseWidgetState extends State<ExcerciseWidget> {
  Excercise get excercise => widget.excercise;
  Duration get prevDuration => widget.duration;
  ExcerciseInfo get excerciseInfo => widget.excerciseInfo;
  void Function(ExcerciseInfo) get addExcerciseInfo => widget.addExcerciseInfo;
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
      addExcerciseInfo(ExcerciseInfo(excercise: excercise, sets: newSets));
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
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Icon(Icons.save)),
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
          : const Placeholder(),
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

  @override
  void initState() {
    super.initState();
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
      ],
    );
  }
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
  @override
  String toString() {
    return "Set: $reps reps, $weight kg";
  }
}