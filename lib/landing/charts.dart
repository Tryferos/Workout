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

  void updateList() {
    list = null;
    ExcerciseInfo.excercisesFrequent().then((value) {
      setState(() {
        list = Future.value(value);
      });
    });
  }

  @override
  void didUpdateWidget(ExcercisesChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('object');
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
            Text(
              'See All',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue),
            ),
          ],
        ),
        const Divider(
          height: 22,
          color: Colors.grey,
        ),
        FutureBuilder(
            builder: (context, snapshot) {
              print(snapshot.data);
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return const Text('No Data');
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
                          gap: '10%',
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

class ExcerciseChart {
  final String name;
  final int times;
  ExcerciseChart(this.name, this.times);
}
