import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/Flashcard/AddCardScreem.dart';


class AddFlashcardCategory extends StatefulWidget {
  @override
  _AddFlashcardCategoryState createState() => _AddFlashcardCategoryState();
}

class _AddFlashcardCategoryState extends State<AddFlashcardCategory> {
  final CollectionReference flashcardCollection =
  FirebaseFirestore.instance.collection('Flashcards');
  final _formKey = GlobalKey<FormState>();

  String categoryName = '';
  String categoryDescription = '';
  Color selectedColor = Colors.blueAccent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Category", style: TextStyle(color: Colors.black87)),
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
                  decoration: InputDecoration(labelText: 'Category Name'),
                  onChanged: (value) {
                    setState(() {
                      categoryName = value;
                    });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration:
                  InputDecoration(labelText: 'Category Description'),
                  onChanged: (value) {
                    setState(() {
                      categoryDescription = value;
                    });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a category description';
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
                          title: Text('Pick a color',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: selectedColor,
                              onColorChanged: (color) {
                                setState(() {
                                  selectedColor = color;
                                });
                              },
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
                                    fontFamily: AppFonts.alatsiRegular),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text("Choose Panel Color",
                      style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.alatsiRegular)),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() == true) {
                        // Save category data
                        saveFlashcardData();

                        // Navigate to AddCardScreen with category data
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: AddCardScreen(categoryName: categoryName, selectedColor: selectedColor),
                          withNavBar: false,
                        );
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Text(
                        "Create Category",
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

  void saveFlashcardData() {
    // Use the category name as the document ID
    DocumentReference categoryRef = flashcardCollection.doc(categoryName);

    categoryRef.set({
      'categoryName': categoryName,
      'categoryDescription': categoryDescription,
      'backgroundColor': selectedColor.value.toRadixString(16),
    }).then((_) {
      print('Flashcard added to Firestore');
    }).catchError((error) {
      print('Error adding flashcard to Firestore: $error');
    });
  }

}
