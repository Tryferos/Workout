import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bodyPart.dart';
import 'package:vertical_weight_slider/vertical_weight_slider.dart';

import '../excercise.dart' as Excercise_Package;
import '../excercise.dart';
import 'goals.dart';

class GoalStepperWidget extends StatefulWidget {
  const GoalStepperWidget({super.key});

  @override
  State<GoalStepperWidget> createState() => _GoalStepperWidgetState();
}

class _GoalStepperWidgetState extends State<GoalStepperWidget> {
  String goalType = 'Workout';
  int _index = 0;
  String title = '';
  Excercise? selectedExcercise;
  Excercise_Package.Set? excerciseInfo;
  int workouts = 0;
  DateTime? deadline;
  void changeWorkouts(int n) {
    setState(() {
      workouts = n;
    });
  }

  void changeDeadline(DateTime newDeadline) {
    setState(() {
      deadline = newDeadline;
    });
  }

  void changeExcerciseInfo(Excercise_Package.Set newExcerciseInfo) {
    setState(() {
      excerciseInfo = newExcerciseInfo;
    });
  }

  void changeExcercise(Excercise newExcercise) {
    setState(() {
      selectedExcercise = newExcercise;
    });
  }

  void changeTitle(String title) {
    setState(() {
      this.title = title;
    });
  }

  void writeGoal() async {
    if (goalType == 'Workout') {
      WorkoutGoal goal = WorkoutGoal(
          number: workouts,
          untilDate: deadline!,
          title: title,
          date: DateTime.now());
      goal.writeGoal();
    } else {
      Set startingSet = Goal.getSet(selectedExcercise!.name);

      ExcerciseGoalItem item = ExcerciseGoalItem(
          name: selectedExcercise!.name,
          bodyPart: selectedExcercise!.bodyPart,
          iconUrl: selectedExcercise!.getIconUrlColored,
          goalSet: excerciseInfo!,
          startingSet: startingSet);
      SingleExcerciseGoal goal = SingleExcerciseGoal(
          excercise: item, title: title, date: DateTime.now());
      goal.writeGoal();
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        currentStep: _index,
        onStepContinue: () {
          if (_index >= 4) return writeGoal();
          setState(() {
            _index++;
          });
        },
        onStepCancel: () {
          if (_index == 0) return;
          setState(() {
            _index--;
          });
        },
        stepIconBuilder: (stepIndex, stepState) {
          return const Icon(Icons.check, color: Colors.white);
        },
        controlsBuilder: (context, details) {
          return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (details.onStepCancel != null)
                    ElevatedButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back')),
                  if (details.onStepContinue != null)
                    if (goalType == 'Excercise' &&
                        details.currentStep == 1 &&
                        selectedExcercise == null)
                      ElevatedButton(
                          onPressed: () {},
                          child: const Text('Select an excercise'))
                    else if (goalType == 'Excercise' &&
                        details.currentStep == 2 &&
                        excerciseInfo == null)
                      ElevatedButton(
                          onPressed: () {},
                          child: const Text('Select an excercise'))
                    else if (goalType == 'Workout' &&
                        details.currentStep == 1 &&
                        workouts == 0)
                      ElevatedButton(
                          onPressed: () {},
                          child: const Text('Select a number'))
                    else if (goalType == 'Workout' &&
                        details.currentStep == 2 &&
                        deadline == null)
                      ElevatedButton(
                          onPressed: () {},
                          child: const Text('Select a deadline'))
                    else if (details.currentStep == 3 && title.length < 4)
                      ElevatedButton(
                          onPressed: () {}, child: const Text('Set a title'))
                    else
                      ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: Text(
                              details.currentStep == 4 ? 'Finish' : 'Next')),
                ],
              ));
        },
        steps: [
          Step(
            title: const Text('Select type of the goal you want to set'),
            content: DropdownMenu(
              initialSelection: goalType,
              hintText: 'Select the goal',
              onSelected: (value) {
                setState(() {
                  goalType = value!;
                });
              },
              dropdownMenuEntries: const [
                DropdownMenuEntry(
                  leadingIcon: Icon(Icons.sports_gymnastics_outlined),
                  label: 'Workout',
                  value: 'Workout',
                ),
                DropdownMenuEntry(
                    label: 'Excercise',
                    value: 'Excercise',
                    leadingIcon: Icon(Icons.fitness_center_outlined)),
              ],
            ),
          ),
          if (goalType == 'Workout')
            ...getWorkoutGoalStep()
          else
            ...getExcercisesStep(),
          Step(
              content: TitleWidget(changeTitle: changeTitle),
              title: const Text('Add a title for your goal')),
          const Step(
              content: Text(''),
              title: Text(
                  "You're almost finished! Check your info and start your goal")),
        ]);
  }

  List<Step> getExcercisesStep() {
    return [
      Step(
          content: AddExcerciseWidget(
            excerciseName: selectedExcercise?.name,
            changeExcercise: changeExcercise,
          ),
          title: const Text('Select an Excercise')),
      Step(
          content: AddExcerciseInfo(
            changeExcerciseInfo: changeExcerciseInfo,
          ),
          title: const Text('Enter excercise goals')),
    ];
  }

  List<Step> getWorkoutGoalStep() {
    return [
      Step(
          title: const Text('Select the number of workouts you want to do'),
          content: WorkoutsSlider(
            changeWorkouts: changeWorkouts,
          )),
      Step(
          content: DatePickerWidget(changeDeadline: changeDeadline),
          title: const Text('Choose a deadline for your goal')),
    ];
  }
}

class TitleWidget extends StatefulWidget {
  const TitleWidget({super.key, required this.changeTitle});

  final void Function(String) changeTitle;

  @override
  State<TitleWidget> createState() => _TitleWidgetState();
}

class _TitleWidgetState extends State<TitleWidget> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: (value) => setState(() {
        widget.changeTitle(value);
      }),
      decoration: const InputDecoration(
          focusedBorder: UnderlineInputBorder(),
          border: UnderlineInputBorder(),
          labelText: 'Enter a title'),
    );
  }
}

//Exercises Goal
class AddExcerciseInfo extends StatefulWidget {
  const AddExcerciseInfo({super.key, required this.changeExcerciseInfo});

  final void Function(Excercise_Package.Set) changeExcerciseInfo;

  @override
  State<AddExcerciseInfo> createState() => _AddExcerciseInfoState();
}

class _AddExcerciseInfoState extends State<AddExcerciseInfo> {
  late WeightSliderController _weightController;
  late WeightSliderController _repsController;
  double _weight = 10;
  double _reps = 4;
  @override
  void initState() {
    super.initState();
    _weightController = WeightSliderController(
        initialWeight: _weight, minWeight: 0, interval: 1);
    _repsController = WeightSliderController(
        initialWeight: _weight, minWeight: 1, interval: 1);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 50,
                child: Text(
                  "${_weight.toStringAsFixed(0)} kg",
                  style: const TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.w500),
                ),
              ),
              VerticalWeightSlider(
                controller: _weightController,
                decoration: const PointerDecoration(
                  width: 130.0,
                  height: 3.0,
                  largeColor: Color(0xFF898989),
                  mediumColor: Color(0xFFC5C5C5),
                  smallColor: Color(0xFFF0F0F0),
                  gap: 30.0,
                ),
                onChanged: (double value) {
                  setState(() {
                    _weight = value;
                    widget.changeExcerciseInfo(Excercise_Package.Set(
                        reps: _reps.round(), weight: _weight));
                  });
                },
                maxWeight: 300,
                indicator: Container(
                  height: 3.0,
                  width: 200.0,
                  alignment: Alignment.centerLeft,
                  color: Colors.red[300],
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          width: 40,
        ),
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                child: Text(
                  "${_reps.toStringAsFixed(0)} reps",
                  style: const TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.w500),
                ),
              ),
              VerticalWeightSlider(
                controller: _repsController,
                decoration: const PointerDecoration(
                  width: 130.0,
                  height: 3.0,
                  largeColor: Color(0xFF898989),
                  mediumColor: Color(0xFFC5C5C5),
                  smallColor: Color(0xFFF0F0F0),
                  gap: 30.0,
                ),
                onChanged: (double value) {
                  setState(() {
                    _reps = value;
                  });
                },
                maxWeight: 30,
                indicator: Container(
                  height: 3.0,
                  width: 200.0,
                  alignment: Alignment.centerLeft,
                  color: Colors.red[300],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class AddExcerciseWidget extends StatefulWidget {
  const AddExcerciseWidget(
      {super.key, required this.changeExcercise, required this.excerciseName});

  final void Function(Excercise) changeExcercise;
  final String? excerciseName;

  @override
  State<AddExcerciseWidget> createState() => _AddExcerciseWidgetState();
}

class _AddExcerciseWidgetState extends State<AddExcerciseWidget> {
  List<Excercise>? excercises;
  @override
  void initState() {
    super.initState();
    print('init');
    if (!mounted) return;
    Excercise.fetchAllExcercises().then((data) => setState(() {
          excercises = data;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownSearch<String>(
          filterFn: (item, filter) {
            if (!mounted) return false;
            return item.toLowerCase().contains(filter.toLowerCase());
          },
          popupProps: PopupProps.bottomSheet(
            searchDelay: const Duration(milliseconds: 500),
            fit: FlexFit.tight,
            itemBuilder: (context, item, isSelected) {
              if (!mounted) return const Placeholder();
              int index =
                  excercises!.indexWhere((element) => element.name == item);
              if (index == -1) return const ListTile();
              Excercise excercise = excercises![index];
              return ListTile(
                title: Text(
                  item,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                trailing: Text(
                  excercise.bodyPart,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                leading: Image.network(excercise.getIconUrlColored),
              );
            },
            showSelectedItems: false,
            bottomSheetProps: const BottomSheetProps(
                backgroundColor: Colors.white, elevation: 0),
            searchFieldProps: const TextFieldProps(
              decoration: InputDecoration(
                icon: Icon(Icons.search),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                hintText: "Search an excercise",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            showSearchBox: true,
            listViewProps: const ListViewProps(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
            ),
            title: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                  child: Text(
                'Select an Excercise',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )),
            ),
          ),
          asyncItems: (String filter) async {
            if (!mounted) return [];
            return Future.value((excercises)!.map((e) => e.name).toList());
          },
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: widget.excerciseName ?? "Excercises",
              hintText: "pick an excercise",
            ),
          ),
          onChanged: (newItem) {
            if (!mounted) return;
            widget.changeExcercise(
                excercises!.firstWhere((element) => element.name == newItem));
          },
        )
      ],
    );
  }
}

// Workout Goal

class DatePickerWidget extends StatefulWidget {
  const DatePickerWidget({super.key, required this.changeDeadline});

  final void Function(DateTime) changeDeadline;

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  @override
  Widget build(BuildContext context) {
    return CalendarDatePicker(
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
        onDateChanged: (newDate) {
          widget.changeDeadline(newDate);
        });
  }
}

class WorkoutsSlider extends StatefulWidget {
  const WorkoutsSlider({super.key, required this.changeWorkouts});

  final void Function(int) changeWorkouts;

  @override
  State<WorkoutsSlider> createState() => _WorkoutsSliderState();
}

class _WorkoutsSliderState extends State<WorkoutsSlider> {
  late WeightSliderController _controller;
  double _weight = 10;
  @override
  void initState() {
    super.initState();
    _controller = WeightSliderController(
        initialWeight: _weight, minWeight: 1, interval: 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 50,
          child: Text(
            "${_weight.toStringAsFixed(0)} Workouts",
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
          ),
        ),
        VerticalWeightSlider(
          controller: _controller,
          decoration: const PointerDecoration(
            width: 130.0,
            height: 3.0,
            largeColor: Color(0xFF898989),
            mediumColor: Color(0xFFC5C5C5),
            smallColor: Color(0xFFF0F0F0),
            gap: 30.0,
          ),
          onChanged: (double value) {
            setState(() {
              _weight = value;
              widget.changeWorkouts(_weight.round());
            });
          },
          indicator: Container(
            height: 3.0,
            width: 200.0,
            alignment: Alignment.centerLeft,
            color: Colors.red[300],
          ),
        )
      ],
    );
  }
}
