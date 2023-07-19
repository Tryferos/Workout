import 'package:flutter/material.dart';

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
                  child: Text('1w ago',
                      style: TextStyle(
                          color: getTextColor(), fontWeight: FontWeight.w400)),
                )
              ],
            )));
  }
}
