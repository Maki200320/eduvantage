import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'tasks/tasks.dart';

class EditTask extends StatefulWidget {
  final String taskId; // Task ID to edit, pass null for creating a new task

  EditTask({required this.taskId});

  @override
  _EditTaskState createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
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

  final List<String> taskTypes = ['Assignment', 'Meeting', 'Review', 'Heads-Up', 'Other'];

  final auth = FirebaseAuth.instance;
  String userUID = "";

  @override
  void initState() {
    super.initState();
    fetchUserUID();
    if (widget.taskId != null) {
      fetchTaskDetails(widget.taskId);
    }
  }

  Future<void> fetchUserUID() async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      setState(() {
        userUID = currentUser.uid;
      });
    }
  }

  Future<void> fetchTaskDetails(String taskId) async {
    classCollection.doc(taskId).get().then((DocumentSnapshot doc) {
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          subjectName = data['subjectName'] ?? '';
          subjectCode = data['subjectCode'] ?? '';
          selectedDate = (data['date'] != null)
              ? (data['date'] as Timestamp).toDate()
              : DateTime.now();
          startTime = DateFormat('h:mm a').parse(data['startTime'] ?? '');
          endTime = DateFormat('h:mm a').parse(data['endTime'] ?? '');
          description = data['description'] ?? '';
          teacher = data['teacher'] ?? '';
          taskType = data['taskType'] ?? 'Other';
          selectedColor = data['backgroundColor'] != null
              ? Color(int.parse(data['backgroundColor'], radix: 16))
              : Colors.blue;
        });
      } else {
        print('Task with ID $taskId does not exist.');
      }
    }).catchError((error) {
      print('Error fetching task details: $error');
    });
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
        title: Text(widget.taskId.isEmpty ? "Add New Task" : "Edit Task",
            style: TextStyle(color: Colors.black87)),
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
                  initialValue: subjectName,
                  onChanged: (value) {
                    setState(() {
                      subjectName = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Subject Code'),
                  initialValue: subjectCode,
                  onChanged: (value) {
                    setState(() {
                      subjectCode = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Teacher'),
                  initialValue: teacher,
                  onChanged: (value) {
                    setState(() {
                      teacher = value;
                    });
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
                  initialValue: description,
                  onChanged: (value) {
                    setState(() {
                      description = value;
                    });
                  },
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Pick a color',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                              child: Text(
                                'Done',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: AppFonts.alatsiRegular,
                                    color: Colors.deepPurple),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text("Choose Panel Color",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.alatsiRegular,
                          color: Colors.deepPurple)),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() == true) {
                        if (widget.taskId.isEmpty) {
                          saveTaskData();
                        } else {
                          updateTaskData(widget.taskId);
                        }
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
                        widget.taskId.isEmpty ? "Create Task" : "Update Task",
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

  void saveTaskData() {
    classCollection.add({
      'subjectName': subjectName,
      'subjectCode': subjectCode,
      'date': selectedDate,
      'startTime': DateFormat('h:mm a').format(startTime),
      'endTime': DateFormat('h:mm a').format(endTime),
      'description': description,
      'teacher': teacher,
      'taskType': taskType,
      'backgroundColor': selectedColor.value.toRadixString(16),
      'userUID': userUID,
    }).then((_) {
      print('Task added to Firestore');
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
      );
      Navigator.pop(context, newTask);
    }).catchError((error) {
      print('Error adding task to Firestore: $error');
    });
  }

  void updateTaskData(String taskId) {
    classCollection.doc(taskId).update({
      'subjectName': subjectName,
      'subjectCode': subjectCode,
      'date': selectedDate,
      'startTime': DateFormat('h:mm a').format(startTime),
      'endTime': DateFormat('h:mm a').format(endTime),
      'description': description,
      'teacher': teacher,
      'taskType': taskType,
      'backgroundColor': selectedColor.value.toRadixString(16),
      'userUID': userUID,
    }).then((_) {
      print('Task updated in Firestore');
      Navigator.pop(context);
    }).catchError((error) {
      print('Error updating task in Firestore: $error');
    });
  }
}
