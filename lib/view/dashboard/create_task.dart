import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'tasks/tasks.dart';

class CreateTask extends StatefulWidget {
  final String userUID;

  CreateTask({required this.userUID});

  @override
  _CreateTaskState createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  final CollectionReference classCollection = FirebaseFirestore.instance.collection('Tasks');
  final _formKey = GlobalKey<FormState>();

  String subjectName = '';
  String subjectCode = '';
  DateTime selectedDate = DateTime.now();
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  String description = '';
  String teacher = '';
  String taskType = 'Other'; // Set an initial value for taskType
  Color selectedColor = Colors.blue;
  bool pinned = false; // Add a variable to track the pinned status

  final List<String> taskTypes = ['Assignment', 'Meeting', 'Review', 'Heads-Up', 'Other'];

  final auth = FirebaseAuth.instance;
  String userUID = "";

  @override
  void initState() {
    super.initState();
    fetchUserUID();
  }

  Future<void> fetchUserUID() async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      setState(() {
        userUID = currentUser.uid;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Task", style: TextStyle(color: Colors.black87)),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87), // Change the color here
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
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Task Type'),
                  items: taskTypes.map((String taskType) {
                    return DropdownMenuItem<String>(
                      value: taskType,
                      child: Text(taskType),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      taskType = value ?? '';
                    });
                  },
                  value: taskType,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Subject Name'),
                  onChanged: (value) {
                    setState(() {
                      subjectName = value;
                    });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a subject name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Subject Code'),
                  onChanged: (value) {
                    setState(() {
                      subjectCode = value;
                    });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a subject code';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Teacher'),
                  onChanged: (value) {
                    setState(() {
                      teacher = value;
                    });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a teacher';
                    }
                    return null;
                  },
                ),
                GestureDetector(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Date'),
                    child: Text(
                      DateFormat('MMM dd, yyyy').format(selectedDate),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
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
                  decoration: InputDecoration(labelText: 'Task Description'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                  onChanged: (value) {
                    setState(() {
                      description = value;
                    });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter description';
                    }
                    return null;
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
                              child: Text('Done', style: TextStyle(fontSize: 16, fontFamily: AppFonts.alatsiRegular, color: Colors.deepPurple),),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text("Choose Panel Color", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: AppFonts.alatsiRegular, color: Colors.deepPurple)),
                ),
                CheckboxListTile(
                  title: Text("Pinned", style: TextStyle(fontWeight: FontWeight.normal),),
                  checkboxShape: CircleBorder(),
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                  value: pinned,
                  onChanged: (value) {
                    setState(() {
                      pinned = value ?? false;
                    });
                  },
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() == true) {
                        saveClassData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.black87.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        "Create Task",
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

  void saveClassData() {
    classCollection.add({
      'subjectName': subjectName,
      'subjectCode': subjectCode,
      'date': selectedDate, // Save selected date as DateTime
      'startTime': DateFormat('h:mm a').format(startTime), // Save selected start time as a string
      'endTime': DateFormat('h:mm a').format(endTime), // Save selected end time as a string
      'description': description,
      'teacher': teacher,
      'taskType': taskType, // Include the task type when saving class data
      'backgroundColor': selectedColor.value.toRadixString(16),
      'userUID': userUID,
      'pinned': pinned, // Include the pinned status when saving task data
    }).then((_) {
      print('Class added to Firestore');
      final newTask = Task(
        documentID: '',
        date: selectedDate,
        startTime: TimeOfDay.fromDateTime(startTime),
        endTime: TimeOfDay.fromDateTime(endTime),
        subject: subjectName,
        subjectCode: subjectCode,
        teacher: teacher,
        description: description,
        color: selectedColor,
        type: taskType,
        pinned: pinned, // Include the pinned status in the new task
      );
      Navigator.pop(context, newTask);
    }).catchError((error) {
      print('Error adding class to Firestore: $error');
    });
  }
}
