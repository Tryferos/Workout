import 'package:flutter/material.dart';
import 'package:flutter_application_1/excercise.dart';

class NotesWidget extends StatefulWidget {
  const NotesWidget({super.key, required this.name});

  final String name;

  @override
  State<NotesWidget> createState() => _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  String newNotes = '';
  String initialNotes = '';
  Future<String>? notes;
  @override
  void initState() {
    super.initState();
    readNotes();
  }

  void readNotes() async {
    notes = ExcerciseInfo.excerciseNotes(widget.name);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your notes for ${widget.name}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                initialNotes == newNotes
                    ? const Text('Saved',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600))
                    : IconButton(
                        icon: const Icon(Icons.check,
                            color: Colors.blue, size: 32),
                        onPressed: () async {
                          print(newNotes);
                          await ExcerciseInfo.updateNotes(
                              newNotes, widget.name);
                          setState(() {
                            initialNotes = newNotes;
                          });
                        },
                      ),
              ],
            )),
        FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return TextFormField(
                  onChanged: (value) => {
                    setState(() {
                      newNotes = value;
                    })
                  },
                  maxLines: 19,
                  minLines: 5,
                  initialValue: snapshot.data,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 0.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 0.0)),
                      border: null,
                      hintText: 'Enter your notes here',
                      alignLabelWithHint: true),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
            future: notes),
      ],
    );
  }
}
