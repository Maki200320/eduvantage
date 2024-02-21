import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/Flashcard/EditCard.dart';

import '../../../../../res/fonts.dart';

class EditAddCardScreen extends StatefulWidget {
  final String categoryName;
  final Color selectedColor;

  EditAddCardScreen({required this.categoryName, required this.selectedColor});

  @override
  _EditAddCardScreenState createState() => _EditAddCardScreenState();
}

class _EditAddCardScreenState extends State<EditAddCardScreen> {
  List<Map<String, String>> cards = [];
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Cards for ${widget.categoryName}",
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
          ),
        ],
      ),
      backgroundColor: Color(0xFFe5f3fd),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(labelText: 'Enter Question'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: answerController,
                  decoration: InputDecoration(labelText: 'Enter Answer'),
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      addCard();
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
                        "Add Card",
                        style: TextStyle(
                          fontFamily: AppFonts.alatsiRegular,
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10)
              ],
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Flashcards')
                    .doc(widget.categoryName)
                    .collection('cards')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
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

                  var cardDocs = snapshot.data?.docs ?? [];
                  cardDocs = cardDocs.reversed.toList(); // Reverse the order
                  List<Widget> cardWidgets = [];

                  for (var card in cardDocs) {
                    var cardData = card.data() as Map<String, dynamic>;

                    cardWidgets.add(
                      Card(
                        color: Colors.orange.shade800,
                        child: ListTile(
                          title: Text(
                            'Question: ${cardData['question']}',
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Answer: ${cardData['answer']}',
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.white),
                                onPressed: () {
                                  // Navigate to EditCardScreen with the card details
                                  PersistentNavBarNavigator.pushNewScreen(
                                    context,
                                    screen: EditCardScreen(
                                      categoryName: widget.categoryName,
                                      cardId: card.id,
                                      initialQuestion: cardData['question'],
                                      initialAnswer: cardData['answer'],
                                    ),
                                    withNavBar: true, // Set this to true to include the persistent navigation bar
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.white),
                                onPressed: () {
                                  // Handle delete functionality
                                  // You can show a confirmation dialog before deleting
                                  onDeleteCard(card.id); // Pass the card id for deletion
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView(
                    children: cardWidgets,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addCard() {
    String question = questionController.text.trim();
    String answer = answerController.text.trim();

    if (question.isNotEmpty && answer.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('Flashcards')
          .doc(widget.categoryName)
          .collection('cards')
          .add({
        'question': question,
        'answer': answer,
        'timestamp': FieldValue.serverTimestamp(),
      })
          .then((_) {
        print('Card added to Firestore');
        questionController.clear();
        answerController.clear();
      })
          .catchError((error) {
        print('Error adding card to Firestore: $error');
      });
    }
  }

  void saveCardsData() {
    // Navigate back to the previous screen
    Navigator.pop(context);
    // Navigate back to the previous previous screen
    Navigator.pop(context);
  }

  void onDeleteCard(String cardId) {
    FirebaseFirestore.instance
        .collection('Flashcards')
        .doc(widget.categoryName)
        .collection('cards')
        .doc(cardId)
        .delete()
        .then((_) {
      print('Card deleted from Firestore');
    })
        .catchError((error) {
      print('Error deleting card from Firestore: $error');
    });
  }
}
