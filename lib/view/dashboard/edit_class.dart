import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:tech_media/res/fonts.dart';

class EditClassScreen extends StatefulWidget {
  final String docId;
  final String userUID;

  EditClassScreen({required this.docId, required this.userUID});

  @override
  _EditClassScreenState createState() => _EditClassScreenState();
}

class _EditClassScreenState extends State<EditClassScreen> {
  final CollectionReference classCollection = FirebaseFirestore.instance.collection('Class');
  final _formKey = GlobalKey<FormState>();

  String subjectName = '';
  String subjectCode = '';
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  String room = '';
  String teacher = '';
  Color selectedColor = Colors.blue;

  TextEditingController subjectNameController = TextEditingController();
  TextEditingController subjectCodeController = TextEditingController();
  TextEditingController roomController = TextEditingController();
  TextEditingController teacherController = TextEditingController();

  void changeColor(Color color) {
    setState(() => selectedColor = color);
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(startTime),
    );

    if (pickedTime != null) {
      setState(() {
        startTime = DateTime(
          startTime.year,
          startTime.month,
          startTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(endTime),
    );

    if (pickedTime != null) {
      setState(() {
        endTime = DateTime(
          endTime.year,
          endTime.month,
          endTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchClassDetails(widget.docId);
  }

  void fetchClassDetails(String docId) {
    classCollection.doc(docId).get().then((DocumentSnapshot doc) {
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        setState(() {
          subjectName = data['subjectName'] ?? '';
          subjectCode = data['subjectCode'] ?? 'ITE';
          room = data['room'] ?? '';
          teacher = data['teacher'] ?? '';

          subjectNameController.text = subjectName;
          subjectCodeController.text = subjectCode;
          roomController.text = room;
          teacherController.text = teacher;

          startTime = data['startTime'] != null
              ? (data['startTime'] as Timestamp).toDate()
              : DateTime.now();
          endTime = data['endTime'] != null
              ? (data['endTime'] as Timestamp).toDate()
              : DateTime.now();

          selectedColor = data['backgroundColor'] != null
              ? Color(int.parse(data['backgroundColor'], radix: 16))
              : Colors.blue;
        });
      } else {
        print('Class document with docId $docId does not exist.');
      }
    }).catchError((error) {
      print('Error fetching class details: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Class", style: TextStyle(color: Colors.black87)),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Color(0xFFe5f3fd),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: subjectNameController,
                  decoration: InputDecoration(labelText: 'Subject Name'),
                  onChanged: (value) {
                    setState(() {
                      subjectName = value;
                    });
                  },
                ),
                TextFormField(
                  controller: subjectCodeController,
                  decoration: InputDecoration(labelText: 'Subject Code'),
                  onChanged: (value) {
                    setState(() {
                      subjectCode = value;
                    });
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _selectStartTime(context);
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(labelText: 'Start Time'),
                          child: Text(
                            DateFormat('h:mm a').format(startTime),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _selectEndTime(context);
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(labelText: 'End Time'),
                          child: Text(
                            DateFormat('h:mm a').format(endTime),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: roomController,
                  decoration: InputDecoration(labelText: 'Room'),
                  onChanged: (value) {
                    setState(() {
                      room = value;
                    });
                  },
                ),
                TextFormField(
                  controller: teacherController,
                  decoration: InputDecoration(labelText: 'Teacher'),
                  onChanged: (value) {
                    setState(() {
                      teacher = value;
                    });
                  },
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Pick a color', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: selectedColor,
                              onColorChanged: changeColor,
                              showLabel: true,
                              pickerAreaHeightPercent: 0.8,
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Done', style: TextStyle(fontSize: 16, fontFamily: AppFonts.alatsiRegular, color: Colors.blue)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text("Choose Panel Color", style: TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.bold, fontFamily: AppFonts.alatsiRegular)),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                        updateClassData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: Colors.black87.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        "Update Class",
                        style: TextStyle(
                          fontFamily: AppFonts.alatsiRegular,
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateClassData() {
    classCollection.doc(widget.docId).update({
      'subjectName': subjectName,
      'subjectCode': subjectCode,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'room': room,
      'teacher': teacher,
      'backgroundColor': selectedColor.value.toRadixString(16),
      'userUID': widget.userUID,
    }).then((_) {
      print('Class updated in Firestore');
      Navigator.pop(context);
    }).catchError((error) {
      print('Error updating class in Firestore: $error');
    });
  }
}
