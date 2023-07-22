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
    onCreate: (db, version) async {
      await db.execute(
        'create table if not exists Notes(id integer primary key autoincrement not null, note text, excerciseName text, date integer)',
      );
      await db.execute(
          'create table if not exists Sets(id integer primary key autoincrement not null, reps integer, weight double, excerciseInfoId integer, FOREIGN KEY(excerciseInfoId) REFERENCES excerciseInfo(id))');
      await db.execute(
          "CREATE TABLE if not exists ExcerciseInfo(id integer primary key autoincrement not null, excerciseName text, notes text,sessionId integer,FOREIGN KEY(sessionId) REFERENCES Session(id))");
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
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Wotfard',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : const LayoutLanding(),
      ),
    );
  }
}
