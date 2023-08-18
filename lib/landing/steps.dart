import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StepsSparkLine extends StatefulWidget {
  const StepsSparkLine({super.key, required this.health});
  final HealthFactory? health;

  @override
  State<StepsSparkLine> createState() => _StepsSparkLineState();
}

enum DaysOffset { W, M }

class _HealthDataPoint {
  final int value;
  final DateTime date;
  _HealthDataPoint(this.value, this.date);
}

class _StepsSparkLineState extends State<StepsSparkLine> {
  HealthFactory? get health => widget.health;
  Future<List<_HealthDataPoint>>? steps;
  List<_HealthDataPoint> month = [];
  List<_HealthDataPoint> day = [];
  DaysOffset selected = DaysOffset.W;
  @override
  void initState() {
    super.initState();
    if (health == null) {
      steps = Future.value([]);
      return;
    }
    readData();
  }

  @override
  void didUpdateWidget(StepsSparkLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (health == null) {
      steps = Future.value([]);
      return;
    }
    readData();
  }

  int get daysOffset {
    switch (selected) {
      case DaysOffset.W:
        return 7;
      case DaysOffset.M:
        return 30;
    }
  }

  void readData() async {
    if (selected == DaysOffset.W && day.isNotEmpty) {
      setState(() {
        steps = Future.value(day);
      });
      return;
    }
    if (selected == DaysOffset.M && month.isNotEmpty) {
      setState(() {
        steps = Future.value(month);
      });
      return;
    }
    List<HealthDataPoint> healthData = await health!.getHealthDataFromTypes(
        DateTime.now().subtract(Duration(days: daysOffset)),
        DateTime.now(),
        [HealthDataType.STEPS]);
    List<_HealthDataPoint> healthData2 = [];
    for (var i = 0; i < (daysOffset); i++) {
      int value = 0;
      DateTime now = DateTime.now();
      DateTime date = DateTime(now.year, now.month, now.day);
      date = date.subtract(Duration(days: i + 1));
      healthData
          .where((element) => element.dateFrom.day == date.day)
          .forEach((element) {
        value += int.parse(element.value.toString());
      });
      healthData2.add(_HealthDataPoint(value, date));
    }
    setState(() {
      if (selected == DaysOffset.W) {
        day = healthData2;
      } else {
        month = healthData2;
      }
      steps = Future.value(healthData2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0, 2),
              blurRadius: 3,
            )
          ], borderRadius: BorderRadius.circular(10), color: Colors.blue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text(
                      "Steps",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.directions_walk,
                      color: Colors.white,
                    ),
                  ],
                ),
                Row(
                  children: [
                    ...DaysOffset.values.map(
                      (e) => InkWell(
                        onTap: () {
                          setState(() {
                            selected = e;
                            steps = null;
                            readData();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: selected == e
                              ? BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10))
                              : null,
                          child: Text(
                            e.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color:
                                    selected == e ? Colors.blue : Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        FutureBuilder(
            future: steps,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == null) {
                  return const Text("I don't have any data yet");
                }
                return SizedBox(
                  height: 400,
                  child: SfCartesianChart(
                    primaryXAxis: DateTimeAxis(
                      interval: selected == DaysOffset.M ? 7 : 1,
                      dateFormat: DateFormat('dd/MM'),
                      minimum:
                          DateTime.now().subtract(Duration(days: daysOffset)),
                      maximum: DateTime.now().subtract(const Duration(days: 1)),
                    ),
                    primaryYAxis: NumericAxis(
                      visibleMinimum: 0,
                      maximum: null,
                      interval: 2500,
                    ),
                    // Enable legend
                    legend: const Legend(
                        isVisible: true, toggleSeriesVisibility: false),
                    trackballBehavior: TrackballBehavior(
                        enable: true,
                        tooltipSettings: const InteractiveTooltip(
                            enable: true,
                            color: Colors.blue,
                            format: 'point.x : point.y')),
                    // Enable tooltip
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                    ),
                    series: <AreaSeries<_HealthDataPoint, DateTime>>[
                      AreaSeries<_HealthDataPoint, DateTime>(
                        color: Colors.blue[100]!,
                        borderDrawMode: BorderDrawMode.excludeBottom,
                        borderColor: Colors.blue,
                        borderWidth: 2,
                        gradient: LinearGradient(
                            colors: [
                              Colors.blue[100]!,
                              Colors.blue[300]!,
                            ],
                            stops: const [
                              0.3,
                              0.9
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter),
                        isVisible: true,
                        name: 'Steps',
                        dataSource: snapshot.data!,
                        xValueMapper: (_HealthDataPoint point, _) => point.date,
                        yValueMapper: (_HealthDataPoint point, _) =>
                            point.value,
                        // Enable data label
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: false,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const Text("I don't have any data yet");
            }),
      ],
    );
  }
}
