import 'package:flutter/cupertino.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/Flashcard/FlashcardMM.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/Flashcard/FlashcardScreen.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/NotesScreen.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/RecorderScreen.dart';

import '../vantageAI/vantage.dart';

class LearningToolsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduVantage',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      debugShowCheckedModeBanner: false,
      home: LearningToolsPage(),
    );
  }
}

class LearningToolsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Learning Tools',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: AppFonts.alatsiRegular, // Use the desired font
          ),
        ),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            LearningToolCard(
              toolName: 'Notes',
              iconWow: Icon(Icons.edit, size: 50, color: Colors.white,),
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: NotesScreen(),
                  withNavBar: false,
                );
              },
              backgroundColor: Colors.blue, // Change the card color
              textColor: Colors.white, // Change the text color
            ),
            LearningToolCard(
              toolName: 'Recorder',
              iconWow: Icon(Icons.keyboard_voice_rounded, size: 50, color: Colors.white,),
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: RecorderScreen(),
                  withNavBar: false,
                );
              },
              backgroundColor: Colors.red,
              textColor: Colors.white,
            ),
            LearningToolCard(
              toolName: 'Flashcards',
              iconWow: Icon(Icons.flash_on_rounded, size: 50, color: Colors.white),
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: FlashcardMainMenu(),
                  withNavBar: false,
                );
              },
              backgroundColor: Colors.orange, // Change the card color
              textColor: Colors.white, // Change the text color
            ),
            LearningToolCard(
              toolName: 'Vantage Statistics', // New card
              iconWow: Icon(Icons.area_chart_rounded, size: 50, color: Colors.white,), // Replace 'chat' with the actual icon for Vantage AI
              onPressed: () {
                navigateToVantage(context, showBackButton: true);
              },
              backgroundColor: Colors.green, // Change the card color
              textColor: Colors.white, // Change the text color
            ),
          ],
        ),
      ),
    );
  }
}

void navigateToVantage(BuildContext context, {required bool showBackButton}) {
  PersistentNavBarNavigator.pushNewScreen(
    context,
    screen: Vantage(),
    withNavBar: false,
  );
}

class LearningToolCard extends StatelessWidget {
  final String toolName;
  final Icon iconWow;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  LearningToolCard({
    required this.toolName,
    required this.iconWow,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Decreased border radius for a more modern look
      ),
      color: backgroundColor, // Use the specified background color
      elevation: 1, // Increased elevation for a more modern card appearance
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              iconWow,
              SizedBox(height: 16.0),
              Text(
                toolName,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.alatsiRegular, // Use your desired font
                  color: textColor, // Set the text color
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(LearningToolsScreen());
}
