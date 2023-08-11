import 'package:action_slider/action_slider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/database.dart' as db;
import 'package:flutter_application_1/excercise.dart';
import 'package:flutter_application_1/landing/calories.dart';
import 'package:flutter_application_1/landing/charts.dart';
import 'package:flutter_application_1/landing/goals.dart';
import 'package:flutter_application_1/landing/profiling.dart';
import 'package:flutter_application_1/landing/recent.dart';
import 'package:flutter_application_1/landing/schedule.dart';
import 'package:flutter_application_1/landing/steps.dart';
import 'package:flutter_application_1/session.dart' as s;
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

import '../database.dart';
import '../index.dart';
import '../main.dart';

const types = [HealthDataType.STEPS, HealthDataType.ACTIVE_ENERGY_BURNED];
const permissions = [HealthDataAccess.READ_WRITE, HealthDataAccess.READ_WRITE];

class LayoutLanding extends StatefulWidget {
  const LayoutLanding({super.key});

  @override
  State<LayoutLanding> createState() => _LayoutLandingState();
}

class SessionReturned {
  final OnGoingSession? onGoingSession;
  final Session? session;
  final bool finished;
  SessionReturned(
      {required this.onGoingSession,
      required this.session,
      required this.finished});
}

class OnGoingSession {
  final DateTime startTime;
  final Duration duration;
  final List<ExcerciseInfo> excerciseInfo;
  final List<String> selectedBodyParts;
  OnGoingSession(
      {required this.startTime,
      required this.duration,
      required this.excerciseInfo,
      required this.selectedBodyParts});
}

class _LayoutLandingState extends State<LayoutLanding> {
  List<Session> sessionsCurrent = [];
  HealthFactory? health;
  bool refresh = false;
  OnGoingSession? onGoingSession;
  @override
  void initState() {
    super.initState();
    setState(() {
      requestPermissions();
      sessionsCurrent = sessions;
      health = HealthFactory(useHealthConnectIfAvailable: true);
    });
  }

  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  void requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await deviceInfo.androidInfo;
      if (!androidInfo.isPhysicalDevice) return;
    }
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
            child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ListView(
                cacheExtent: 2700,
                addAutomaticKeepAlives: true,
                scrollDirection: Axis.vertical,
                children: [
                  ProfilingWidget(
                      sessionsCurrent: sessionsCurrent, health: health),
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
                        ).then(handleSessionReturn);
                      }),
                  const SizedBox(
                    height: 20,
                  ),
                  SparkWidget(refresh: refresh),
                  const SizedBox(
                    height: 20,
                  ),
                  WorkoutGoals(
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
                      title: 'Add Goals',
                      clickHandler: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => GoalCreation(
                                    refresh: () {
                                      setState(() {
                                        refresh = !refresh;
                                      });
                                    },
                                  )),
                        );
                      }),
                  const SizedBox(
                    height: 40,
                  ),
                  StepsSparkLine(
                    health: health,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  const Schedule(),
                  const SizedBox(
                    height: 40,
                  ),
                  CaloriesChart(health: health),
                  WorkoutsChart(refresh: refresh),
                  const SizedBox(
                    height: 40,
                  ),
                  ExcercisesChart(refresh: refresh),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              left: MediaQuery.of(context).size.width * 0.2,
              child: onGoingSession != null
                  ? ActionSlider.dual(
                      actionThresholdType: ThresholdType.release,
                      backgroundBorderRadius: BorderRadius.circular(10.0),
                      foregroundBorderRadius: BorderRadius.circular(10.0),
                      width: MediaQuery.of(context).size.width * 0.6,
                      toggleColor: Colors.blue,
                      backgroundColor: Colors.white,
                      startChild: const Text('Stop',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      endChild: const Text('Continue',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      successIcon: const Icon(Icons.check, color: Colors.white),
                      failureIcon: const Icon(Icons.close, color: Colors.white),
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 0.0),
                        child: Transform.rotate(
                            angle: 0.5 * 3.14,
                            child: const Icon(Icons.stop,
                                color: Colors.white, size: 18.0)),
                      ),
                      startAction: (controller) async {
                        controller.success(); //starts success animation
                        await Future.delayed(const Duration(seconds: 1));
                        setState(() {
                          onGoingSession = null;
                        });
                        controller.reset();
                      },
                      endAction: (controller) async {
                        controller.success(); //starts success animation
                        await Future.delayed(const Duration(seconds: 1));
                        // ignore: use_build_context_synchronously
                        Navigator.push(context, CupertinoPageRoute(
                          builder: (context) {
                            return s.Session(
                                selectedBodyParts: const [],
                                onGoingSession: onGoingSession);
                          },
                        )).then(handleSessionReturn);
                        controller.reset();
                      },
                    )
                  : Container(),
            )
          ],
        )),
      ),
    );
  }

  void handleSessionReturn(dynamic sessionInfo) {
    if (sessionInfo == null) return;
    SessionReturned info = sessionInfo as SessionReturned;
    if (!(info.finished)) {
      if (info.onGoingSession == null) return;
      setState(() {
        onGoingSession = info.onGoingSession as OnGoingSession;
      });
      return;
    }
    if (info.session == null) return;
    setState(() {
      onGoingSession = null;
      db.Session.insertSession(info.session!);
      sessions.insert(0, info.session!);
      refresh = !refresh;
    });
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
