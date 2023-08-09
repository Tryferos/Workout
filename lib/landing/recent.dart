import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';

import '../database.dart';

class AllWorkouts extends StatefulWidget {
  const AllWorkouts({
    super.key,
  });

  @override
  State<AllWorkouts> createState() => _AllWorkoutsState();
}

class _AllWorkoutsState extends State<AllWorkouts> {
  List<String> bodyPartsTotal = [];
  @override
  void initState() {
    super.initState();
    setState(() {
      for (var i = 0; i < sessions.length; i++) {
        List<String> bodyParts = [];
        sessions[i]
            .excerciseInfo!
            .map((element) => element.excercise.bodyPart)
            .toList()
            .forEach((element) {
          if (!bodyParts.contains(element)) bodyParts.add(element);
        });
        bodyPartsTotal.add(bodyParts.join(', '));
      }
    });
  }

  @override
  void didUpdateWidget(AllWorkouts oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      bodyPartsTotal = [];
      for (var i = 0; i < sessions.length; i++) {
        List<String> bodyParts = [];
        sessions[i]
            .excerciseInfo!
            .map((element) => element.excercise.bodyPart)
            .toList()
            .forEach((element) {
          if (!bodyParts.contains(element)) bodyParts.add(element);
        });
        bodyPartsTotal.add(bodyParts.join(', '));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Workouts',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView.separated(
              shrinkWrap: true,
              addAutomaticKeepAlives: true,
              scrollDirection: Axis.vertical,
              separatorBuilder: (context, index) => const SizedBox(
                    height: 10,
                  ),
              itemCount: bodyPartsTotal.length,
              itemBuilder: (context, i) {
                return ListTile(
                  shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey, width: 0.75),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  leading: const Icon(Icons.fitness_center),
                  title: Text(
                    bodyPartsTotal[i],
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  trailing: Stack(
                    children: [
                      PopupMenuButton<int>(
                        offset: Offset.fromDirection(3, 40),
                        onSelected: (item) async {
                          if (item == 0) {
                            return;
                          }
                          (await database)!.delete('Session',
                              where: 'id = ?', whereArgs: [sessions[i].id]);
                          setState(() {
                            sessions.removeAt(i);
                            bodyPartsTotal.removeAt(i);
                            Navigator.pop(context);
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem<int>(
                              value: 0, child: Text('View More')),
                          const PopupMenuItem<int>(
                              value: 1, child: Text('Delete')),
                        ],
                      ),
                    ],
                  ),
                  subtitle: Text(
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color.fromARGB(255, 134, 131, 131)),
                      '${sessions[i].excerciseInfo!.map((el) => el.sets.length).reduce((value, element) => value + element)} Sets, ${(sessions[i].duration / 60).round()}m | ${Session.getAgo(sessions[i].date)}'),
                );
              }),
        )),
      ]),
    );
  }
}

class RecentWorkouts extends StatefulWidget {
  const RecentWorkouts(
      {super.key, required this.sessionsCurrent, required this.refresh});

  final void Function() refresh;

  final List<Session> sessionsCurrent;

  @override
  State<RecentWorkouts> createState() => _RecentWorkoutsState();
}

class _RecentWorkoutsState extends State<RecentWorkouts> {
  List<String> bodyPartsTotal = [];

  @override
  void didUpdateWidget(RecentWorkouts oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      bodyPartsTotal = [];
      for (var i = 0; i < min(2, widget.sessionsCurrent.length); i++) {
        List<String> bodyParts = [];
        widget.sessionsCurrent[i].excerciseInfo!
            .map((element) => element.excercise.bodyPart)
            .toList()
            .forEach((element) {
          if (!bodyParts.contains(element)) bodyParts.add(element);
        });
        bodyPartsTotal.add(bodyParts.join(', '));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      for (var i = 0; i < min(2, widget.sessionsCurrent.length); i++) {
        List<String> bodyParts = [];
        widget.sessionsCurrent[i].excerciseInfo!
            .map((element) => element.excercise.bodyPart)
            .toList()
            .forEach((element) {
          if (!bodyParts.contains(element)) bodyParts.add(element);
        });
        bodyPartsTotal.add(bodyParts.join(', '));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Latest Workouts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            InkWell(
              child: const Text(
                'See All',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => const AllWorkouts(),
                    ));
              },
            )
          ],
        ),
        for (var i = 0; i < bodyPartsTotal.length; i++)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ListTile(
              shape: const RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey, width: 0.75),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              leading: const Icon(Icons.fitness_center),
              title: Text(
                bodyPartsTotal[i],
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              trailing: Stack(
                children: [
                  PopupMenuButton<int>(
                    onSelected: (item) async {
                      if (item == 0) {
                        return;
                      }
                      (await database)!.delete('Session',
                          where: 'id = ?', whereArgs: [sessions[i].id]);
                      setState(() {
                        sessions.removeAt(i);
                        widget.refresh();
                        bodyPartsTotal.removeAt(i);
                      });
                    },
                    offset: Offset.fromDirection(3, 40),
                    itemBuilder: (context) => [
                      const PopupMenuItem<int>(
                          value: 0, child: Text('View More')),
                      const PopupMenuItem<int>(value: 1, child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              subtitle: Text(
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color.fromARGB(255, 134, 131, 131)),
                  '${widget.sessionsCurrent[i].excerciseInfo?.map((el) => el.sets.length).reduce((value, element) => value + element)} Sets, ${(widget.sessionsCurrent[i].duration / 60).round()}m | ${Session.getAgo(widget.sessionsCurrent[i].date)}'),
            ),
          )
      ],
    );
  }
}
