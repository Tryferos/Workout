import 'package:flutter/material.dart';
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
      body: const Center(
        child: ProfilingWidget(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BodyPartSelector()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
