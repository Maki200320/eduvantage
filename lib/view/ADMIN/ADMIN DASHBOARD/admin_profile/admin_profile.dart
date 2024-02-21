import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_media/res/color.dart';
import 'package:tech_media/res/components/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_media/view/login/login_screen.dart';
import 'package:tech_media/view_model/profile/profile_controller.dart';
import 'package:tech_media/view_model/services/session_manager.dart';

import '../../../../res/fonts.dart';
import '../../../res/fonts.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final ref = FirebaseDatabase.instance.ref('User');
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.black87,
        ),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: AppFonts.alatsiRegular,
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFe5f3fd),
      body: ChangeNotifierProvider(
        create: (_) => ProfileController(),
        child: Consumer<ProfileController>(
          builder: (context, provider, child) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: StreamBuilder(
                    stream: ref.child(SessionController().userId.toString()).onValue,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data.snapshot.value == null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 300,),
                              Text('No data available'),
                              RoundButton(
                                title: 'Logout',
                                color: Colors.white70.withOpacity(0),
                                textColor: Colors.red,
                                onPress: () async {
                                  // Show confirmation dialog for logout
                                  await _confirmLogout(context);
                                },
                              ),
                            ],
                          ),
                        );
                      } else {
                        Map<dynamic, dynamic> map = snapshot.data.snapshot.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20,),
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Center(
                                    child: Container(
                                      height: 150,
                                      width: 150,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(color:Colors.black12)
                                          ],
                                          border: Border.all(
                                            color: Colors.transparent,
                                          )
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(100),
                                        child: provider.image == null
                                            ? map['profile'].toString()  == ""
                                            ? const Icon(
                                          Icons.person_rounded,
                                          size: 70,
                                          color: AppColors.whiteColor,
                                        )
                                            : Image(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                            map['profile'].toString(),
                                          ),
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(child: CircularProgressIndicator());
                                          },
                                          errorBuilder: (context, object, stack) {
                                            return Container(
                                              child: Icon(
                                                Icons.error_outline,
                                                color: AppColors.alertColor,
                                              ),
                                            );
                                          },
                                        )
                                            : Stack(
                                          children: [
                                            Image.file(
                                              File(provider.image!.path).absolute,
                                            ),
                                            Center(child: CircularProgressIndicator())
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    provider.pickImage(context);
                                  },
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black87.withOpacity(0.8),
                                    child: Icon(CupertinoIcons.camera_fill, size: 14, color: Colors.white.withOpacity(0.9),),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 5,),
                            Text(
                              map['userName'],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 20,),
                            const SizedBox(height: 20,),
                            GestureDetector(
                              onTap: () {
                                provider.showUserNameDialogAlert(context, map['userName']);
                              },
                              child: ReusableRow(title: 'Username',
                                value: map['userName'],
                                iconData: CupertinoIcons.person_alt,
                                iconColor: CupertinoColors.activeBlue,

                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                provider.showPhoneDialogAlert(context, map['phone']);
                              },
                              child: ReusableRow(title: 'Phone',
                                value: map['phone'] == '' ? 'xxx-xxx-xxx' : map['phone'],
                                iconData: CupertinoIcons.phone_fill,
                                iconColor: CupertinoColors.destructiveRed,
                              ),
                            ),
                            ReusableRow(title: 'Email',
                              value: map['email'],
                              iconData: CupertinoIcons.mail_solid,
                              iconColor: CupertinoColors.activeGreen,
                            ),
                            // ReusableRow(
                            //   title: 'Role', // Display the user's role
                            //   value: userRole,
                            //   iconData: CupertinoIcons.person_2_alt,
                            //   iconColor: Colors.blue.withOpacity(0.9),
                            // ),
                            const SizedBox(height: 170,),
                            RoundButton(
                              title: 'Logout',
                              color: Colors.white70.withOpacity(0.2),
                              textColor: Colors.red,
                              onPress: () async {
                                // Show confirmation dialog for logout
                                await _confirmLogout(context);
                              },
                            )
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
          ),
          title: Text('Confirm Logout', style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontSize: 18, fontWeight: FontWeight.w800),),
          content: Text('Are you sure you want to logout?', style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontSize: 16, fontWeight: FontWeight.w100),),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // Close the dialog
                Navigator.of(context).pop();

                // Sign out the user
                await auth.signOut();

                // Navigate to LoginScreen and remove all routes below it
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },
              child: Text('Logout', style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontSize: 16, color: Colors.red),),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog without logging out
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(fontFamily: AppFonts.alatsiRegular, fontSize: 16, color: Colors.black87),),
            ),
          ],
        );
      },
    );
  }
}

class ReusableRow extends StatelessWidget {
  final String title, value;
  final IconData iconData;
  final Color iconColor;
  const ReusableRow({Key? key,
    required this.title,
    required this.iconData,
    required this.value,
    required this.iconColor,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200, color: Colors.black87.withOpacity(0.5))),
          leading: Icon(iconData, color: iconColor),
          trailing: Text(value,style: Theme.of(context).textTheme.headline3, ),
        ),
        Divider(color: AppColors.whiteColor.withOpacity(0))
      ],
    );
  }
}
