import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/AddRecordScreen.dart';
import 'package:tech_media/view/dashboard/LearningTools/LT-Functions/EditNotes.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(RecorderScreen());
}

class RecorderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final user = snapshot.data;
          if (user != null) {
            return MaterialApp(
              title: 'EduVantage',
              theme: ThemeData(
                primarySwatch: Colors.amber,
              ),
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Recorder',
                    style: TextStyle(
                      fontFamily: AppFonts.alatsiRegular,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
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
                body: NotesList(), // Pass the user's UID
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: AddRecordScreen(),
                      withNavBar: false,
                    );
                  },
                  child: Icon(Icons.keyboard_voice_rounded, color: Colors.white),
                  backgroundColor: CupertinoColors.destructiveRed,
                ),
              ),
            );
          } else {
            return Center(child: Text('User not authenticated.'));
          }
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class NotesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dummy voice records data with different colors
    List<Map<String, dynamic>> dummyVoiceRecords = [
      {
        'title': 'Capstone 1',
        'duration': '2:30',
        'waveform': 'https://www.pngkey.com/png/detail/211-2113819_easy-waveform-generation-stencil.png',
        'color': Colors.blue, // Set the color for this panel
      },
      {
        'title': 'Game Development',
        'duration': '1:45',
        'waveform': 'https://www.pngkey.com/png/detail/211-2113819_easy-waveform-generation-stencil.png',
        'color': Colors.green, // Set the color for this panel
      },
      {
        'title': 'App Development',
        'duration': '5:45',
        'waveform': 'https://www.pngkey.com/png/detail/211-2113819_easy-waveform-generation-stencil.png',
        'color': Colors.pink, // Set the color for this panel
      },
      {
        'title': 'Web Development',
        'duration': '3:56',
        'waveform': 'https://www.pngkey.com/png/detail/211-2113819_easy-waveform-generation-stencil.png',
        'color': Colors.black, // Set the color for this panel
      },
    ];

    return RefreshIndicator(
      onRefresh: () async {
        // Add your logic to refresh the data here, e.g., fetch the latest voice records
      },
      child: ListView.builder(
        scrollDirection: Axis.vertical, // Horizontal scroll
        itemCount: dummyVoiceRecords.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: 200, // Set a fixed width for each horizontal panel
            margin: EdgeInsets.all(8), // Add some margin between panels
            child: AudioPanel(
              title: dummyVoiceRecords[index]['title'] ?? '',
              duration: dummyVoiceRecords[index]['duration'] ?? '',
              waveform: dummyVoiceRecords[index]['waveform'] ?? '',
              color: dummyVoiceRecords[index]['color'] ?? Colors.blue, // Use the color from the data
            ),
          );
        },
      ),
    );
  }
}



class NoteCard extends StatelessWidget {
  final QueryDocumentSnapshot note;

  NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final data = note.data() as Map<String, dynamic>;
    final title = data['title'] ?? '';
    final content = data['note'] ?? '';

    // Parse the color from Firebase data
    final colorHexString = data['backgroundColor'] ?? '';
    final color = Color(int.parse(colorHexString, radix: 16));

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Confirm Deletion", style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontWeight: FontWeight.w800),),
              content: Text("Are you sure you want to delete this note?", style: TextStyle(fontFamily: AppFonts.alatsiRegular),),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Cancel", style: TextStyle(color: Colors.green, fontFamily: AppFonts.alatsiRegular)),
                ),
                TextButton(
                  onPressed: () {
                    // Delete the note from Firestore and dismiss the dialog
                    FirebaseFirestore.instance.collection('Notes').doc(note.id).delete();
                    Navigator.of(context).pop(true);
                  },
                  child: Text("Delete", style: TextStyle(color: Colors.red, fontFamily: AppFonts.alatsiRegular)),
                ),
              ],
            );
          },
        );
      },
      background: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          color: Color(0xFFe5f3fd),
          child: Align(
            alignment: Alignment.center,
            child: Icon(CupertinoIcons.delete, color: Colors.red),
          ),
        ),
      ),
      child: Card(
        margin: EdgeInsets.all(8.0),
        color: color,
        elevation: 2,
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: AppFonts.alatsiRegular,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  content,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: AppFonts.alatsiRegular,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: EditNotesScreen(noteDocument: note,),
              withNavBar: false,
            );
          },
          contentPadding: EdgeInsets.all(16.0),
        ),
      ),
    );
  }
}

class AudioPanel extends StatelessWidget {
  final String title;
  final String duration;
  final String waveform;
  final Color color; // Added color property

  AudioPanel({
    required this.title,
    required this.duration,
    required this.waveform,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 2,
      color: color, // Set the background color for the panel
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.network(
            waveform,
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          ListTile(
            title: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.alatsiRegular,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Text color
              ),
            ),
            subtitle: Text(
              'Duration: $duration',
              style: TextStyle(
                fontFamily: AppFonts.alatsiRegular,
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.white, // Text color
              ),
            ),
          ),
        ],
      ),
    );
  }
}