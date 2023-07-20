import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';

class BodyPartItem extends StatefulWidget {
  const BodyPartItem({super.key, required this.title, required this.onTap});
  final String title;
  final void Function(String) onTap;
  @override
  State<BodyPartItem> createState() => _BodyPartItemState();
}

class _BodyPartItemState extends State<BodyPartItem> {
  bool value = false;
  String get title => widget.title;
  String lastWorkout = '';

  @override
  void initState() {
    super.initState();
    int index = sessions.indexWhere((element) => element.excerciseInfo!
        .where((element) => element.excercise.bodyPart == title)
        .isNotEmpty);
    if (index == -1) return;
    int millis = sessions[index].date;
    DateTime date = DateTime.now();
    int timePassed = ((date.millisecondsSinceEpoch - millis) / 1000).round();

    setState(() {
      int hoursPassed = (timePassed / 3600).round();
      if (hoursPassed < 24) {
        lastWorkout = '${hoursPassed}h ago';
        return;
      }
      int daysPassed = (hoursPassed / 24).round();
      if (daysPassed < 7) {
        lastWorkout = '${daysPassed}d ago';
        return;
      }
      int weeksPassed = (daysPassed / 7).round();
      if (weeksPassed < 4) {
        lastWorkout = '${weeksPassed}w ago';
        return;
      }
    });
  }

  Color getBackgroundColor() {
    if (value == true) {
      return const Color.fromRGBO(52, 143, 250, 1);
    }
    return Colors.white;
  }

  Color getCheckboxColor() {
    if (value == false) {
      return const Color.fromRGBO(52, 143, 250, 1);
    }
    return Colors.white;
  }

  Color getTextColor() {
    if (value == true) {
      return Colors.white;
    }
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          widget.onTap(title);
          setState(() {
            value = !value;
          });
        },
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: 80,
            // margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            decoration: BoxDecoration(
              color: getBackgroundColor(),
              // border: Border.all(color: getTextColor(), width: 0.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Checkbox(
                      checkColor: Colors.blue,
                      fillColor: MaterialStateProperty.resolveWith(
                          (states) => getCheckboxColor()),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      value: value,
                      onChanged: (bool? newValue) {
                        setState(() {
                          value = newValue!;
                        });
                      },
                    ),
                    Text(title,
                        style: TextStyle(
                            fontSize: 20,
                            color: getTextColor(),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                Container(
                  height: 80,
                  alignment: Alignment.bottomRight,
                  child: Text(lastWorkout,
                      style: TextStyle(
                          color: getTextColor(), fontWeight: FontWeight.w400)),
                )
              ],
            )));
  }
}
