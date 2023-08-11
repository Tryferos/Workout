import 'package:flutter/material.dart';
import 'package:flutter_application_1/bodyPart.dart';
import 'package:flutter_application_1/landing/layout.dart';

import '../database.dart';
import '../excercise.dart';
import '../main.dart';

class PostSessionResults extends StatefulWidget {
  const PostSessionResults(
      {super.key,
      required this.session,
      required this.bodyParts,
      required this.onGoingSession});

  final List<BodyPartData> bodyParts;

  final bool onGoingSession;

  final Session session;

  @override
  State<PostSessionResults> createState() => _PostSessionResultsState();
}

class _PostSessionResultsState extends State<PostSessionResults> {
  Session get session => widget.session;
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: index,
      length: 2,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Workout Summary',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w500)),
            centerTitle: true,
            backgroundColor: Colors.blue,
            toolbarHeight: 105,
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(15),
                child: TabBar(
                  onTap: (index) {
                    setState(() {
                      this.index = index;
                    });
                  },
                  tabs: const [
                    Tab(
                      text: 'Latest Workout',
                    ),
                    Tab(
                      text: 'Overall Performance',
                    ),
                  ],
                  indicatorColor: Colors.white,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.7),
                  indicator: UnderlineTabIndicator(
                    borderSide:
                        const BorderSide(color: Colors.white, width: 2.25),
                    insets: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 4 - 10,
                        vertical: 0),
                  ),
                )),
            leading: BackButton(
              color: Colors.white,
              onPressed: () {
                if (!widget.onGoingSession) {
                  Navigator.of(context).pop();
                }
                Navigator.of(context).pop();
                SessionReturned r = SessionReturned(
                    session: session, finished: true, onGoingSession: null);
                Navigator.of(context).pop(r);
              },
            ),
          ),
          body: LatestWorkout(
            session: session,
            bodyParts: widget.bodyParts,
            overall: index == 1,
          )),
    );
  }
}

class LatestWorkout extends StatefulWidget {
  const LatestWorkout(
      {super.key,
      required this.session,
      required this.bodyParts,
      required this.overall});

  final bool overall;

  final List<BodyPartData> bodyParts;

  final Session session;

  @override
  State<LatestWorkout> createState() => _LatestWorkoutState();
}

class _LatestWorkoutState extends State<LatestWorkout> {
  Session get session => widget.session;
  List<double> offsetPercentage = [];
  double overallPerformance = 0;
  @override
  void initState() {
    super.initState();
    readData();
  }

  @override
  void didUpdateWidget(LatestWorkout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.overall == widget.overall) return;
    readData();
  }

  void readData() {
    setState(() {
      offsetPercentage.clear();
    });
    //Sort to get the most recent workout
    sessions.sort((a, b) => a.date.compareTo(b.date));
    for (var e in session.excerciseInfo!) {
      ExcerciseInfo? latest;
      int length = 0;
      double lEffort = 0;
      for (var element in sessions) {
        element.excerciseInfo?.forEach((element) {
          if (element.excercise.name == e.excercise.name) {
            latest = element;
            if (widget.overall) {
              length++;
              for (var s in element.sets) {
                lEffort += (s.reps * 0.75) * s.weight;
              }
            }
          }
        });
      }
      if (widget.overall) {
        lEffort /= length;
      }
      if (latest == null) continue;
      double offsetPercentage = 0;
      double cEffort = 0;
      for (var s in e.sets) {
        cEffort += (s.reps * 0.75) * s.weight;
      }
      if (!widget.overall) {
        for (var s in latest!.sets) {
          lEffort += (s.reps * 0.75) * s.weight;
        }
      }
      offsetPercentage = (cEffort - lEffort) / lEffort;
      setState(() {
        this.offsetPercentage.add((offsetPercentage * 100).ceilToDouble());
      });
    }
    setState(() {
      overallPerformance = offsetPercentage.isEmpty
          ? 0
          : offsetPercentage.reduce((value, element) => value + element);
    });
  }

  String getWorkoutNumber() {
    int length = sessions.length + 1;
    if (length == 1) {
      return '1st';
    }
    if (length == 2) {
      return '2nd';
    }
    if (length == 3) {
      return '3rd';
    }
    return '${length}th';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                text: overallPerformance == 0
                    ? 'Your performance has not changed'
                    : 'Your performance has ${overallPerformance > 0 ? 'increased' : 'decreased'} by ',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w500),
                children: [
                  overallPerformance != 0
                      ? TextSpan(
                          text:
                              '${overallPerformance.abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                              color: overallPerformance >= 0
                                  ? Colors.green[500]
                                  : Colors.red[500],
                              fontSize: 22,
                              fontWeight: FontWeight.w500),
                        )
                      : const TextSpan(),
                ],
              ),
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w500)),
          const SizedBox(
            height: 0,
          ),
          InkWell(
            onTap: () => readData(),
            child: Icon(
              overallPerformance >= 0 ? Icons.auto_graph : Icons.show_chart,
              color:
                  overallPerformance >= 0 ? Colors.green[500] : Colors.red[500],
              size: overallPerformance != 0 ? 80 : 0,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.grey[300]!,
                  offset: const Offset(5.0, 5.0),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(widget.bodyParts.map((item) => item.bodyPart).join(' - '),
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w500)),
          const SizedBox(
            height: 5,
          ),
          Text('${getWorkoutNumber()} Workout',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600]!)),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 125,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(100)),
                        child: Icon(
                          Icons.fitness_center_outlined,
                          color: Colors.blue[800],
                          size: 26,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('Excercises',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      Text('${session.excerciseInfo!.length}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600))
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(100)),
                        child: Image.asset(
                          'assets/weight-icon-png-16.jpg',
                          width: 26,
                          height: 26,
                          color: Colors.yellow[900],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('Sets',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      Text(
                          '${session.excerciseInfo!.map((item) => item.sets.length).reduce((value, element) => value + element)}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600))
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(100)),
                        child: Icon(
                          Icons.timer,
                          color: Colors.green[800],
                          size: 26,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('Duration',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      Text(getDuration(session.duration),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600))
                    ],
                  )
                ]),
          ),
          Expanded(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  double increase = index < offsetPercentage.length
                      ? offsetPercentage[index]
                      : 0.0;
                  return ListTile(
                    trailing: Column(
                      children: [
                        Icon(
                          increase > 0 ? Icons.auto_graph : Icons.show_chart,
                          color: increase > 0
                              ? Colors.green
                              : increase == 0
                                  ? Colors.grey
                                  : Colors.red,
                        ),
                        Text(
                          '${increase.abs()}%',
                          style: TextStyle(
                              fontSize: 14,
                              color: increase > 0
                                  ? Colors.green
                                  : increase == 0
                                      ? Colors.grey
                                      : Colors.red,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                    leading: Image.network(
                      session.excerciseInfo![index].excercise.getIconUrlColored,
                      width: 50,
                      height: 50,
                    ),
                    title: Text(
                      session.excerciseInfo![index].excercise.name,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                    subtitle: Text(
                      '${session.excerciseInfo![index].sets.length} sets - ${session.excerciseInfo![index].sets.map((item) => item.reps).reduce((value, element) => value + element)} reps',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600]),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemCount: session.excerciseInfo!.length),
          ),
        ],
      ),
    );
  }
}

String strDigits(int n) => n.toString().padLeft(2, '0');

String getDuration(int seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int secs = seconds % 60;
  return '${hours > 0 ? '${strDigits(hours)}:' : ''}${strDigits(minutes)}:${strDigits(secs)}';
}
