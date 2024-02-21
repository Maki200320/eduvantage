import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/utils/utils.dart';
import '../services/session_manager.dart';

class LoginController with ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void login(BuildContext context, String email, String password) async {
    setLoading(true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user is an admin
      if (userCredential.user != null && isUserAdmin(userCredential.user!)) {
        // If user is admin, prevent login and navigate to admin screen
        setLoading(false);
        Utils.toastMessage('Admins should use the Admin Login screen.');
        Navigator.pushNamed(context, RouteName.adminLoginScreen);
      } else {
        // If user is not admin, proceed with regular login flow
        SessionController().userId = userCredential.user!.uid;
        setLoading(false);
        Navigator.pushReplacementNamed(context, RouteName.dashboardScreen);
      }
    } catch (e) {
      setLoading(false);
      Utils.toastMessage(e.toString());
    }
  }

  // Function to check if the user is an admin (you should implement your own logic here)
  bool isUserAdmin(User user) {
    // Example: check if the user's email matches the admin email
    return user.email == 'admin1@gmail.com';
  }
}
