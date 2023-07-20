import 'package:flutter/material.dart';
import 'package:flutter_application_1/bodyPart.dart';
import 'package:flutter_application_1/excercise.dart';

class ExcerciseHistoryWidget extends StatefulWidget {
  const ExcerciseHistoryWidget({super.key, required this.excercise});

  final Excercise excercise;

  @override
  State<ExcerciseHistoryWidget> createState() => _ExcerciseHistoryWidgetState();
}

class _ExcerciseHistoryWidgetState extends State<ExcerciseHistoryWidget> {
  Excercise get excercise => widget.excercise;
  late Future<List<ExcerciseHistory>> list;
  @override
  void initState() {
    super.initState();
    getHistory();
  }

  void getHistory() async {
    list = ExcerciseInfo.excercisesInfoHistory(excercise.name);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExcerciseHistory>>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(itemBuilder: (context, index) {
              if (index >= snapshot.data!.length) return null;
              return ExcerciseHistoryItem(
                  history: snapshot.data![index], name: excercise.name);
            });
          }
          return const Center(child: CircularProgressIndicator());
        },
        future: list);
  }
}

class ExcerciseHistoryItem extends StatefulWidget {
  const ExcerciseHistoryItem(
      {super.key, required this.history, required this.name});

  final ExcerciseHistory history;
  final String name;

  @override
  State<ExcerciseHistoryItem> createState() => _ExcerciseHistoryItemState();
}

class _ExcerciseHistoryItemState extends State<ExcerciseHistoryItem> {
  ExcerciseHistory get history => widget.history;
  String get name => widget.name;
  String lastWorkout = '';
  String lastWorkoutDate = '';
  String sets = '';

  String strDigits(int n) => n.toString().padLeft(2, '0');

  @override
  void initState() {
    super.initState();
    int millis = history.date;
    DateTime date = DateTime.now();
    DateTime lastWorkoutDateTime = DateTime.fromMillisecondsSinceEpoch(millis);
    //format last workout date to dd/mm/yyy
    lastWorkoutDate =
        '${strDigits(lastWorkoutDateTime.day)}/${strDigits(lastWorkoutDateTime.month)}/${lastWorkoutDateTime.year}';
    int timePassed = ((date.millisecondsSinceEpoch - millis) / 1000).round();

    setState(() {
      int hoursPassed = (timePassed / 3600).round();
      if (hoursPassed < 24) {
        lastWorkout = '${hoursPassed}h ago';
        return;
      }
      int daysPassed = (hoursPassed / 24).round();
      if (daysPassed < 7) {
        lastWorkout = '${daysPassed}d ago';
        return;
      }
      int weeksPassed = (daysPassed / 7).round();
      if (weeksPassed < 4) {
        lastWorkout = '${weeksPassed}w ago';
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 0),
      height: 70,
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.4))),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                '${history.sets.length} sets',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Container(
                width: 20,
                height: 1,
                color: Colors.grey,
              ),
              Text(
                  '${ExcerciseInfo.isEachRepDifferent(history.sets) ? history.sets.map((e) => e.reps.toString()).join('/') : history.sets[0].reps} reps',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              Container(
                width: 20,
                height: 1,
                color: Colors.grey,
              ),
              Text(
                  '${ExcerciseInfo.isEachWeightDifferent(history.sets) ? history.sets.map((e) => e.weight.toString()).join('/') : history.sets[0].weight} kg',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              '$lastWorkoutDate - $lastWorkout',
              style: const TextStyle(fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}
