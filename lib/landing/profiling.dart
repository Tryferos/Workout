import 'package:flutter/material.dart';
import 'package:flutter_application_1/profile/layout.dart';

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
      if (sessions.isEmpty) {
        averageWorkouts = Future.value('0');
        return;
      }
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
        Stack(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile.png'),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileWidget()));
                },
              ),
            )
          ],
        ),
        const Text('Trifon Mazarakis',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(height: 16),
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
