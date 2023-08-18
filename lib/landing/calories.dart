import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CaloriesChart extends StatefulWidget {
  const CaloriesChart({super.key, required this.health});

  final HealthFactory? health;

  @override
  State<CaloriesChart> createState() => _CaloriesChartState();
}

class _CaloriesChartState extends State<CaloriesChart> {
  HealthFactory? get health => widget.health;
  List<_ChartData> data = [];
  @override
  void initState() {
    super.initState();
    readData();
  }

  @override
  void didUpdateWidget(CaloriesChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    readData();
  }

  void readData() async {
    if (health == null) return;
    DateTime now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      DateTime date =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      DateTime end = DateTime(date.year, date.month, date.day, 23, 59, 59);
      List<HealthDataPoint> tmp = await health!.getHealthDataFromTypes(
          date, i == 0 ? now : end, [HealthDataType.ACTIVE_ENERGY_BURNED]);
      if (tmp.isEmpty) continue;
      int calories =
          tmp.map((e) => double.parse(e.value.toString()).ceil()).reduce(
                (value, element) => value + element,
              );
      setState(() {
        data.add(_ChartData(date, calories.toDouble()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Calories Burnt',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Divider(
          height: 22,
          color: Colors.grey,
        ),
        SfCartesianChart(
            primaryXAxis: DateTimeAxis(
              dateFormat: DateFormat.MMMd(),
              interval: 1,
            ),
            primaryYAxis: NumericAxis(
                minimum: 0, maximum: null, interval: 250, visibleMinimum: 1000),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <ChartSeries<_ChartData, DateTime>>[
              ColumnSeries<_ChartData, DateTime>(
                  dataSource: data,
                  gradient: LinearGradient(colors: [
                    Colors.blue[100]!,
                    Colors.blue[300]!,
                  ], stops: const [
                    0.0,
                    0.6
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  borderRadius: BorderRadius.circular(10),
                  xValueMapper: (_ChartData data, _) => data.x,
                  yValueMapper: (_ChartData data, _) => data.y,
                  name: 'Calories Burnt',
                  color: const Color.fromRGBO(8, 142, 255, 1))
            ]),
      ],
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final DateTime x;
  final double y;
}
