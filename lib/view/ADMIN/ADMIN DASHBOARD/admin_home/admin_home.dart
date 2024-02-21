import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/res/color.dart';

import '../../../login/login_screen.dart';
import '../admin_profile/admin_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_media/utils/routes/route_name.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final ref = FirebaseDatabase.instance.ref('User');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar:
      PreferredSize(child: getAppBar(), preferredSize: Size.fromHeight(60)),
      body: getBody(),
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
              "EduVantage | ADMIN",
              style: TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.alatsiRegular),
            ),

            IconButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                    builder: (builder) => AdminProfileScreen(),
                  ),);
                },
                icon: Icon(
                  CupertinoIcons.person_alt_circle_fill,
                  color: Colors.black87.withOpacity(0.9) ,
                  size: 35,
                )),

            // IconButton(
            //     onPressed: () {
            //       _auth.signOut().then((value) {
            //         Navigator.of(context, rootNavigator: true)
            //             .pushAndRemoveUntil(
            //           MaterialPageRoute(
            //             builder: (BuildContext context) {
            //               return const LoginScreen();
            //             },
            //           ),
            //               (_) => false,
            //         );
            //       }).catchError((error) {
            //         print("Failed to log out: $error");
            //       });
            //     },
            //     icon: Icon(
            //       Icons.logout,
            //       color: Colors.red.withOpacity(0.9),
            //       size: 30,
            //     )
            // )

          ],
        ),
      ),
    );
  }

  Widget getBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 18, right: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            // ... Other widgets

            // Class Schedule Panel
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(
                    height: 20,
                  ),

                ],
              ),
            ),

            // Upcoming Task Panel


          ],
        ),
      ),
    );
  }
}
