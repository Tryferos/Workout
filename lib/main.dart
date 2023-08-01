import 'package:flutter/material.dart';
import 'package:flutter_application_1/database.dart';
import 'package:flutter_application_1/landing/layout.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database>? database;
List<Session> sessions = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  database = openDatabase(
    join(await getDatabasesPath(), "excercise_info_database.db"),
    onOpen: (db) async {
      await db.execute("PRAGMA foreign_keys=ON");
    },
    onCreate: (db, version) async {
      //Goals
      await db.execute(
          'create table if not exists Goals(id integer primary key autoincrement not null, title text, date integer)');
      await db.execute(
          'create table if not exists GoalExcerciseItem(id integer primary key autoincrement not null, name text, startingReps integer, startingWeight double, goalReps integer, goalWeight double,bodyPart text, icon_url text)');
      await db.execute(
          'create table if not exists WorkoutGoal(id integer primary key autoincrement not null, number integer, untilDate integer, goalId integer,FOREIGN KEY(goalId) REFERENCES Goals(id) ON DELETE CASCADE )');
      await db.execute(
          'create table if not exists ExcerciseGoal(id integer primary key autoincrement not null, goalId integer,goalExcerciseItemId integer,FOREIGN KEY(goalId) REFERENCES Goals(id) ON DELETE CASCADE , FOREIGN KEY(goalExcerciseItemId) REFERENCES GoalExcerciseItem(id) ON DELETE CASCADE )');

      //Workout
      await db.execute(
        'create table if not exists Notes(id integer primary key autoincrement not null, note text, excerciseName text, date integer)',
      );
      await db.execute(
          'create table if not exists Sets(id integer primary key autoincrement not null, reps integer, weight double, excerciseInfoId integer, FOREIGN KEY(excerciseInfoId) REFERENCES excerciseInfo(id) ON DELETE CASCADE )');
      await db.execute(
          "CREATE TABLE if not exists ExcerciseInfo(id integer primary key autoincrement not null, excerciseName text, notes text,sessionId integer,FOREIGN KEY(sessionId) REFERENCES Session(id) ON DELETE CASCADE )");
      return db.execute(
          'create table if not exists Session(id integer primary key autoincrement not null, date integer, duration integer)');
    },
    version: 1,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = true;
  @override
  void initState() {
    super.initState();
    print('init');
    Session.sessions().then((data) {
      sessions = data;
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            backgroundColor: Colors.transparent,
            toolbarOpacity: 0,
          ),
          extendBodyBehindAppBar: true,
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : const LayoutLanding()),
    );
  }
}
