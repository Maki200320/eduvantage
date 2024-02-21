import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/Flashcard/AddCardScreem.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/Flashcard/AddFlashcardCategory.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/Flashcard/EditCategory.dart';
import '../../../../../res/fonts.dart';
import 'EditAddCard.dart';
import 'FlashcardPlayScreen.dart';

void main() {
  runApp(MyApp());
}

void navigateToFlashcardPlayScreen(
    BuildContext context, {
      required String categoryName,
      required String categoryDescription,
    }) {
  PersistentNavBarNavigator.pushNewScreen(
    context,
    screen: FlashcardPlayScreen(
      categoryName: categoryName,
      categoryDescription: categoryDescription,
    ),
    withNavBar: false,
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: FlashcardMainMenu(),
    );
  }
}

class FlashcardMainMenu extends StatefulWidget {
  @override
  _FlashcardMainMenuState createState() => _FlashcardMainMenuState();
}

class _FlashcardMainMenuState extends State<FlashcardMainMenu> {
  List<FlashcardCard> flashcardWidgets = [];

  Future<void> _refreshData() async {
    // Implement your refresh logic here
    // For example, you can refetch data from Firestore
    await Future.delayed(Duration(seconds: 2)); // Simulating a delay, replace this with your actual data fetching logic
  }

  void deleteCard(BuildContext context, String categoryName) {
    // Implement the deletion logic
    FirebaseFirestore.instance
        .collection('Flashcards')
        .doc(categoryName)
        .delete()
        .then((_) {
      print('Card deleted from Firestore');
      // Remove the card from the UI
      setState(() {
        flashcardWidgets.removeWhere((card) => card.categoryName == categoryName);
      });
    }).catchError((error) {
      print('Error deleting card from Firestore: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Flashcards',
          style: TextStyle(
            fontFamily: AppFonts.alatsiRegular,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Color(0xFFe5f3fd),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('Flashcards').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              var flashcardDocs = snapshot.data?.docs ?? [];
              flashcardWidgets = [];

              for (var flashcard in flashcardDocs) {
                var flashcardData = flashcard.data() as Map<String, dynamic>;
                flashcardWidgets.add(
                  FlashcardCard(
                    categoryName: flashcardData['categoryName'],
                    categoryDescription: flashcardData['categoryDescription'],
                    backgroundColor: flashcardData['backgroundColor'],
                    onPressed: () {
                      navigateToFlashcardPlayScreen(
                        context,
                        categoryName: flashcardData['categoryName'],
                        categoryDescription: flashcardData['categoryDescription'],
                      );
                    },
                    onDelete: () {
                      deleteCard(context, flashcardData['categoryName']);
                    },
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: flashcardWidgets.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        flashcardWidgets[index],
                        SizedBox(height: 3), // Added more space between cards
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: AddFlashcardCategory(),
            withNavBar: false,
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.deepOrange,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class FlashcardCard extends StatelessWidget {
  final String categoryName;
  final String categoryDescription;
  final String backgroundColor;
  final VoidCallback onPressed;
  final VoidCallback onDelete;

  FlashcardCard({
    required this.categoryName,
    required this.categoryDescription,
    required this.backgroundColor,
    required this.onPressed,
    required this.onDelete,
  });

  void navigateToAddCardScreen(BuildContext context, {required String categoryName}) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: EditAddCardScreen(categoryName: categoryName, selectedColor: Colors.blue),
      withNavBar: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 150,
        width: 350,
        child: Card(
          color: Color(int.parse(backgroundColor, radix: 16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$categoryName',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Colors.white),
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              navigateToAddCardScreen(context, categoryName: categoryName);
                            },
                            child: Row(
                              children: [
                                Icon(Icons.add),
                                SizedBox(width: 8),
                                Text('Add'),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: EditFlashcardCategory(categoryName: categoryName),
                                withNavBar: false,
                              );
                            },
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirm Deletion'),
                                    content: Text('Are you sure you want to delete this card?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context); // Close the dialog
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          onDelete();
                                          Navigator.pop(context); // Close the dialog
                                        },
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Row(
                              children: [
                                Icon(Icons.delete),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  '$categoryDescription',
                  style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white.withOpacity(0.9), fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}