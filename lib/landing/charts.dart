import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/excercise.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExcercisesChart extends StatefulWidget {
  const ExcercisesChart({super.key, required this.refresh});

  final bool refresh;

  @override
  State<ExcercisesChart> createState() => _ExcercisesChartState();
}

class _ExcercisesChartState extends State<ExcercisesChart> {
  Future<List<ExcerciseChart>>? list;
  @override
  void initState() {
    super.initState();
    updateList();
  }

  void updateList() async {
    list = null;
    final l = await ExcerciseInfo.excercisesFrequent();
    setState(() {
      list = Future.value(l);
    });
  }

  @override
  void didUpdateWidget(ExcercisesChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Frequent Excercises',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SparkWidget()));
              },
              child: const Text('View More',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue)),
            ),
          ],
        ),
        const Divider(
          height: 22,
          color: Colors.grey,
        ),
        FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return const Text("I don't have any data yet");
                }
                return SfCircularChart(
                    centerX: '50%',
                    centerY: '50%',
                    legend: const Legend(
                        toggleSeriesVisibility: true,
                        position: LegendPosition.bottom,
                        isVisible: true,
                        alignment: ChartAlignment.center,
                        overflowMode: LegendItemOverflowMode.wrap),
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                    ),
                    series: <CircularSeries>[
                      // Renders radial bar chart
                      RadialBarSeries<ExcerciseChart, String>(
                          radius: '100%',
                          cornerStyle: CornerStyle.bothCurve,
                          gap: '${(5 - (snapshot.data!.length + 1)) * 10}%',
                          trackColor: Colors.grey[200]!,
                          maximumValue: max(
                              snapshot.data!.isNotEmpty
                                  ? snapshot.data![0].times.toDouble()
                                  : 10,
                              10),
                          innerRadius: '${80 - snapshot.data!.length * 10}%',
                          dataSource: snapshot.data,
                          xValueMapper: (ExcerciseChart data, _) => data.name,
                          yValueMapper: (ExcerciseChart data, _) => data.times)
                    ]);
              }
              return const CircularProgressIndicator();
            },
            future: list)
      ],
    );
  }
}

class SparkWidget extends StatelessWidget {
  const SparkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: ((context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                }),
            title: Container(
                color: Colors.transparent,
                child: const Text("Excercise Analysis")),
            elevation: 4.0,
            centerTitle: true,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            expandedHeight: 50,
            floating: true,
            snap: true,
          )
        ];
      }),
      body: Column(
        children: [
          FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data == null) {
                    return const Text("I don't have any data yet");
                  }
                  return Expanded(
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: [
                        for (var excercise in snapshot.data!)
                          Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.blue),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          excercise.name,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${excercise.times} workouts',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SparkLine(name: excercise.name),
                              const SizedBox(
                                height: 40,
                              ),
                            ],
                          )
                      ],
                    ),
                  );
                }
                return const Text("I don't have any data yet");
              },
              future: ExcerciseInfo.excercisesFrequent()),
        ],
      ),
    ));
  }
}

class SparkLine extends StatelessWidget {
  const SparkLine({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
            height: 400,
            child: FutureBuilder(
                future: ExcerciseInfo.getExcercisesEffort(name),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data == null) {
                      return const Text("I don't have any data yet");
                    }
                    return SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      // Chart title
                      // Enable legend
                      legend: const Legend(isVisible: true),
                      // Enable tooltip
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <LineSeries<ExcerciseSpikeLineWeeklyInfo,
                          String>>[
                        LineSeries<ExcerciseSpikeLineWeeklyInfo, String>(
                            name: 'Daily Effort',
                            dataSource: snapshot.data!.weeklyInfo,
                            xValueMapper:
                                (ExcerciseSpikeLineWeeklyInfo sales, _) =>
                                    getDate(sales.ms),
                            yValueMapper:
                                (ExcerciseSpikeLineWeeklyInfo sales, _) =>
                                    sales.effort,
                            // Enable data label
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: true))
                      ],
                    );
                  }
                  return const Text("I don't have any data yet");
                })));
  }
}

//create a function that takes the current date and a parameter of the number of days to go back
//and returns a string date
String getDate(int ms) {
  final DateTime date = DateTime.fromMillisecondsSinceEpoch(ms);

  return '${date.day}/${date.month}/${date.year}';
}

class ExcerciseSpikeLine {
  List<ExcerciseSpikeLineWeeklyInfo> weeklyInfo = [];
  final String name;
  ExcerciseSpikeLine(this.name);
  @override
  String toString() {
    return '$name $weeklyInfo';
  }
}

class ExcerciseSpikeLineWeeklyInfo {
  final int ms;
  double effort;
  ExcerciseSpikeLineWeeklyInfo(this.ms, this.effort);
  @override
  String toString() {
    return '$ms $effort';
  }
}

class ExcerciseChart {
  final String name;
  final int times;
  ExcerciseChart(this.name, this.times);
}
