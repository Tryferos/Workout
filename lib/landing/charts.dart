import 'package:flutter/material.dart';
import 'package:flutter_application_1/excercise.dart';
import 'package:pie_chart/pie_chart.dart';

class ExcercisesChart extends StatefulWidget {
  const ExcercisesChart({super.key});

  @override
  State<ExcercisesChart> createState() => _ExcercisesChartState();
}

class _ExcercisesChartState extends State<ExcercisesChart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) return const Text('no data');
            return PieChart(
              dataMap: snapshot.data!,
              animationDuration: const Duration(milliseconds: 800),
              chartLegendSpacing: 16,
              chartRadius: MediaQuery.of(context).size.width / 2.1,
              initialAngleInDegree: 0,
              chartType: ChartType.disc,
              gradientList: const [],
              ringStrokeWidth: 32,
              colorList: const [
                Colors.blue,
                Colors.red,
                Colors.green,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
                Colors.teal,
                Colors.pink,
                Colors.indigo,
                Colors.lime,
                Colors.cyan,
                Colors.amber,
                Colors.brown,
                Colors.grey,
                Colors.blueGrey,
              ],
              legendOptions: const LegendOptions(
                showLegendsInRow: false,
                legendPosition: LegendPosition.right,
                showLegends: true,
                legendShape: BoxShape.circle,
                legendTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              chartValuesOptions: const ChartValuesOptions(
                chartValueStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                showChartValueBackground: true,
                showChartValues: true,
                showChartValuesInPercentage: true,
                showChartValuesOutside: false,
                decimalPlaces: 1,
              ),
            );
          }
          return const CircularProgressIndicator();
        },
        future: ExcerciseInfo.excercisesFrequent());
  }
}
