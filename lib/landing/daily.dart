import 'package:flutter/material.dart';
import 'package:health/health.dart';

class DailyStats extends StatefulWidget {
  const DailyStats({super.key, required this.health});

  final HealthFactory? health;

  @override
  State<DailyStats> createState() => _DailyStatsState();
}

class _DailyStatsState extends State<DailyStats> {
  HealthFactory? get health => widget.health;
  Future<int>? steps;
  Future<double>? distance;
  Future<int>? minutes;
  DateTime date = DateTime.now();
  @override
  void initState() {
    super.initState();
    readData();
  }

  @override
  void didUpdateWidget(DailyStats oldWidget) {
    super.didUpdateWidget(oldWidget);
    readData();
  }

  void readData() async {
    List<HealthDataPoint> healthData = await getHealthData();
    setState(() {
      steps = null;
      minutes = null;
      distance = null;
    });
    int tmpSteps = 0;
    int tmpMinutes = 0;
    double tmpDistance = 0;
    for (var element in healthData) {
      switch (element.type) {
        case HealthDataType.STEPS:
          tmpSteps += int.parse(element.value.toString());
          break;
        case HealthDataType.MOVE_MINUTES:
          tmpMinutes += int.parse(element.value.toString());
          break;
        case HealthDataType.DISTANCE_DELTA:
          tmpDistance += double.parse(element.value.toString());
          break;
        default:
          break;
      }
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        steps = Future.value(tmpSteps);
        minutes = Future.value(tmpMinutes);
        distance = Future.value(tmpDistance);
      });
    });
  }

  Future<List<HealthDataPoint>> getHealthData() async {
    if (health == null) return [];
    DateTime endDate = date == DateTime.now()
        ? DateTime.now()
        : DateTime(date.year, date.month, date.day, 23, 59, 59);
    return await health!.getHealthDataFromTypes(
        DateTime(date.year, date.month, date.day, 0, 0, 0), endDate, [
      HealthDataType.STEPS,
      HealthDataType.MOVE_MINUTES,
      HealthDataType.DISTANCE_DELTA
    ]);
  }

  String formatDate() {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daily Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            InkWell(
                onTap: () async {
                  DateTime? newDate = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now());
                  if (newDate == null) return;
                  setState(() {
                    date = newDate;
                    readData();
                  });
                },
                child: Row(
                  children: [
                    Text(
                      formatDate(),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[200]),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.blue[300],
                    )
                  ],
                ))
          ],
        ),
        const Divider(
          height: 22,
          color: Colors.grey,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Box(
              label: 'Steps walked',
              value: formatSteps(),
              icon: Icons.directions_walk_outlined,
            ),
            Box(
              label: 'Time spent',
              value: formatMinutes(),
              icon: Icons.access_time_outlined,
            ),
            Box(
              label: 'Distance covered',
              value: formatDistance(),
              icon: Icons.place_outlined,
            ),
          ],
        )
      ],
    );
  }

  Future<dynamic> formatSteps() async {
    int? tmp = await steps;
    if (steps == null || tmp == null) return null;
    if (tmp < 1000) return '$tmp';
    return '${(tmp / 1000).toStringAsFixed(1)} k';
  }

  Future<dynamic> formatMinutes() async {
    int? tmp = await minutes;
    if (minutes == null || tmp == null) return null;
    if (tmp < 60) return '$tmp min';
    return '${(tmp / 60).toStringAsFixed(1)} h';
  }

  Future<dynamic> formatDistance() async {
    double? tmp = await distance;
    if (distance == null || tmp == null) return null;
    if (tmp < 1000) return '${tmp.toStringAsFixed(0)} m';
    return '${((await distance)! / 1000).toStringAsFixed(1)} km';
  }
}

class Box extends StatelessWidget {
  const Box(
      {super.key,
      required this.label,
      required this.value,
      required this.icon});

  final String label;
  final IconData icon;
  final Future<dynamic> value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.blue[200]!,
              offset: const Offset(0, 2),
              blurRadius: 3,
            )
          ], borderRadius: BorderRadius.circular(10), color: Colors.blue),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        FutureBuilder(
            future: value,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  snapshot.data!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
              return const CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 4,
              );
            })
      ],
    );
  }
}
