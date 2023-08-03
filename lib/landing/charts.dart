import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/excercise.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../bodyPart.dart';

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
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Frequent Excercises',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

class SparkWidget extends StatefulWidget {
  const SparkWidget({super.key});

  @override
  State<SparkWidget> createState() => _SparkWidgetState();
}

enum TimeOffset { d, m, y }

class _SparkWidgetState extends State<SparkWidget> {
  TimeOffset selectedTimeOffset = TimeOffset.d;
  List<ExcerciseChart> list = [];
  String? selectedExcerciseName;
  void handleChange(TimeOffset offset) {
    setState(() {
      selectedTimeOffset = offset;
    });
  }

  @override
  void initState() {
    super.initState();
    ExcerciseInfo.excercisesFrequent().then((value) {
      if (value.isEmpty) return;
      setState(() {
        list = value;
        selectedExcerciseName = value[0].name;
      });
    });
  }

  void handleChangeExc(String exc) {
    if (!mounted) return;
    setState(() {
      selectedExcerciseName = exc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      FutureBuilder(
          builder: (context, snapshot) {
            return SizedBox(
              height: 480,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0, 2),
                            blurRadius: 3,
                          )
                        ],
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blue),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  backgroundColor: Colors.white,
                                  elevation: 0,
                                  context: context,
                                  builder: (context) {
                                    return SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                (list.length + 0.5) /
                                                10,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: SearchExcercise(
                                          fList: list,
                                          handleChangeExc: handleChangeExc,
                                        ));
                                  },
                                );
                              },
                              child: Text(
                                  selectedExcerciseName ?? 'Select Excercise',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))),
                          TimeOffsetWidget(
                              currentOffset: selectedTimeOffset,
                              change: handleChange),
                        ],
                      ),
                    ),
                  ),
                  snapshot.hasData
                      ? SparkLine(
                          name: snapshot.data!.name, offset: selectedTimeOffset)
                      : const Text("I don't have any data yet")
                ],
              ),
            );
          },
          future: selectedExcerciseName != null
              ? ExcerciseInfo.getExcercisesEffort(selectedExcerciseName!)
              : Future.value(null)),
    ]);
  }
}

class SearchExcercise extends StatefulWidget {
  const SearchExcercise(
      {super.key, required this.handleChangeExc, required this.fList});

  final void Function(String) handleChangeExc;
  final List<ExcerciseChart> fList;

  @override
  State<SearchExcercise> createState() => _SearchExcerciseState();
}

class _SearchExcerciseState extends State<SearchExcercise> {
  Future<List<Excercise>>? list;
  @override
  void initState() {
    super.initState();
    fetchExc();
  }

  void fetchExc() async {
    List<Excercise> tmp = [];
    for (var fItem in widget.fList) {
      tmp.add(await ExcerciseInfo.fetchExcercise(fItem.name));
    }
    setState(() {
      list = Future.value(tmp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
      child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height *
                (widget.fList.length + 0.5) /
                10,
            child: FutureBuilder(
              future: list,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    physics: const ScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: [
                      const Center(
                          child: Text(
                        'Select an Excercise',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      )),
                      const SizedBox(
                        height: 10,
                      ),
                      ...snapshot.data!.map((excercise) {
                        return ListTile(
                          onTap: () {
                            widget.handleChangeExc(excercise.getName);
                            Navigator.of(context).pop();
                          },
                          tileColor: Colors.transparent,
                          trailing: Container(
                            width: 32,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.transparent),
                            child: const Icon(
                              Icons.auto_graph,
                              size: 24,
                              color: Colors.blue,
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
                      }).toList()
                    ],
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                );
              },
            ),
          )),
    );
  }
}

class TimeOffsetWidget extends StatelessWidget {
  const TimeOffsetWidget(
      {super.key, required this.change, required this.currentOffset});

  final void Function(TimeOffset) change;
  final TimeOffset currentOffset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...TimeOffset.values.map(
          (e) {
            return InkWell(
              onTap: () {
                change(e);
              },
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: e == currentOffset ? Colors.white : Colors.blue),
                  child: Text(e.name.toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: e == currentOffset
                              ? Colors.blue
                              : Colors.white))),
            );
          },
        ).toList(),
      ],
    );
  }
}

class SparkLine extends StatelessWidget {
  const SparkLine({super.key, required this.name, required this.offset});

  final TimeOffset offset;

  final String name;

  String getTextOffset() {
    switch (offset) {
      case TimeOffset.d:
        return 'Daily';
      case TimeOffset.m:
        return 'Monthly';
      case TimeOffset.y:
        return 'Yearly';
    }
  }

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
                            name: '${getTextOffset()} Effort',
                            dataSource: snapshot.data!.weeklyInfo,
                            xValueMapper:
                                (ExcerciseSpikeLineWeeklyInfo sales, _) =>
                                    getDate(sales.ms, offset),
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
String getDate(int ms, TimeOffset offset) {
  final DateTime date = DateTime.fromMillisecondsSinceEpoch(ms);
  //get name of month from date.month

  switch (offset) {
    case TimeOffset.d:
      return '${date.day}/${date.month}/${date.year}';
    case TimeOffset.m:
      return DateFormat("MMMM").format(date);
    case TimeOffset.y:
      return '${date.year}';
  }
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
