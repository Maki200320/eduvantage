import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateNotesScreen extends StatefulWidget {
  @override
  _CreateNotesScreenState createState() => _CreateNotesScreenState();
}

class _CreateNotesScreenState extends State<CreateNotesScreen> {
  final CollectionReference classCollection = FirebaseFirestore.instance.collection('Notes');
  final _formKey = GlobalKey<FormState>();

  String title = '';
  String note = '';
  Color selectedColor = Colors.blue;

  // Declare FirebaseAuth instance and userUID
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

  void changeColor(Color color) {
    setState(() => selectedColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("Add Note", style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold)),
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
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: TextStyle(fontSize: 24, color: Colors.black54),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: 24, color: Colors.black),
                    onChanged: (value) {
                      setState(() {
                        title = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Note',
                      hintStyle: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.normal),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.normal),
                    onChanged: (value) {
                      setState(() {
                        note = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 480),
                Row(
                  children: <Widget>[
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
                                  child: Text('Done', style: TextStyle(fontSize: 16, fontFamily: AppFonts.alatsiRegular)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text("Choose Panel Color", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: AppFonts.alatsiRegular, color: Colors.blue)),
                    ),
                    Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        if (_formKey.currentState?.validate() == true) {
                          saveClassData();
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: Icon(
                        Icons.save_as_rounded,
                        color: Color(0xFFe5f3fd),
                      ),
                      label: Text(
                        "",
                        style: TextStyle(
                          fontFamily: AppFonts.alatsiRegular,
                          fontSize: 1,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void saveClassData() {
    classCollection.add({
      'title': title,
      'note': note,
      'backgroundColor': selectedColor.value.toRadixString(16),
      'userUID': userUID,
    }).then((_) {
      print('Class added to Firestore');
      Navigator.pop(context);
    }).catchError((error) {
      print('Error adding class to Firestore: $error');
    });
  }
}
