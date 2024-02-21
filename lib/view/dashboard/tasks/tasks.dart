import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_media/view/dashboard/create_task.dart';
import 'package:tech_media/view/dashboard/edit_task.dart';

import '../../../res/fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskScreen extends StatefulWidget {
  final String userUID;

  TaskScreen({required this.userUID});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Task> _tasks = []; // List of tasks

  void togglePinTask(Task task) {
    setState(() {
      task.pinned = !task.pinned; // Toggle the pinned status
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTaskData();
  }

  Future<void> togglePinTaskInFirestore(String taskId, bool pinned) async {
    try {
      await FirebaseFirestore.instance.collection('Tasks').doc(taskId).update({
        'pinned': pinned,
      });
    } catch (e) {
      print("Error updating pinned status in Firestore: $e");
    }
  }

  Future<void> deleteTaskFromFirestore(String taskId) async {
    try {
      await FirebaseFirestore.instance.collection('Tasks').doc(taskId).delete();
    } catch (e) {
      print("Error deleting task from Firestore: $e");
    }
  }

  // Function to load task data from Firestore
  Future<void> _loadTaskData() async {
    try {
      final taskSnapshot = await FirebaseFirestore.instance.collection('Tasks')
          .where('userUID', isEqualTo: widget.userUID) // Filter by userUID
          .get();

      final taskList = taskSnapshot.docs.map((document) {
        final data = document.data() as Map<String, dynamic>;
        return Task(
          documentID: document.id, // Added documentID
          date: data['date'].toDate(),
          startTime: TimeOfDay.fromDateTime(DateFormat('h:mm a').parse(data['startTime'])),
          endTime: TimeOfDay.fromDateTime(DateFormat('h:mm a').parse(data['endTime'])),
          subject: data['subjectName'],
          subjectCode: data['subjectCode'],
          teacher: data['teacher'],
          description: data['description'],
          color: Color(int.parse(data['backgroundColor'], radix: 16)),
          type: data['taskType'],
          pinned: data['pinned'] ?? false, // Fetch the pinned status from Firestore
        );
      }).toList();

      setState(() {
        _tasks = taskList;
      });
    } catch (e) {
      print("Error loading task data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: AppBar(
        title: Text('Tasks', style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: AppFonts.alatsiRegular,
        ),),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFFe5f3fd),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.deepPurple),
            onPressed: () {
              // Navigate to the task creation screen without the navigation bar
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: CreateTask(userUID: widget.userUID),
                withNavBar: false,
              ).then((newTask) {
                if (newTask != null) {
                  setState(() {
                    _tasks.add(newTask);
                  });
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return _tasks
                  .where((task) =>
              task.date.year == day.year &&
                  task.date.month == day.month &&
                  task.date.day == day.day)
                  .map((task) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple,
                ),
              ))
                  .toList();
            },
          ),
          SizedBox(height: 16.0), // Add spacing between calendar and task panels
          Expanded(
            child: _buildTaskPanels(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskPanels() {
    // Filter tasks that match the selected date
    final filteredTasks = _tasks.where((task) =>
    task.date.year == _selectedDay?.year &&
        task.date.month == _selectedDay?.month &&
        task.date.day == _selectedDay?.day).toList();

    return RefreshIndicator(
      onRefresh: _loadTaskData, // Refresh when dragged down
      child: ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return _buildTaskPanel(task);
        },
      ),
    );
  }

  Widget _buildTaskPanel(Task task) {
    // Define the background color for the task panel.
    Color panelBackgroundColor = task.color;

    // Define the text color for the task title and subtitle.
    Color titleTextColor = Colors.white; // Change this color to your desired text color

    String timeRange = '${task.startTime.format(context)} - ${task.endTime.format(context)}';

    // Check if the task is pinned and change the panel appearance accordingly
    bool isPinned = task.pinned;

    void handlePinTask(Task task) {
      togglePinTaskInFirestore(task.documentID, !task.pinned);
      togglePinTask(task);
    }

    void handleEditTask(Task task) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: EditTask(taskId: task.documentID,),
        withNavBar: false,
      );
    }

    void handleDeleteTask(Task task) {
      // Implement the logic to delete the task
      deleteTaskFromFirestore(task.documentID); // Delete the task from Firestore
      setState(() {
        _tasks.remove(task); // Remove the task from the local list
      });
    }

    void _showDeleteConfirmationDialog(Task task) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Task'),
            content: Text('Are you sure you want to delete this task?', style: TextStyle(fontWeight: FontWeight.normal),),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel', style: TextStyle(fontFamily: AppFonts.alatsiRegular, color: Colors.green, fontSize: 16)),
              ),
              TextButton(
                onPressed: () {
                  handleDeleteTask(task);
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Delete', style: TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular, fontSize: 16)),
              ),
            ],
          );
        },
      );
    }

    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: panelBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: task.pinned
            ? Border.all(color: Colors.black87, width: 2)
            : null,
      ),
      child: Stack(
        children: [
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${task.type}',
                  style: TextStyle(color: titleTextColor, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${task.subject}',
                  style: TextStyle(color: titleTextColor, fontWeight: FontWeight.w100, fontSize: 18, height: 1.5),
                ),
                Text(
                  '${task.subjectCode}',
                  style: TextStyle(color: titleTextColor, fontWeight: FontWeight.w100, fontSize: 17, height: 1),
                ),
                Text(
                  '${task.teacher}',
                  style: TextStyle(color: titleTextColor, fontWeight: FontWeight.w100, fontSize: 16, height: 1),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.date_range, // Calendar icon
                      size: 15,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    SizedBox(width: 5),
                    Text(
                      '${DateFormat('MMM dd, yyyy').format(task.date)}',
                      style: TextStyle(fontSize: 13, color: titleTextColor, fontWeight: FontWeight.w100, height: 1),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time, // Clock icon
                      size: 15,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    SizedBox(width: 5),
                    Text(
                      '$timeRange', // Display the concatenated time range
                      style: TextStyle(fontSize: 13, color: titleTextColor, fontWeight: FontWeight.w100, height: 1),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '${task.description}',
                  style: TextStyle(color: titleTextColor, fontWeight: FontWeight.w100, fontSize: 18, height: 1),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: PopupMenuButton<String>(
              onSelected: (choice) {
                if (choice == 'Pin') {
                  handlePinTask(task);
                } else if (choice == 'Unpin') {
                  handlePinTask(task);
                } else if (choice == 'Edit') {
                  handleEditTask(task);
                } else if (choice == 'Delete') {
                  _showDeleteConfirmationDialog(task);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  task.pinned ? 'Unpin' : 'Pin', // Display "Unpin" if pinned, "Pin" if not pinned
                  'Edit',
                  'Delete'
                ].map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
              icon: Icon(Icons.more_vert, color: Colors.white), // Icon for the kebab menu
            ),
          ),
        ],
      ),
    );
  }
}

class Task {
  final String documentID; // Added documentID
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String subject;
  final String subjectCode;
  final String teacher;
  final String description;
  final Color color;
  final String type;
  bool pinned; // New field to track if the task is pinned

  Task({
  required this.documentID, // Added documentID
  required this.date,
  required this.startTime,
  required this.endTime,
  required this.subject,
  required this.subjectCode,
  required this.teacher,
  required this.description,
  required this.color,
  required this.type,
    this.pinned = false, // Default is unpinned
});
}

