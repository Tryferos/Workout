import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/database.dart' as db;
import 'package:flutter_application_1/landing/charts.dart';
import 'package:flutter_application_1/landing/goals.dart';
import 'package:flutter_application_1/landing/profiling.dart';
import 'package:flutter_application_1/landing/recent.dart';
import 'package:flutter_application_1/landing/schedule.dart';
import 'package:flutter_application_1/landing/steps.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

import '../database.dart';
import '../index.dart';
import '../main.dart';

const types = [HealthDataType.STEPS, HealthDataType.ACTIVE_ENERGY_BURNED];
const permissions = [HealthDataAccess.READ, HealthDataAccess.READ];

class LayoutLanding extends StatefulWidget {
  const LayoutLanding({super.key});

  @override
  State<LayoutLanding> createState() => _LayoutLandingState();
}

class _LayoutLandingState extends State<LayoutLanding> {
  List<Session> sessionsCurrent = [];
  HealthFactory? health;
  bool refresh = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      sessionsCurrent = sessions;
      // health = HealthFactory(useHealthConnectIfAvailable: true);
      // requestPermissions();
    });
  }

  void requestPermissions() async {
    await Permission.activityRecognition.request();
    await Permission.location.request();
    await health!.requestAuthorization(types);
    await health!.requestAuthorization(types, permissions: permissions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          List<Session> li = await Session.sessions();
          setState(() {
            refresh = !refresh;
            if (li.isEmpty) {
              sessionsCurrent = [];
              sessions = [];
              return;
            }
            if ((li.length > sessionsCurrent.length) ||
                li.length > sessions.length) {
              sessionsCurrent = li;
              sessions = li;
              return;
            }
            sessionsCurrent.setAll(0, li);
            sessions.setAll(0, li);
          });
          return Future.value();
        },
        child: Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            cacheExtent: 2700,
            addAutomaticKeepAlives: true,
            scrollDirection: Axis.vertical,
            children: [
              ProfilingWidget(sessionsCurrent: sessionsCurrent, health: health),
              const SizedBox(
                height: 30,
              ),
              RecentWorkouts(
                sessionsCurrent: sessionsCurrent,
                refresh: () {
                  setState(() {
                    refresh = !refresh;
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Button(
                  title: 'Start Workout',
                  clickHandler: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => const BodyPartSelector()),
                    ).then((session) {
                      if (session == null) return;
                      setState(() {
                        db.Session.insertSession(session);
                        sessions.insert(0, session);
                        refresh = !refresh;
                      });
                    });
                  }),
              const SizedBox(
                height: 20,
              ),
              SparkWidget(refresh: refresh),
              const SizedBox(
                height: 20,
              ),
              WorkoutGoals(refresh: refresh),
              const SizedBox(
                height: 20,
              ),
              Button(
                  title: 'Add Goals',
                  clickHandler: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GoalCreation()),
                    );
                  }),
              const SizedBox(
                height: 40,
              ),
              const WorkoutsChart(),
              const SizedBox(
                height: 40,
              ),
              const Schedule(),
              const SizedBox(
                height: 40,
              ),
              StepsSparkLine(
                health: health,
              ),
              const SizedBox(
                height: 40,
              ),
              ExcercisesChart(refresh: refresh),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        )),
      ),
    );
  }
}

class Button extends StatelessWidget {
  const Button({super.key, required this.title, required this.clickHandler});
  final String title;
  final Function clickHandler;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: ElevatedButton(
          style: ButtonStyle(
            elevation: MaterialStateProperty.all<double>(3),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: const BorderSide(color: Colors.blue))),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          ),
          onPressed: () {
            clickHandler();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(
                width: 10,
              ),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const Icon(Icons.arrow_right_alt_outlined,
                  color: Colors.white, size: 32)
            ],
          )),
    );
  }
}
