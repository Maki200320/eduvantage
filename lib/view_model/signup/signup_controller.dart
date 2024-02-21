
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/utils/utils.dart';
import 'package:tech_media/view_model/services/session_manager.dart';

class SignUpController with ChangeNotifier{

  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('User');


  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value){
    _loading = value;
    notifyListeners();
  }

  Future<UserModel?> createUserModelFromDatabase(String uid) async {
    try {
      DatabaseEvent event = await ref.child(uid).once();
      if (event.snapshot.exists) {
        Map<String, dynamic>? userMap = event.snapshot.value as Map<String, dynamic>?;
        if (userMap != null) {
          return UserModel.fromMap(userMap);
        }
      }
      return null; // Return null if the user doesn't exist in the database
    } catch (error) {
      Utils.toastMessage(error.toString());
      return null;
    }
  }

  void signup(BuildContext context, String username, String email, String password, /*String selectedRole*/)async{

    setLoading(true);

    try {

     auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      ).then((value){
       SessionController().userId = value.user!.uid.toString();

        ref.child(value.user!.uid.toString()).set({
          'uid': value.user!.uid.toString(),
          'email': value.user!.email.toString(),
          'onlineStatus': 'true',
          'phone': '',
          'userName': username,
          'profile': '',
          // 'role' : selectedRole,

        }).then((value){

          setLoading(false);
          Navigator.pushReplacementNamed(context, RouteName.loginView);

          //Navigator.pushReplacementNamed(context, RouteName.dashboardScreen);
          // setLoading(false);
          // if (selectedRole == 'student') {
          //   Navigator.pushNamed(context, RouteName.loginView);
          //
          //   else if (selectedRole == 'educator') {
          //    Navigator.pushNamed(context, RouteName.adminDashboardScreen);
          // }

        }).onError((error, stackTrace){
          setLoading(false);
          Utils.toastMessage(error.toString());
        });

     }).onError((error, stackTrace){
       setLoading(false);
       Utils.toastMessage(error.toString());

     });

    }catch(e){
      setLoading(false);
      Utils.toastMessage(e.toString());
    }

  }

}

class UserModel {
  final String uid;
  final String email;
  final String onlineStatus;
  final String phone;
  final String userName;
  final String profile;

  UserModel({
    required this.uid,
    required this.email,
    required this.onlineStatus,
    required this.phone,
    required this.userName,
    required this.profile,
  });

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      onlineStatus: map['onlineStatus'],
      phone: map['phone'],
      userName: map['userName'],
      profile: map['profile'],
    );
  }
}
