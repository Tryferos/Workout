import 'package:flutter/material.dart';
import 'package:flutter_application_1/session.dart';
import 'package:flutter_application_1/workout.dart';

class Index extends StatelessWidget {
  const Index({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const BodyPartSelector()));
              },
              child: const Text('Start a workout'))
        ],
      ),
    );
  }
}

class BodyPartSelector extends StatefulWidget {
  const BodyPartSelector({super.key});

  @override
  State<BodyPartSelector> createState() => _BodyPartSelectorState();
}

class _BodyPartSelectorState extends State<BodyPartSelector> {
  final List<String> selectedBodyParts = [];
  void onTap(String bodyPart) {
    if (selectedBodyParts.contains(bodyPart)) {
      setState(() {
        selectedBodyParts.remove(bodyPart);
      });
      return;
    }
    setState(() {
      selectedBodyParts.add(bodyPart);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Workout(onTap: onTap, selectedBodyParts: selectedBodyParts);
  }
}

const bodyParts = [
  'Chest',
  'Back',
  'Legs',
  'Shoulders',
  'Biceps',
  'Triceps',
  'Core',
  'Forearms',
  'Full Body',
];

class Workout extends StatelessWidget {
  const Workout(
      {super.key, required this.onTap, required this.selectedBodyParts});

  final void Function(String) onTap;
  final List<String> selectedBodyParts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Body Parts to train",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        addAutomaticKeepAlives: false,
        children: [
          for (var bodyPart in bodyParts)
            BodyPartItem(title: bodyPart, onTap: onTap)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.start),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  Session(selectedBodyParts: selectedBodyParts)));
        },
      ),
    );
  }
}
