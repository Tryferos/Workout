import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../database.dart';
import '../main.dart';

class ProfilingWidget extends StatefulWidget {
  const ProfilingWidget({super.key, required this.sessionsCurrent});

  final List<Session> sessionsCurrent;

  @override
  State<ProfilingWidget> createState() => _ProfilingWidgetState();
}

class _ProfilingWidgetState extends State<ProfilingWidget> {
  int workoutsNumber = 0;
  List<Session> get cSessions => widget.sessionsCurrent;
  Future<String>? averageWorkouts;
  String? username;
  String? image_path;
  @override
  void initState() {
    super.initState();
    getSessions();
    getProfileData();
  }

  void readImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    update(image.path);
    setState(() {
      image_path = image.path;
    });
  }

  void update(String? path) async {
    final db = await database;
    if (db == null) return;
    final a = await db.update("Profile",
        {'image_path': path ?? image_path, 'username': username ?? 'Gym Bro'},
        where: 'id = 1');
    if (a == 0) {
      await db.insert("Profile", {
        'image_path': path ?? image_path,
        'username': username ?? 'Gym Bro'
      });
    }
  }

  void getProfileData() async {
    final db = await database;
    if (db == null) return;
    final List<Map<String, dynamic>> pMap = await db.query("Profile");
    if (pMap.isEmpty) return;
    setState(() {
      username = pMap[0]['username'];
      image_path = pMap[0]['image_path'];
    });
  }

  @override
  void didUpdateWidget(ProfilingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    getSessions();
  }

  void getSessions() async {
    setState(() {
      workoutsNumber = cSessions.length;
      if (cSessions.isEmpty) {
        averageWorkouts = Future.value('0');
        return;
      }
      int sum = 0;
      int total = 1;
      int daysOffset = 7;
      for (var session in cSessions) {
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

  void showPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 250,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Column(children: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    readImage();
                  },
                  child: const Text('Choose an image')),
              const Divider(
                height: 48,
              ),
              const Text('Change username'),
              TextField(
                decoration: InputDecoration(
                  hintText: username ?? 'Gym Bro',
                ),
                onChanged: (value) {
                  setState(() {
                    username = value;
                    update(null);
                  });
                },
              ),
            ]),
          ),
        );
      },
    );
  }

  ImageProvider getImage() {
    if (image_path != null) {
      FileImage(File(image_path!));
    }
    return const AssetImage('assets/profile.png');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: image_path != null
                            ? FileImage(File(image_path!), scale: 1)
                            : const AssetImage('assets/profile.png')
                                as ImageProvider,
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
                            showPicker();
                          },
                        ),
                      )
                    ],
                  ),
                  Text(username ?? 'Gym Bro',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 16),
                ],
              ),
              (workoutsNumber >= 10)
                  ? Positioned(
                      top: 0,
                      left: 0,
                      child: Tooltip(
                        message: 'This certification is given to users who\n'
                            'have completed more than 10 workouts in total.',
                        child: Image.asset(
                          'assets/gym_bro_cert.png',
                          width: 64,
                          height: 64,
                        ),
                      ),
                    )
                  : Container(),
              (workoutsNumber >= 100)
                  ? Positioned(
                      top: 0,
                      right: 0,
                      child: Tooltip(
                        message: 'This certification is given to users who\n'
                            'have completed more than 100 workouts in total.',
                        child: Image.asset(
                          'assets/olympia_cert.png',
                          width: 64,
                          height: 64,
                        ),
                      ),
                    )
                  : Container(),
              FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.hasData && double.parse(snapshot.data!) >= 5) {
                      return Positioned(
                        top: 74,
                        left: 0,
                        child: Tooltip(
                          message: 'This certification is given to users who\n'
                              'average 5 or more workouts per week.',
                          child: Image.asset(
                            'assets/steroids_cert.png',
                            width: 64,
                            height: 64,
                          ),
                        ),
                      );
                    }
                    return Container();
                  },
                  future: averageWorkouts),
              FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.hasData && double.parse(snapshot.data!) <= 1) {
                      return Positioned(
                        top: 74,
                        right: 0,
                        child: Tooltip(
                          message: 'This certification is given to users who\n'
                              'average 1 or less workouts per week.',
                          child: Image.asset(
                            'assets/pose_cert.png',
                            width: 64,
                            height: 64,
                          ),
                        ),
                      );
                    }
                    return Container();
                  },
                  future: averageWorkouts)
            ],
          ),
        ),
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
                  'AVG',
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
