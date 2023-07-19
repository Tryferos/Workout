import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/bodyPart.dart';
import 'package:flutter_application_1/session.dart';

class ExcerciseWidget extends StatefulWidget {
  const ExcerciseWidget(
      {super.key, required this.excercise, required this.duration});
  final Excercise excercise;
  final Duration duration;

  @override
  State<ExcerciseWidget> createState() => _ExcerciseWidgetState();
}

class _ExcerciseWidgetState extends State<ExcerciseWidget> {
  Excercise get excercise => widget.excercise;
  Duration get prevDuration => widget.duration;
  Duration duration = const Duration(seconds: 0);
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
      body: Placeholder(),
    );
  }
}

class ExcerciseInfo {
  final Excercise excercise;
  final List<Set> sets;
  final bool isDone = false;
  ExcerciseInfo({required this.excercise, required this.sets});
}

class Set {
  final int reps;
  final int weight;
  final int? rest;
  Set({required this.reps, required this.weight, this.rest});
}
