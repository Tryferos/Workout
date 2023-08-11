import 'dart:convert';

import 'package:action_slider/action_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/database.dart' as db;
import 'package:flutter_application_1/excercise.dart' as Excercise_Package;
import 'package:http/http.dart' as http;

import 'excercise.dart';
import 'landing/results.dart';

class BodyPartData {
  final String bodyPart;
  final List<Excercise> excercises;
  BodyPartData({required this.bodyPart, required this.excercises});

  factory BodyPartData.fromJson(Map<String, dynamic> json, String bodyPart) {
    List<Excercise> excercises = [];
    json['data'].forEach((element) {
      excercises.add(Excercise.fromJson(element));
    });
    return BodyPartData(bodyPart: bodyPart, excercises: excercises);
  }
  String get getBodyPart => bodyPart;

  List<Excercise> get getExcercises => excercises;
}

class Excercise {
  final String name;
  final String nameUrl;
  final List<String> aliases;
  final String iconUrl;
  final String category;
  final String bodyPart;
  final int id;

  Excercise({
    required this.name,
    required this.nameUrl,
    required this.aliases,
    required this.iconUrl,
    required this.bodyPart,
    required this.category,
    required this.id,
  });

  factory Excercise.fromJson(Map<String, dynamic> json) {
    try {
      json = json['data'][0];
    } catch (Exception) {
      json = json;
    }
    List<String> aliases = [];
    if (json['aliases'] is List) {
      json['aliases'].forEach((el) {
        aliases.add(el);
      });
    }
    return Excercise(
      name: json['name'],
      bodyPart: json['bodypart'],
      nameUrl: json['name_url'],
      aliases: aliases,
      iconUrl: json['icon_url'],
      category: json['category'],
      id: json['id'],
    );
  }
  get getAliases => aliases;
  get getCategory => category;
  get getIconUrl => iconUrl;
  get getIconUrlColored => iconUrl
      .replaceFirst("silhouettes", "illustrations")
      .replaceAll("256", "1000")
      .replaceFirst(".png", ".jpg");
  get getName => name;

  get getNameUrl => nameUrl;
  static Future<List<Excercise>> fetchAllExcercises() async {
    final res = await http.get(Uri.parse(
        'https://strengthlevel.com/api/exercises?limit=64&exercise.fields=category,name_url,bodypart,count,aliases,icon_url&standard=yes'));
    if (res.statusCode == 200) {
      List<Excercise> excercises = [];
      jsonDecode(res.body)['data'].forEach((element) {
        excercises.add(Excercise.fromJson(element));
      });
      return excercises;
    } else {
      throw Exception('Failed to load body part data');
    }
  }
}

class ExcerciseListItem extends StatefulWidget {
  final Duration duration;
  final void Function(ExcerciseInfo, bool) addExcerciseInfo;
  final ExcerciseInfo excerciseInfo;
  final Excercise excercise;
  bool applied = false;
  ExcerciseListItem({
    super.key,
    required this.excercise,
    required this.duration,
    required this.excerciseInfo,
    required this.addExcerciseInfo,
  });

  @override
  State<ExcerciseListItem> createState() => _ExcerciseListItemState();
}

class BodyPart extends StatefulWidget {
  final String title;

  final void Function(BodyPartData) addBodyPartData;
  final void Function(ExcerciseInfo, bool) addExcerciseInfo;
  final List<ExcerciseInfo> excerciseInfo;
  final BodyPartData bodyPartData;
  final Duration duration;
  final List<BodyPartData> bodyPartDataList;
  final bool onGoingSession;
  const BodyPart(
      {super.key,
      required this.title,
      required this.excerciseInfo,
      required this.addExcerciseInfo,
      required this.addBodyPartData,
      required this.bodyPartData,
      required this.bodyPartDataList,
      required this.onGoingSession,
      required this.duration});

  @override
  State<BodyPart> createState() => _BodyPartState();
}

class _BodyPartState extends State<BodyPart> {
  late Future<BodyPartData> futureBodyPartData;
  void Function(BodyPartData) get addBodyPartData => widget.addBodyPartData;
  void Function(ExcerciseInfo, bool) get addExcerciseInfo =>
      widget.addExcerciseInfo;
  BodyPartData? get bodyPartData => widget.bodyPartData;
  Duration get duration => widget.duration;
  List<ExcerciseInfo> get excerciseInfo => widget.excerciseInfo;
  String get title => widget.title;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<BodyPartData>(
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                      cacheExtent: 2000,
                      itemBuilder: (context, index) {
                        if (index >= snapshot.data!.excercises.length) {
                          return null;
                        }
                        return ExcerciseListItem(
                            addExcerciseInfo: addExcerciseInfo,
                            excerciseInfo: excerciseInfo.firstWhere(
                                (element) =>
                                    element.excercise.getName ==
                                    snapshot.data!.getExcercises[index].getName,
                                orElse: () => ExcerciseInfo(
                                    excercise:
                                        snapshot.data!.getExcercises[index],
                                    sets: [])),
                            duration: duration,
                            excercise: snapshot.data!.getExcercises[index]);
                      }),
                );
              }
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.white,
              ));
            },
            future: futureBodyPartData),
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: ActionSlider.standard(
              sliderBehavior: SliderBehavior.stretch,
              width: 300.0,
              backgroundColor: Colors.white,
              toggleColor: Colors.blue,
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              loadingIcon: const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
              successIcon: const Icon(Icons.check, color: Colors.white),
              failureIcon: const Icon(Icons.close, color: Colors.white),
              action: (controller) async {
                controller.loading(); //starts loading animation
                await Future.delayed(const Duration(seconds: 3));
                if (excerciseInfo.isEmpty) {
                  controller.failure();
                  await Future.delayed(const Duration(seconds: 2));
                  controller.reset();
                  return;
                }
                controller.success();
                db.Session session = db.Session(
                    date: DateTime.now().millisecondsSinceEpoch,
                    duration: widget.duration.inSeconds);
                session.excerciseInfo = excerciseInfo;
                await Future.delayed(const Duration(seconds: 1));
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => PostSessionResults(
                        session: session,
                        bodyParts: widget.bodyPartDataList,
                        onGoingSession: widget.onGoingSession)));
              },
              child: const Text(
                'Finish your workout',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<BodyPartData> fetchBodyPartData() async {
    final res = await http.get(Uri.parse(
        'https://strengthlevel.com/api/exercises?limit=64&exercise.fields=category,name_url,bodypart,count,aliases,icon_url&bodypart=$title&standard=yes'));
    if (res.statusCode == 200) {
      BodyPartData data = BodyPartData.fromJson(jsonDecode(res.body), title);
      addBodyPartData(data);
      return data;
    } else {
      throw Exception('Failed to load body part data');
    }
  }

  @override
  void initState() {
    super.initState();
    if (bodyPartData == null ||
        bodyPartData!.getBodyPart != title ||
        bodyPartData!.getExcercises.isEmpty) {
      futureBodyPartData = fetchBodyPartData();
      return;
    } else {
      futureBodyPartData = Future.value(bodyPartData);
    }
  }
}

class _ExcerciseListItemState extends State<ExcerciseListItem> {
  bool get applied => widget.applied;
  void Function(ExcerciseInfo, bool) get addExcerciseInfo =>
      widget.addExcerciseInfo;
  Duration get duration => widget.duration;
  Excercise get excercise => widget.excercise;
  ExcerciseInfo get excerciseInfo => widget.excerciseInfo;
  void checkApplied(bool value) {
    setState(() {
      // widget.applied = value;
    });
  }

  @override
  void didUpdateWidget(covariant ExcerciseListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.applied == excerciseInfo.sets.isNotEmpty) return;
    setState(() {
      widget.applied = excerciseInfo.sets.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).push(CupertinoPageRoute(
          fullscreenDialog: true,
          builder: (context) => Excercise_Package.ExcerciseWidget(
                excerciseInfo: excerciseInfo,
                addExcerciseInfo: addExcerciseInfo,
                excercise: excercise,
                duration: duration,
                checkApplied: checkApplied,
              ))),
      tileColor: const Color.fromARGB(255, 255, 255, 255),
      trailing: Container(
        width: 32,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: applied ? Colors.green : Colors.grey[500]),
        child: Icon(
          applied ? Icons.check : Icons.add,
          size: 24,
          color: applied ? Colors.white : Colors.white,
        ),
      ),
      title: Text(excercise.getName),
      subtitle: Text(excercise.getCategory),
      leading: Hero(
        tag: 'excerciseIcon${excercise.name}',
        child: Image.network(excercise.getIconUrlColored),
      ),
      shape: const Border(
        bottom: BorderSide(color: Colors.grey, width: 0.3),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      widget.applied = excerciseInfo.sets.isNotEmpty;
    });
  }
}
