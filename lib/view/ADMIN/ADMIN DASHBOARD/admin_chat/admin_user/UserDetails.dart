import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tech_media/res/fonts.dart';

class AdminUserDetails extends StatelessWidget {
  final String userId;

  const AdminUserDetails({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DatabaseReference ref = FirebaseDatabase.instance.reference().child('User').child(userId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFe5f3fd),
        title: Text('Profile'),
      ),
      backgroundColor: Color(0xFFe5f3fd),
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: CachedNetworkImageProvider(map['profile'] ?? ''),
                  ),
                  SizedBox(height: 20),
                  Text(
                    map['userName'] ?? '',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.person_alt, color: CupertinoColors.activeBlue,),
                        SizedBox(width: 10),
                        Text('Username:', style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                    title: Text(map['userName'] ?? '',
                      style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold),),
                  ),
                  ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.phone_fill, color: CupertinoColors.destructiveRed,),
                        SizedBox(width: 10),
                        Text('Phone:', style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                    title: Text(map['phone'] ?? '',
                      style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold),),
                  ),
                  ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.mail_solid, color: CupertinoColors.activeGreen,),
                        SizedBox(width: 10),
                        Text('Email:', style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                    title: Text(map['email'] ?? '',
                      style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold),),
                  ),

                ],
              ),
            );
          } else {
            return Center(child: Text('Something went wrong'));
          }
        },
      ),
    );
  }
}
