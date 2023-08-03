import 'package:flutter/material.dart';
import 'package:flutter_application_1/session.dart';
import 'package:flutter_application_1/workout.dart';

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
        toolbarHeight: 70,
        centerTitle: true,
        title: const Text(
          "Select Body Parts",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.blue,
        elevation: 2,
      ),
      body: GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          scrollDirection: Axis.vertical,
          // Generate 100 widgets that display their index in the List.
          children: List.generate(bodyParts.length, (index) {
            return BodyPartItem(
                title: bodyParts[index],
                onTap: onTap,
                index: selectedBodyParts.indexOf(bodyParts[index]));
          })),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          if (selectedBodyParts.isEmpty) return;
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  Session(selectedBodyParts: selectedBodyParts)));
        },
        child: const Icon(
          Icons.start,
          color: Colors.white,
        ),
      ),
    );
  }
}


// ListView(
//         scrollDirection: Axis.vertical,
//         addAutomaticKeepAlives: false,
//         children: [
//           for (var bodyPart in bodyParts)
//             Column(
//               children: [
//                 BodyPartItem(
//                   title: bodyPart,
//                   onTap: onTap,
//                   index: selectedBodyParts.indexOf(bodyPart),
//                 ),
//                 const Divider(
//                   color: Colors.black,
//                   height: 0,
//                   thickness: 0.2,
//                 )
//               ],
//             )
//         ],
//       ),