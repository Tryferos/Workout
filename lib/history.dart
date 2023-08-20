import 'package:flutter/material.dart';
import 'package:flutter_application_1/bodyPart.dart';
import 'package:flutter_application_1/excercise.dart';

class ExcerciseHistoryWidget extends StatefulWidget {
  const ExcerciseHistoryWidget({
    super.key,
    required this.excercise,
  });

  final Excercise excercise;

  @override
  State<ExcerciseHistoryWidget> createState() => _ExcerciseHistoryWidgetState();
}

class _ExcerciseHistoryWidgetState extends State<ExcerciseHistoryWidget> {
  Excercise get excercise => widget.excercise;
  Future<List<ExcerciseHistory>>? list;
  @override
  void initState() {
    super.initState();
    getHistory();
  }

  void getHistory() async {
    List<ExcerciseHistory> tmp =
        await ExcerciseInfo.excercisesInfoHistory(excercise.name);
    tmp.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      list = Future.value(tmp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExcerciseHistory>>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
                addAutomaticKeepAlives: false,
                itemCount: snapshot.data!.length + 1,
                separatorBuilder: (context, index) => const Divider(
                      color: Colors.grey,
                      height: 0.3,
                    ),
                itemBuilder: (context, index) {
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

  SizedBox getImage() {
    return const SizedBox(
        width: 16,
        height: 16,
        child: Image(
          image: AssetImage('assets/weight-icon-png-16.jpg'),
          fit: BoxFit.contain,
        ));
  }

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
      height: 80,
      child: Row(
        children: [
          const Expanded(
              flex: 2,
              child: Icon(
                Icons.history_outlined,
                size: 38,
                color: Colors.blueAccent,
              )),
          Expanded(
            flex: 8,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(lastWorkoutDate,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: Text(lastWorkout,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500)),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.sports_gymnastics_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          Text(
                            ' ${history.sets.length}',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Row(children: [
                        const Icon(
                          Icons.fitness_center_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        Text(
                            ' ${ExcerciseInfo.isEachRepDifferent(history.sets) ? history.sets.map((e) => e.reps.toString()).join('/') : history.sets[0].reps}',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ]),
                      Row(
                        children: [
                          Image.asset(
                            'assets/weight-icon-png-16.jpg',
                            width: 15,
                            height: 15,
                            color: Colors.grey,
                          ),
                          Text(
                              ' ${ExcerciseInfo.isEachWeightDifferent(history.sets) ? history.sets.map((e) => e.weight.toString()).join('/') : history.sets[0].weight}',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
