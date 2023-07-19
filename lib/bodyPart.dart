import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/excercise.dart' as Excercise_Package;

import 'excercise.dart';

class BodyPart extends StatefulWidget {
  const BodyPart(
      {super.key,
      required this.title,
      required this.excerciseInfo,
      required this.addExcerciseInfo,
      required this.addBodyPartData,
      required this.bodyPartData,
      required this.duration});

  final String title;
  final void Function(BodyPartData) addBodyPartData;
  final void Function(ExcerciseInfo) addExcerciseInfo;
  final List<ExcerciseInfo> excerciseInfo;
  final BodyPartData bodyPartData;
  final Duration duration;

  @override
  State<BodyPart> createState() => _BodyPartState();
}

class _BodyPartState extends State<BodyPart> {
  String get title => widget.title;
  Duration get duration => widget.duration;
  void Function(BodyPartData) get addBodyPartData => widget.addBodyPartData;
  void Function(ExcerciseInfo) get addExcerciseInfo => widget.addExcerciseInfo;
  List<ExcerciseInfo> get excerciseInfo => widget.excerciseInfo;
  BodyPartData? get bodyPartData => widget.bodyPartData;
  late Future<BodyPartData> futureBodyPartData;
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

  Future<BodyPartData> fetchBodyPartData() async {
    final res = await http.get(Uri.parse(
        'https://strengthlevel.com/api/exercises?limit=64&exercise.fields=category,name_url,bodypart,count,aliases,icon_url&bodypart=${title}&standard=yes'));
    if (res.statusCode == 200) {
      BodyPartData data = BodyPartData.fromJson(jsonDecode(res.body), title);
      addBodyPartData(data);
      return data;
    } else {
      throw Exception('Failed to load body part data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BodyPartData>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(itemBuilder: (context, index) {
              return ExcerciseListItem(
                  addExcerciseInfo: addExcerciseInfo,
                  excerciseInfo: excerciseInfo.firstWhere(
                      (element) =>
                          element.excercise.getName ==
                          snapshot.data!.getExcercises[index].getName,
                      orElse: () => ExcerciseInfo(
                          excercise: snapshot.data!.getExcercises[index],
                          sets: [])),
                  duration: duration,
                  excercise: snapshot.data!.getExcercises[index]);
            });
          }
          return const Center(child: CircularProgressIndicator());
        },
        future: futureBodyPartData);
  }
}

class ExcerciseListItem extends StatefulWidget {
  const ExcerciseListItem(
      {super.key,
      required this.excercise,
      required this.duration,
      required this.excerciseInfo,
      required this.addExcerciseInfo});
  final Duration duration;
  final void Function(ExcerciseInfo) addExcerciseInfo;
  final ExcerciseInfo excerciseInfo;
  final Excercise excercise;

  @override
  State<ExcerciseListItem> createState() => _ExcerciseListItemState();
}

class _ExcerciseListItemState extends State<ExcerciseListItem> {
  bool applied = false;
  Excercise get excercise => widget.excercise;
  Duration get duration => widget.duration;
  void Function(ExcerciseInfo) get addExcerciseInfo => widget.addExcerciseInfo;
  ExcerciseInfo get excerciseInfo => widget.excerciseInfo;
  @override
  void initState() {
    super.initState();
    setState(() {
      applied = excerciseInfo.sets.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Color.fromARGB(255, 255, 255, 255),
      trailing: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Excercise_Package.ExcerciseWidget(
                    excerciseInfo: excerciseInfo,
                    addExcerciseInfo: addExcerciseInfo,
                    excercise: excercise,
                    duration: duration,
                  )));
        },
        child: Container(
          width: 32,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: applied ? Colors.green : Colors.amber),
          child: Icon(
            applied ? Icons.check : Icons.arrow_right_alt_outlined,
            size: 24,
            color: applied ? Colors.white : Colors.black,
          ),
        ),
      ),
      title: Text(excercise.getName),
      subtitle: Text(excercise.getCategory),
      leading: Image.network(excercise.getIconUrlColored),
      shape: const Border(
        bottom: BorderSide(color: Colors.grey, width: 0.3),
      ),
    );
  }
}

class BodyPartData {
  final String bodyPart;
  final List<Excercise> excercises;
  BodyPartData({required this.bodyPart, required this.excercises});

  String get getBodyPart => bodyPart;
  List<Excercise> get getExcercises => excercises;

  factory BodyPartData.fromJson(Map<String, dynamic> json, String bodyPart) {
    List<Excercise> excercises = [];
    json['data'].forEach((element) {
      excercises.add(Excercise.fromJson(element));
    });
    return BodyPartData(bodyPart: bodyPart, excercises: excercises);
  }
}

class Excercise {
  final String name;
  final String nameUrl;
  final List<String> aliases;
  final String iconUrl;
  final String category;
  final int id;

  Excercise({
    required this.name,
    required this.nameUrl,
    required this.aliases,
    required this.iconUrl,
    required this.category,
    required this.id,
  });

  get getName => name;
  get getNameUrl => nameUrl;
  get getAliases => aliases;
  get getIconUrl => iconUrl;
  get getCategory => category;
  get getIconUrlColored => iconUrl
      .replaceFirst("silhouettes", "illustrations")
      .replaceAll("256", "1000")
      .replaceFirst(".png", ".jpg");

  factory Excercise.fromJson(Map<String, dynamic> json) {
    List<String> aliases = [];
    json['aliases'].forEach((el) {
      aliases.add(el);
    });
    return Excercise(
      name: json['name'],
      nameUrl: json['name_url'],
      aliases: aliases,
      iconUrl: json['icon_url'],
      category: json['category'],
      id: json['id'],
    );
  }
}
