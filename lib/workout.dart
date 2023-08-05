import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';

class BodyPartItem extends StatefulWidget {
  const BodyPartItem(
      {super.key,
      required this.title,
      required this.onTap,
      required this.index});
  final String title;
  final void Function(String) onTap;
  final int index;
  @override
  State<BodyPartItem> createState() => _BodyPartItemState();
}

class _BodyPartItemState extends State<BodyPartItem> {
  String get title => widget.title;
  String lastWorkout = '';

  bool isSelected() => widget.index != -1;

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
    if (isSelected() == true) {
      return const Color.fromRGBO(52, 143, 250, 1);
    }
    return Colors.white;
  }

  Color getCheckboxColor() {
    if (isSelected() == false) {
      return const Color.fromRGBO(52, 143, 250, 1);
    }
    return Colors.white;
  }

  Color getTextColor() {
    if (isSelected() == true) {
      return Colors.white;
    }
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          widget.onTap(title);
        },
        child: Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
            decoration: BoxDecoration(
              color: getBackgroundColor(),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: !isSelected()
                  ? Border.all(color: Colors.blue, width: 1.25)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 20,
                              color: getTextColor(),
                              fontWeight: FontWeight.w500)),
                      const SizedBox(
                        width: 8,
                      ),
                      Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: isSelected() ? Colors.white : Colors.blue,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4))),
                          height: 28,
                          width: 28,
                          child: isSelected()
                              ? Text(
                                  (widget.index + 1).toString(),
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Roboto'),
                                )
                              : const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                )),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.15,
                  alignment: Alignment.center,
                  child: Text(lastWorkout,
                      style: TextStyle(
                          color: getTextColor(), fontWeight: FontWeight.w400)),
                ),
              ],
            )));
  }
}
