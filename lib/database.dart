import 'package:sqflite/sqflite.dart';

import 'excercise.dart';
import 'main.dart';

class Session {
  Session(
      {required this.date,
      required this.duration,
      this.id,
      this.excerciseInfo});
  final int date;
  final int duration;
  final int? id;
  List<ExcerciseInfo>? excerciseInfo;

  static Future<bool> insertSession(Session session) async {
    // Get a reference to the database.
    final db = await database;
    if (db == null) return false;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    final int sessionId = await db.insert('session', session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    for (var excercise in session.excerciseInfo!) {
      final int excerciseInfoId = await db.insert(
          'excerciseInfo', excercise.toMap(sessionId),
          conflictAlgorithm: ConflictAlgorithm.replace);
      for (var set in excercise.sets) {
        await db.insert('sets', set.toMap(excerciseInfoId),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
    return true;
  }

  static Future<List<Session>> sessions() async {
    // Get a reference to the database.
    final db = await database;
    if (db == null) return [];

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> sessionMap =
        await db.query('session', orderBy: 'date DESC');
    List<List<ExcerciseInfo>> excerciseInfo = [];
    for (var session in sessionMap) {
      excerciseInfo.add(await ExcerciseInfo.excercisesInfo(session['id']));
    }

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(sessionMap.length, (i) {
      return Session(
        id: sessionMap[i]['id'],
        date: sessionMap[i]['date'],
        duration: sessionMap[i]['duration'],
        excerciseInfo: excerciseInfo[i],
      );
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'duration': duration,
    };
  }

  @override
  String toString() {
    return 'Session{date: $date, duration: $duration, id: $id, excerciseInfo: $excerciseInfo,}';
  }
}
