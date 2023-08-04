import 'dart:math';

import 'package:circular_chart_flutter/circular_chart_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/landing/goalStepper.dart';

import '../database.dart';
import '../excercise.dart' as Excercise_Package;
import '../excercise.dart';
import '../main.dart';

class AllGoals extends StatefulWidget {
  const AllGoals({super.key, required this.refresh});

  final bool refresh;

  @override
  State<AllGoals> createState() => _AllGoalsState();
}

class _AllGoalsState extends State<AllGoals> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'All Goals',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: Column(
            children: [
              Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Uncompleted Goals',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FutureBuilder<List<Goal>>(
                      future: Goal.getGoals(true),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return const Text(
                              'You don\'t have any uncompleted goals. Create one!',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            );
                          }
                          return ListView.separated(
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data!.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) =>
                                snapshot.data![index].getGoalCard(context),
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                              height: 10,
                            ),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                  const SizedBox(
                    height: 40,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Completed Goals',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FutureBuilder<List<Goal>>(
                      future: Goal.getCompletedGoals(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return const Text(
                              'You don\'t have any completed goals yet. Be persistent and you will get there!',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            );
                          }
                          return ListView.separated(
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data!.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) =>
                                snapshot.data![index].getGoalCard(context),
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                              height: 10,
                            ),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                  const SizedBox(
                    height: 40,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Failed Goals',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FutureBuilder<List<Goal>>(
                      future: Goal.getFailedGoals(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return const Text(
                              'You don\'t have any failed goals 😁 Keep up the good work!',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            );
                          }
                          return ListView.separated(
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data!.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) =>
                                snapshot.data![index].getGoalCard(context),
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                              height: 10,
                            ),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                ],
              ),
            ],
          ),
        ));
  }
}

class WorkoutGoals extends StatefulWidget {
  const WorkoutGoals({super.key, required this.refresh});

  final bool refresh;

  @override
  State<WorkoutGoals> createState() => _WorkoutGoalsState();
}

class _WorkoutGoalsState extends State<WorkoutGoals> {
  Future<List<Goal>>? list;

  @override
  void initState() {
    super.initState();
    updateWidget();
  }

  @override
  void setState(void Function() fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void updateWidget() async {
    List<Goal> updatedList = await Goal.getGoals(false);
    setState(() {
      list = Future.value(updatedList);
    });
  }

  @override
  void didUpdateWidget(WorkoutGoals oldWidget) {
    super.didUpdateWidget(oldWidget);
    list = Future.value([]);
    updateWidget();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Goals',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AllGoals(
                              refresh: widget.refresh,
                            )),
                  );
                },
                child: const Text(
                  'See All',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue),
                )),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        FutureBuilder<List<Goal>>(
            future: list,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.separated(
                  itemCount: snapshot.data!.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) =>
                      snapshot.data![index].getGoalCard(context),
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 10,
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ],
    );
  }
}

class GoalCreation extends StatefulWidget {
  const GoalCreation({super.key});

  @override
  State<GoalCreation> createState() => _GoalCreationState();
}

class _GoalCreationState extends State<GoalCreation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create a new goal'),
          centerTitle: true,
        ),
        body: const Center(
          child: GoalStepperWidget(),
        ));
  }
}

enum GoalType { singleExcercise, multiExcercise, workouts }

abstract class Goal {
  Goal({required this.title, required this.date, required this.type});
  String title;
  int date;
  GoalType type;
  bool isCompleted();
  double getProgress();
  void writeGoal();
  Widget getGoalCard(BuildContext context);

  void removeGoal(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget removeButton = TextButton(
      child: const Text(
        "Remove",
      ),
      onPressed: () async {
        Navigator.of(context).pop();
        final db = await database;
        if (db == null) return;

        db.delete('Goals', where: 'date = ?', whereArgs: [date]);
      },
    );
    AlertDialog alert = AlertDialog(
      elevation: 5,
      title: const Text("Remove Goal"),
      content: const Text("Are you sure you want to remove this goal?"),
      actions: [
        cancelButton,
        removeButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static Excercise_Package.Set getSet(String name) {
    Excercise_Package.Set startingSet;
    try {
      Session s = sessions.firstWhere((element) =>
          element.excerciseInfo!.any((el) => el.excercise.name == name));
      ExcerciseInfo info = s.excerciseInfo!
          .firstWhere((element) => element.excercise.name == name);
      info.sets.sort(
        (a, b) => a.weight.compareTo(b.weight),
      );
      startingSet = info.sets.last;
    } catch (e) {
      startingSet = Excercise_Package.Set(reps: 12, weight: 0);
    }
    return startingSet;
  }

  static Future<List<Goal>> fetchAllGoals() async {
    final db = await database;
    if (db == null) return [];
    List<Map<String, dynamic>> goals =
        await db.query('Goals', orderBy: 'date DESC');
    List<Goal> goalList = [];
    for (var g in goals) {
      List<ExcerciseGoalItem> excercises = [];
      List<Map<String, dynamic>> excerciseGoals = await db
          .query('ExcerciseGoal', where: 'id = ?', whereArgs: [g['id']]);
      if (excerciseGoals.isEmpty) {
        List<Map<String, dynamic>> workoutGoals = await db
            .query('WorkoutGoal', where: 'goalId = ?', whereArgs: [g['id']]);
        if (workoutGoals.isEmpty) continue;
        goalList.add(WorkoutGoal(
          title: g['title'],
          date: DateTime.fromMillisecondsSinceEpoch(g['date']),
          number: workoutGoals[0]['number'],
          untilDate:
              DateTime.fromMillisecondsSinceEpoch(workoutGoals[0]['untilDate']),
        ));
        continue;
      }
      for (var e in excerciseGoals) {
        List<Map<String, dynamic>> excerciseItems = await db.query(
            'GoalExcerciseItem',
            where: 'id = ?',
            whereArgs: [e['goalExcerciseItemId']]);
        for (var i in excerciseItems) {
          excercises.add(ExcerciseGoalItem(
            name: i['name'],
            bodyPart: i['bodyPart'],
            iconUrl: i['icon_url'],
            goalSet: Excercise_Package.Set(
              reps: i['goalReps'],
              weight: i['goalWeight'],
            ),
            startingSet: Excercise_Package.Set(
              reps: i['startingReps'],
              weight: i['startingWeight'],
            ),
          ));
        }
      }
      goalList.add(SingleExcerciseGoal(
          date: DateTime.fromMillisecondsSinceEpoch(g['date']),
          title: g['title'],
          excercise: excercises[0]));
    }
    return goalList;
  }

  static Future<List<Goal>> getGoals(bool getAll) async {
    List<Goal> goalList = await fetchAllGoals();
    goalList.sort((a, b) => b.getProgress().compareTo(a.getProgress()));
    goalList = goalList
        .where(
            (element) => !element.isCompleted() && element.getProgress() >= 0)
        .toList();
    return goalList.sublist(
        0, getAll == true ? goalList.length : min(2, goalList.length));
  }

  static Future<List<Goal>> getFailedGoals() async {
    return (await fetchAllGoals())
        .where((element) => element.getProgress() < 0)
        .toList();
  }

  static Future<List<Goal>> getCompletedGoals() async {
    return (await fetchAllGoals())
        .where((element) => element.isCompleted())
        .toList();
  }
}

class WorkoutGoal extends Goal {
  WorkoutGoal(
      {required String title,
      required DateTime date,
      required this.number,
      required this.untilDate})
      : super(
            title: title,
            date: date.millisecondsSinceEpoch,
            type: GoalType.workouts);
  int number;
  DateTime untilDate;

  bool hasPassedDate() {
    return DateTime.now().isAfter(untilDate);
  }

  int getDaysLeft() {
    return untilDate.difference(DateTime.now()).inDays;
  }

  @override
  Widget getGoalCard(BuildContext context) {
    return ListTile(
      onLongPress: () {
        super.removeGoal(context);
      },
      shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey, width: 0.75),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      title: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      subtitle: Text(
          '$number total | ${getDaysLeft() < 0 ? 'was due ${getDaysLeft().abs()}d ago' : '${getDaysLeft()}d left'}',
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 134, 131, 131))),
      trailing: getProgress() < 0
          ? Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Container(
                height: 55,
                width: 55,
                decoration: const BoxDecoration(
                    border: Border.fromBorderSide(
                        BorderSide(color: Colors.red, width: 2)),
                    borderRadius: BorderRadius.all(Radius.circular(100))),
                child: const Icon(Icons.remove_circle, color: Colors.red),
              ))
          : getProgress() < 1
              ? AnimatedCircularChart(
                  percentageValues: true,
                  holeRadius: 24,
                  duration: const Duration(milliseconds: 500),
                  holeLabel: '${(getProgress() * 100).toStringAsFixed(1)}%',
                  key: const Key('chart'),
                  size: const Size(65.0, 65.0),
                  initialChartData: <CircularStackEntry>[
                    CircularStackEntry(
                      <CircularSegmentEntry>[
                        CircularSegmentEntry(
                          getProgress() * 100,
                          getProgress() < 0
                              ? Colors.red[400]
                              : getProgress() >= 1
                                  ? Colors.green[500]
                                  : Colors.blue[400],
                          rankKey: 'completed',
                        ),
                        CircularSegmentEntry(
                          (100 - (getProgress() * 100)),
                          const Color.fromARGB(255, 227, 231, 233),
                          rankKey: 'remaining',
                        ),
                      ],
                      rankKey: 'progress',
                    ),
                  ],
                  chartType: CircularChartType.Radial,
                )
              : Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Container(
                      height: 55,
                      width: 55,
                      decoration: const BoxDecoration(
                          border: Border.fromBorderSide(
                              BorderSide(color: Colors.green, width: 2)),
                          borderRadius: BorderRadius.all(Radius.circular(100))),
                      child: const Icon(Icons.check, color: Colors.green)),
                ),
      leading: const Icon(Icons.fitness_center_outlined),
    );
  }

  @override
  void writeGoal() async {
    final db = await database;
    if (db == null) return;
    int id = await db.insert('Goals', {
      'title': title,
      'date': date,
    });
    await db.insert('WorkoutGoal', {
      'number': number,
      'untilDate': untilDate.millisecondsSinceEpoch,
      'goalId': id
    });
  }

  @override
  double getProgress() {
    if (sessions.isEmpty) return 0;
    double progress = sessions
            .where((element) =>
                DateTime.fromMillisecondsSinceEpoch(element.date)
                    .isBefore(untilDate) &&
                DateTime.fromMillisecondsSinceEpoch(element.date)
                    .isAfter(DateTime.fromMillisecondsSinceEpoch(date)))
            .length /
        number;
    if (hasPassedDate() && progress < 1) return -1;
    return progress;
  }

  @override
  bool isCompleted() {
    return getProgress() >= 1;
  }
}

class SingleExcerciseGoal extends Goal {
  SingleExcerciseGoal({
    required String title,
    required DateTime date,
    required this.excercise,
  }) : super(
            title: title,
            date: date.millisecondsSinceEpoch,
            type: GoalType.singleExcercise);
  ExcerciseGoalItem excercise;

  @override
  Widget getGoalCard(BuildContext context) {
    return ListTile(
      onLongPress: () {
        super.removeGoal(context);
      },
      shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey, width: 0.75),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      title: Text(excercise.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      subtitle: Text(
          '${excercise.goalSet.weight}kg | ${excercise.goalSet.reps} reps',
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 134, 131, 131))),
      trailing: getProgress() < 1
          ? AnimatedCircularChart(
              percentageValues: true,
              holeRadius: 24,
              duration: const Duration(milliseconds: 500),
              holeLabel: '${(getProgress() * 100).toStringAsFixed(0)}%',
              key: const Key('chart'),
              size: const Size(65.0, 65.0),
              initialChartData: <CircularStackEntry>[
                CircularStackEntry(
                  <CircularSegmentEntry>[
                    CircularSegmentEntry(
                      getProgress() * 100,
                      getProgress() < 0
                          ? Colors.red[400]
                          : getProgress() >= 1
                              ? Colors.green[500]
                              : Colors.blue[400],
                      rankKey: 'completed',
                    ),
                    CircularSegmentEntry(
                      (100 - (getProgress() * 100)),
                      const Color.fromARGB(255, 227, 231, 233),
                      rankKey: 'remaining',
                    ),
                  ],
                  rankKey: 'progress',
                ),
              ],
              chartType: CircularChartType.Radial,
            )
          : Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Container(
                  height: 55,
                  width: 55,
                  decoration: const BoxDecoration(
                      border: Border.fromBorderSide(
                          BorderSide(color: Colors.green, width: 2)),
                      borderRadius: BorderRadius.all(Radius.circular(100))),
                  child: const Icon(Icons.check, color: Colors.green)),
            ),
      leading: Image.network(
          scale: 32,
          excercise.iconUrl
              .replaceFirst('silhouettes', 'illustrations')
              .replaceAll('png', 'jpg')
              .replaceAll('256', '1000')),
    );
  }

  @override
  void writeGoal() async {
    final db = await database;
    if (db == null) return;
    int gId = await db.insert('Goals', {
      'title': title,
      'date': date,
    });
    int eId = await db.insert('GoalExcerciseItem', {
      'name': excercise.name,
      'bodyPart': excercise.bodyPart,
      'startingReps': excercise.startingSet.reps,
      'startingWeight': excercise.startingSet.weight,
      'goalReps': excercise.goalSet.reps,
      'goalWeight': excercise.goalSet.weight,
      'icon_url': excercise.iconUrl,
    });
    await db.insert('ExcerciseGoal', {
      'goalId': gId,
      'goalExcerciseItemId': eId,
    });
  }

  @override
  double getProgress() {
    if (sessions.isEmpty) return 0;
    excercise.startingSet = Goal.getSet(excercise.name);
    double weightProgress =
        excercise.startingSet.weight / excercise.goalSet.weight;
    double repProgress = excercise.startingSet.reps / excercise.goalSet.reps;
    if (repProgress >= 1 && weightProgress < 1) return weightProgress;
    if (repProgress < 1 && weightProgress >= 1) return 0.99;
    return weightProgress;
  }

  @override
  bool isCompleted() {
    return getProgress() >= 1;
  }
}

class ExcerciseGoalItem {
  String name;
  String bodyPart;
  String iconUrl;
  Excercise_Package.Set goalSet;
  Excercise_Package.Set startingSet;
  ExcerciseGoalItem(
      {required this.name,
      required this.bodyPart,
      required this.iconUrl,
      required this.goalSet,
      required this.startingSet});
}

class MultiExcerciseGoal extends Goal {
  MultiExcerciseGoal(
      {required String title, required DateTime date, required this.excercises})
      : super(
            title: title,
            date: date.millisecondsSinceEpoch,
            type: GoalType.multiExcercise);
  List<ExcerciseGoalItem> excercises;

  @override
  Widget getGoalCard(BuildContext context) {
    return const Text('');
  }

  @override
  bool isCompleted() {
    return getProgress() >= 1;
  }

  @override
  void writeGoal() {}

  @override
  double getProgress() {
    if (sessions.isEmpty) return 0;
    double weightProgress = excercises
            .map((e) => e.startingSet.weight / e.goalSet.weight)
            .reduce((value, element) => value + element) /
        excercises.length;
    double repProgress = excercises
            .map((e) => e.startingSet.reps / e.goalSet.reps)
            .reduce((value, element) => value + element) /
        excercises.length;
    if (repProgress >= 1 && weightProgress < 1) return weightProgress;
    if (repProgress < 1 && weightProgress >= 1) return repProgress;
    return weightProgress;
  }
}
