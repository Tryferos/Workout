import 'package:flutter/material.dart';
import 'package:flutter_application_1/landing/charts.dart';
import 'package:flutter_application_1/landing/goals.dart';
import 'package:flutter_application_1/landing/profiling.dart';
import 'package:flutter_application_1/landing/recent.dart';

import '../index.dart';

class LayoutLanding extends StatefulWidget {
  const LayoutLanding({super.key});

  @override
  State<LayoutLanding> createState() => _LayoutLandingState();
}

class _LayoutLandingState extends State<LayoutLanding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          addAutomaticKeepAlives: false,
          scrollDirection: Axis.vertical,
          children: [
            const ProfilingWidget(),
            const SizedBox(
              height: 30,
            ),
            const RecentWorkouts(),
            const SizedBox(
              height: 20,
            ),
            Button(
                title: 'Start Workout',
                clickHandler: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BodyPartSelector()),
                  );
                }),
            const SizedBox(
              height: 20,
            ),
            const ExcercisesChart(),
            const SizedBox(
              height: 20,
            ),
            const WorkoutGoals(),
            const SizedBox(
              height: 20,
            ),
            Button(
                title: 'Add Goals',
                clickHandler: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GoalCreation()),
                  );
                }),
            const SizedBox(
              height: 100,
            )
          ],
        ),
      )),
    );
  }
}

class Button extends StatelessWidget {
  const Button({super.key, required this.title, required this.clickHandler});
  final String title;
  final Function clickHandler;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: ElevatedButton(
          style: ButtonStyle(
            elevation: MaterialStateProperty.all<double>(3),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: const BorderSide(color: Colors.blue))),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          ),
          onPressed: () {
            clickHandler();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(
                width: 10,
              ),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const Icon(Icons.arrow_right_alt_outlined,
                  color: Colors.white, size: 32)
            ],
          )),
    );
  }
}
