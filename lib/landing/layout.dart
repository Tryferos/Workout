import 'package:flutter/material.dart';
import 'package:flutter_application_1/landing/charts.dart';
import 'package:flutter_application_1/landing/profiling.dart';

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
      body: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          addAutomaticKeepAlives: false,
          scrollDirection: Axis.vertical,
          children: const [
            ProfilingWidget(),
            SizedBox(
              height: 40,
            ),
            StartWorkoutButton(),
            SizedBox(
              height: 20,
            ),
            ExcercisesChart(),
          ],
        ),
      )),
    );
  }
}

class StartWorkoutButton extends StatelessWidget {
  const StartWorkoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: const BorderSide(color: Colors.blue))),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BodyPartSelector()),
          );
        },
        child: const Text(
          'Start Workout',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
