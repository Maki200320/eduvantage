import 'package:tech_media/res/fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminTaskScreen extends StatefulWidget {
  @override
  _AdminTaskScreenState createState() => _AdminTaskScreenState();
}

class _AdminTaskScreenState extends State<AdminTaskScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Task> _tasks = []; // List of tasks

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Tasks'),
        titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: AppFonts.alatsiRegular),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            color: Colors.deepPurpleAccent,
            iconSize: 28,
            alignment: Alignment.centerLeft,
            onPressed: () {
              // Implement adding a task action here
              _showAddTaskDialog();
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
    // Group tasks by date
    final Map<DateTime, List<Task>> taskGroups = {};
    _tasks.forEach((task) {
      final dateKey = DateTime(task.date.year, task.date.month, task.date.day);
      taskGroups[dateKey] ??= [];
      taskGroups[dateKey]!.add(task);
    });

    return ListView.builder(
      itemCount: taskGroups.length,
      itemBuilder: (context, index) {
        final dateKey = taskGroups.keys.elementAt(index);
        final tasks = taskGroups[dateKey];
        return _buildTaskPanel(dateKey, tasks);
      },
    );
  }

  Widget _buildTaskPanel(DateTime date, List<Task>? tasks) {
    // Define the background color for the task panel.
    Color panelBackgroundColor = Colors.deepPurple.withOpacity(0.85); // Change this color to your desired color

    // Define the text color for the task title and subtitle.
    Color titleTextColor = Colors.white; // Change this color to your desired text color
    Color subtitleTextColor = Colors.white70; // Change this color to your desired text color

    // Define the border radius for the panel.
    double borderRadius = 12.0; // Change this value to control the roundness of the corners

    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: panelBackgroundColor, // Set the background color here
        borderRadius: BorderRadius.circular(borderRadius), // Set the border radius here
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Tasks for ${DateFormat('MMM dd, yyyy').format(date)}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: titleTextColor), // Set the title text color
            ),
          ),
          if (tasks != null)
            ...tasks.map((task) => ListTile(
              title: Text(
                task.title,
                style: TextStyle(color: titleTextColor), // Set the task title text color
              ),
              subtitle: Text(
                'Task Date: ${DateFormat('MMM dd, yyyy').format(task.date)}', // Display task date as a subtitle
                style: TextStyle(fontSize: 12.0, color: subtitleTextColor), // Set the subtitle text color
              ),
              // You can add more task details here as needed
            )),
        ],
      ),
    );
  }


  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String taskTitle = '';

        return AlertDialog(
          title: Text('Add Task'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                taskTitle = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Task Title',
              labelStyle: TextStyle(color: Colors.green),
            ),
            style: TextStyle(color: Colors.green),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (taskTitle.isNotEmpty) {
                  final newTask = Task(
                    title: taskTitle,
                    date: _selectedDay ?? DateTime.now(),
                  );
                  setState(() {
                    _tasks.add(newTask);
                  });
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // Change the button's background color to green
              ),
              child: Text('Add', style: TextStyle(color: Colors.white)), // Change the text color to white
            ),
          ],
        );
      },
    );
  }
}

class Task {
  final String title;
  final DateTime date;

  Task({
    required this.title,
    required this.date,
  });
}