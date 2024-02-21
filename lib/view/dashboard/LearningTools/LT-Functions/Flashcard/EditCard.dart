// EditCardScreen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/res/fonts.dart';

class EditCardScreen extends StatefulWidget {
  final String categoryName;
  final String cardId;
  final String initialQuestion;
  final String initialAnswer;

  EditCardScreen({
    required this.categoryName,
    required this.cardId,
    required this.initialQuestion,
    required this.initialAnswer,
  });

  @override
  _EditCardScreenState createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    questionController.text = widget.initialQuestion;
    answerController.text = widget.initialAnswer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Card"),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
      ),
      backgroundColor: Color(0xFFe5f3fd),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: questionController,
              decoration: InputDecoration(labelText: 'Edit Question'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: answerController,
              decoration: InputDecoration(labelText: 'Edit Answer'),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  updateCard();
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
                    "Update Card",
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
          ],
        ),
      ),
    );
  }

  void updateCard() {
    String updatedQuestion = questionController.text.trim();
    String updatedAnswer = answerController.text.trim();

    if (updatedQuestion.isNotEmpty && updatedAnswer.isNotEmpty) {
      // Update the card in Firestore
      FirebaseFirestore.instance
          .collection('Flashcards')
          .doc(widget.categoryName)
          .collection('cards')
          .doc(widget.cardId)
          .update({
        'question': updatedQuestion,
        'answer': updatedAnswer,
      })
          .then((_) {
        print('Card updated in Firestore');
        Navigator.pop(context); // Close the EditCardScreen after updating
      })
          .catchError((error) {
        print('Error updating card in Firestore: $error');
      });
    }
  }
}
