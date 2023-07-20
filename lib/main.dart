import 'package:flutter/material.dart';
import 'package:flutter_application_1/database.dart';
import 'package:flutter_application_1/index.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database>? database;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  database = openDatabase(
    join(await getDatabasesPath(), "excercise_info_database.db"),
    onCreate: (db, version) async {
      await db.execute(
          'create table if not exists Sets(id integer primary key autoincrement not null, reps integer, weight double, excerciseInfoId integer, FOREIGN KEY(excerciseInfoId) REFERENCES excerciseInfo(id))');
      await db.execute(
          "CREATE TABLE if not exists ExcerciseInfo(id integer primary key autoincrement not null, excerciseName text, sessionId integer,FOREIGN KEY(sessionId) REFERENCES Session(id))");
      return db.execute(
          'create table if not exists Session(id integer primary key autoincrement not null, date integer, duration integer)');
    },
    version: 1,
  );
  runApp(const MyApp());
  print(await Session.sessions());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(),
        body: const Index(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
        // bottomNavigationBar: BottomNavigationBar(items: [
        //   const BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'Home'),
        //   const BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'Home'),
        //   const BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'Home'),
        // ]),
      ),
    );
  }
}
