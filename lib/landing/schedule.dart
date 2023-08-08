import 'package:flutter/material.dart';
import 'package:flutter_application_1/database.dart';

import '../main.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

enum Days { Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday }

class _ScheduleState extends State<Schedule> {
  Future<List<_ScheduleItem>>? schedule;
  Days selectedDay = Days.Monday;
  @override
  void initState() {
    super.initState();
    _ScheduleItem.getSchedule().then((value) {
      setState(() {
        schedule = Future.value(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Schedule',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Divider(
          height: 22,
          color: Colors.grey,
        ),
        SizedBox(
          height: 65,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return FutureBuilder(
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return getDayWidget(index, snapshot.data as List<Session>);
                  }
                  return const Center(
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                future: Session.sessionsRecent(DateTime.now().weekday - 1),
              );
            },
            itemCount: Days.values.length,
            separatorBuilder: (context, index) {
              return const SizedBox(
                width: 12,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget getDayWidget(int index, List<Session> session) {
    Days day = Days.values[index];
    DateTime date = DateTime.now();
    Days cDay = Days.values[date.weekday - 1];
    bool isCurrentDay = day == cDay;
    bool isUpcoming = day.index > cDay.index;
    bool hasWorkedOut = sessions
            .firstWhere(
                (element) =>
                    DateTime.fromMillisecondsSinceEpoch(element.date).weekday ==
                    index + 1,
                orElse: () => Session(id: 0, date: 0, duration: 0))
            .id !=
        0;
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 50,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        decoration: BoxDecoration(
          boxShadow: [
            !isUpcoming
                ? BoxShadow(
                    color: Colors.grey.withOpacity(0.25),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 3), // changes position of shadow
                  )
                : const BoxShadow(color: Colors.transparent),
          ],
          border:
              Border.all(color: Colors.grey[300]!, width: isUpcoming ? 1.5 : 0),
          borderRadius: BorderRadius.circular(10),
          color: isCurrentDay
              ? Colors.blue[700]
              : isUpcoming
                  ? Colors.white
                  : hasWorkedOut
                      ? Colors.green[500]
                      : Colors.red[400],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              day.name.toString().substring(0, 3),
              style: TextStyle(
                  color: isUpcoming ? Colors.grey[400] : Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsets.only(top: isUpcoming ? 2 : 0)),
            Icon(
                isCurrentDay
                    ? Icons.watch_later
                    : hasWorkedOut
                        ? Icons.check_circle
                        : isUpcoming
                            ? Icons.circle
                            : Icons.cancel,
                color: isUpcoming ? Colors.grey[300] : Colors.white,
                size: isUpcoming ? 8 : 18)
          ],
        ),
      ),
    );
  }
}

class _ScheduleItem {
  final Days day;
  final List<String> bodyParts;
  _ScheduleItem(this.day, this.bodyParts);

  static Future<List<_ScheduleItem>> getSchedule() async {
    final db = await database;
    if (db == null) return [];
    List<Map<String, dynamic>> sMap = await db.query('Schedule');
    List<_ScheduleItem> schedule = [];
    for (var item in sMap) {
      schedule
          .add(_ScheduleItem(item['day'], [...item['bodyParts'].split(',')]));
    }

    return schedule;
  }
}

// ignore: unused_element
