import 'dart:math';

import 'package:flutter/material.dart';

import '../database.dart';

class RecentWorkouts extends StatefulWidget {
  const RecentWorkouts({super.key, required this.sessionsCurrent});

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
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Latest Workouts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'See All',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue),
            ),
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
                    offset: Offset.fromDirection(3, 40),
                    onSelected: (item) => {},
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
                  '${widget.sessionsCurrent[i].excerciseInfo!.map((el) => el.sets.length).reduce((value, element) => value + element)} Sets, ${(widget.sessionsCurrent[i].duration / 60).round()}m | ${Session.getAgo(widget.sessionsCurrent[i].date)}'),
            ),
          )
      ],
    );
  }
}
