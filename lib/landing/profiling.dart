import 'package:flutter/material.dart';

import '../main.dart';

class ProfilingWidget extends StatefulWidget {
  const ProfilingWidget({super.key});

  @override
  State<ProfilingWidget> createState() => _ProfilingWidgetState();
}

class _ProfilingWidgetState extends State<ProfilingWidget> {
  int workoutsNumber = 0;
  Future<String>? averageWorkouts;
  @override
  void initState() {
    super.initState();
    getSessions();
  }

  void getSessions() async {
    setState(() {
      workoutsNumber = sessions.length;
      int sum = 0;
      int total = 1;
      int daysOffset = 7;
      for (var session in sessions) {
        int date = DateTime.now()
            .subtract(Duration(days: (total * daysOffset)))
            .millisecondsSinceEpoch;
        if (session.date >= date) {
          sum++;
        } else {
          while (session.date < date) {
            date = DateTime.now()
                .subtract(Duration(days: (total * daysOffset)))
                .millisecondsSinceEpoch;
            total++;
          }
          sum++;
        }
      }
      averageWorkouts = Future.value((sum / total).toStringAsFixed(1));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile.png'),
            ),
          ],
        ),
        const Text('Trifon Mazarakis',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text(
                  'Workouts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(workoutsNumber.toString(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w400)),
              ],
            ),
            Column(
              children: [
                const Text(
                  'Workouts AVG',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                FutureBuilder(
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text('${snapshot.data} / week',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w400));
                      }
                      return const CircularProgressIndicator();
                    },
                    future: averageWorkouts)
              ],
            ),
          ],
        )
      ],
    );
  }
}
