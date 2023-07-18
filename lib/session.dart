import 'dart:async';

import 'package:flutter/material.dart';

class Session extends StatefulWidget {
  const Session({super.key, required this.selectedBodyParts});

  final List<String> selectedBodyParts;

  @override
  State<Session> createState() => _SessionState();
}

class _SessionState extends State<Session> {
  List<String> get selectedBodyParts => widget.selectedBodyParts;
  Timer? timer;
  Duration duration = const Duration(seconds: 0);
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        duration += const Duration(seconds: 1);
      });
    });
  }

  String strDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Session has started",
              style: TextStyle(color: Colors.white),
            ),
            Text(
              "${strDigits(duration.inMinutes.remainder(60))}m ${strDigits(duration.inSeconds.remainder(60))}s",
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
    );
  }
}
