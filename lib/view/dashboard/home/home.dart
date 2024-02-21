import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/view/dashboard/create_class.dart';
import 'package:tech_media/view/dashboard/edit_class.dart';
import 'package:tech_media/view/dashboard/profile/profile.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/view/dashboard/tasks/tasks.dart';
import '../../../Firebase_notif_API/Notif_service.dart';
import '../../../res/color.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../edit_task.dart';

class HomeScreen extends StatefulWidget {
  final String userUID; // Add a parameter to pass userUID

  HomeScreen({required this.userUID, Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState(userUID: userUID);
}

class _HomeScreenState extends State<HomeScreen> {

  final String userUID;

  _HomeScreenState({required this.userUID});

  final ref = FirebaseDatabase.instance.ref('User');
  final CollectionReference classCollection = FirebaseFirestore.instance.collection('Class');
  final CollectionReference taskCollection = FirebaseFirestore.instance.collection('Tasks');
  final auth = FirebaseAuth.instance;



  Future<void> _refreshData() async {
    // Add your data fetching logic here, if needed
    // For example, you can update the data from the Firebase database

    // Delay for a few seconds to simulate data fetching
    await Future.delayed(Duration(seconds: 2));

    // Call setState to rebuild the widget after data is fetched
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar:
      PreferredSize(child: getAppBar(), preferredSize: Size.fromHeight(60)),
      body: RefreshIndicator(
        onRefresh: _refreshData, // Specify the refresh function
        child: getBody(),
      ),
    );
  }

  Widget getAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Color(0xFFe5f3fd),
      title: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "EduVantage",
              style: TextStyle(
                fontSize: 28,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),

            IconButton(
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: ProfileScreen(),
                  withNavBar: false,
                );
              },
              icon: Icon(
                CupertinoIcons.person_alt_circle_fill,
                color: Colors.black87.withOpacity(0.9),
                size: 35,
              ),
            ),

            // GestureDetector(
            //   onTap: () {
            //     // Handle the tap, e.g., open the user's profile
            //     Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
            //       builder: (builder) => ProfileScreen(),
            //     ));
            //   },
            //   child: CircleAvatar(
            //     radius: 20, // Adjust the size as needed
            //     backgroundImage: NetworkImage(userUID),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget getBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... Other widgets
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(right: 17),
                child: IconButton(
                  icon: Icon(Icons.notifications, color: Colors.black, size: 24,),
                  onPressed: () {
                    NotificationService().showNotification(
                      title: 'Hey there!',
                      body: 'Your class will start soon',
                    );
                  },
                ),
              ),
            ),


            // Class Schedule Panel
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      "Class Schedule",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  // Use a StreamBuilder to listen to your Firestore data
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: classCollection
                          .where('userUID', isEqualTo: userUID)
                          .orderBy('startTime')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator(); // Loading indicator
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'No classes available',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 18, // Adjust the font size as needed
                                      fontWeight: FontWeight.normal, // Add any other desired style
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Adjust the width as needed
                                height: 50, // Adjust the height as needed
                                child: buildAddClassButton(), // Render "Add Class" button
                              ),
                            ],
                          );
                        }
                        // Display your class schedule items here based on the data in snapshot
                        final classScheduleItems = snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final documentId = doc.id; // Retrieve the document ID
                          final backgroundColor = Color(int.parse(data['backgroundColor'], radix: 16)); // Parse the color from the Firestore document
                          return buildClassScheduleItem(
                            documentId: documentId, // Pass the document I
                            subject: data['subjectName'],
                            subjectCode: data['subjectCode'],
                            startTime: data['startTime'], // Retrieve the start time
                            endTime: data['endTime'],
                            room: data['room'],
                            teacher: data['teacher'],
                            backgroundColor: backgroundColor, // Use the retrieved color
                          );
                        }).toList();

                        // Add the "Add Class" button to the end of the class schedule items
                        classScheduleItems.add(buildAddClassButton());

                        return Container(
                          height: 150, // Adjust the height as needed
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: classScheduleItems,
                          ),
                        );
                      },
                    ),
                  ),

                  // Pinned Tasks Panel
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            "Pinned Tasks",
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // Create a StreamBuilder to listen to pinned tasks
                        StreamBuilder<QuerySnapshot>(
                          stream: taskCollection
                              .where('userUID', isEqualTo: userUID)
                              .where('pinned', isEqualTo: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text(
                                  'No pinned tasks available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              );
                            }

                            // Display your pinned task items here
                            final pinnedTasks = snapshot.data!.docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              print('Data: $data'); // Log the data
                              final taskId = doc.id; // Retrieve the document ID
                              final type = data['taskType'];
                              final date = data['date'].toDate();
                              final startTime = TimeOfDay.fromDateTime(DateFormat('h:mm a').parse(data['startTime']));
                              final endTime = TimeOfDay.fromDateTime(DateFormat('h:mm a').parse(data['endTime']));
                              final subject = data['subjectName'];
                              final subjectCode = data['subjectCode'];
                              final teacher = data['teacher'];
                              final description = data['description'];
                              final backgroundColor = Color(int.parse(data['backgroundColor'], radix: 16));
                              final pinned = data['pinned'];

                              return buildTaskItem(
                                taskId: taskId,
                                type: type,
                                date: date,
                                startTime: startTime,
                                endTime: endTime,
                                subject: subject,
                                subjectCode: subjectCode,
                                teacher: teacher,
                                description: description,
                                backgroundColor: backgroundColor,
                                pinned: pinned,

                              );
                            }).toList();

                            return Column(
                              children: pinnedTasks,
                            );
                          },
                        ),

                      ],
                    ),
                  ),
          ],
        ),
      ),
  ])));
  }

  // Function to build a class schedule item
  Widget buildClassScheduleItem({
    required String documentId,
    required String subject,
    required String subjectCode,
    required Timestamp startTime,
    required Timestamp endTime,
    required String room,
    required String teacher,
    required Color backgroundColor,
  }) {

    // Convert Timestamps to DateTime
    final startTimeDt = startTime.toDate();
    final endTimeDt = endTime.toDate();

    return Container(
      width: 250,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown, // Ensure text scales down to fit
                  child: Text(
                    subject,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown, // Ensure text scales down to fit
                      child: Text(
                        subjectCode,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_filled,
                      color: Colors.white,
                      size: 10,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Start: ${DateFormat('h:mm a').format(startTimeDt)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 10,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'End: ${DateFormat('h:mm a').format(endTimeDt)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 1,
            right: 1,
            child: PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: EditClassScreen(docId: documentId, userUID: userUID),
                    withNavBar: false,
                  );
                } else if (value == 'delete') {
                  deleteClass(documentId);
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ];
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 170,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown, // Ensure text scales down to fit
                  child: Text(
                    room,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown, // Ensure text scales down to fit
                  child: Text(
                    teacher,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget buildAddClassButton() {
    return GestureDetector(
      onTap: () {
        // Navigate to the "Create New Class" screen and hide the bottom navigation bar
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: CreateNewClassScreen(),
          withNavBar: false,
        );
      },
      child: Container(
        width: 150,
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.bgColor, // Change to the color you want
        ),
        child: Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 48,
          ),
        ),
      ),
    );
  }


  void deleteClass(String documentId) {
    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Class'),
        content: Text('Are you sure you want to delete this class?', style: TextStyle(fontWeight: FontWeight.w300),),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // Dismiss the dialog
              Navigator.of(context).pop();
            },
            child: Text('Cancel', style: TextStyle(fontSize: 15, fontFamily: AppFonts.alatsiRegular),),
          ),
          TextButton(
            onPressed: () {
              // Delete the class document
              classCollection.doc(documentId).delete();
              // Dismiss the dialog
              Navigator.of(context).pop();
            },
            child: Text('Delete', style: TextStyle(fontSize: 15, fontFamily: AppFonts.alatsiRegular, color: Colors.red),),
          ),
        ],
      ),
    );
  }

  Widget buildTaskItem({
    required String taskId,
    required String type,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String subject,
    required String subjectCode,
    required String teacher,
    required String description,
    required Color backgroundColor,
    required bool pinned,
  }) {
    return Container(
      width: 350,
      margin: EdgeInsets.all(9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type ?? 'No Type', // Add null check for 'type'
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.5
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '${subject ?? 'No Subject'}', // Add null check for 'subject'
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      height: 1
                  ),
                ),
                Text(
                  '${subjectCode ?? 'No Code'}', // Add null check for 'subjectCode'
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.1
                  ),
                ),
                Text(
                  '${teacher ?? 'No Teacher'}', // Add null check for 'teacher'
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.date_range, // Calendar icon
                      size: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    SizedBox(width: 5),
                    Text(
                      DateFormat('MMM dd, yyyy').format(date ?? DateTime.now()), // Add null check for 'date'
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time, // Calendar icon
                      size: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    SizedBox(width: 5),
                    Text(
                      '${startTime?.format(context) ?? 'N/A'} - ${endTime?.format(context) ?? 'N/A'}', // Add null checks for 'startTime' and 'endTime'
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  description ?? 'No Description', // Add null check for 'description'
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 1,
            right: 1,
            child: PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onSelected: (value) {
                // if (value == 'edit') {
                //   // Implement the edit action
                //   // You can use a similar approach to the class schedule edit action
                // } else
                  if (value == 'unpin') {
                  // Implement the unpin action
                  unpinTask(taskId);
                }
              },
              itemBuilder: (context) {
                return [
                  // PopupMenuItem(
                  //   value: 'edit',
                  //   child: Text('Edit'),
                  // ),
                  PopupMenuItem(
                    value: 'unpin',
                    child: Text('Unpin'),
                  ),
                ];
              },
            ),
          ),
        ],
      ),
    );
  }


  void unpinTask(String taskId) {
    // Update the 'pinned' status of the task to 'false' in Firestore
    taskCollection.doc(taskId).update({'pinned': false})
        .then((value) {
      // Task has been successfully unpinned
      // You can handle this as needed, such as showing a confirmation message
    })
        .catchError((error) {
      // Handle errors, e.g., show an error message
      print("Error unpinning task: $error");
    });
  }

  // void handleEditTask(Task task) {
  //   PersistentNavBarNavigator.pushNewScreen(
  //     context,
  //     screen: EditTask(taskId: task.documentID,),
  //     withNavBar: false,
  //   );
  // }


}
