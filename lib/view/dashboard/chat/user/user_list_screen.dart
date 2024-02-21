import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/view/dashboard/profile/profile.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/color.dart';
import 'package:tech_media/view/dashboard/chat/message_screen.dart';
import 'package:tech_media/view_model/services/session_manager.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tech_media/view/dashboard/chat/messages_screen.dart';

import '../../profile/ProfileScreen2.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  DatabaseReference ref = FirebaseDatabase.instance.reference().child('User');
  String filter = ""; // Search filter string

  // Function to handle the pull-to-refresh action
  Future<void> _refreshData() async {
    // Add your data fetching logic here, if needed
    // For example, you can update the data from the Firebase database

    // Delay for a few seconds to simulate data fetching
    await Future.delayed(Duration(seconds: 2));

    // Call setState to rebuild the widget after data is fetched
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          centerTitle: false,
          title: Text(
            'Contacts',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: AppFonts.alatsiRegular,
            ),
          ),
          backgroundColor: Color(0xFFe5f3fd),
          elevation: 0,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25), // Adjust the radius as needed
                  border: Border.all(color: Colors.grey), // Add a border for the rounded effect
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0), // Add some horizontal padding to the TextField
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(CupertinoIcons.search),
                      border: InputBorder.none, // Remove the border from the TextField
                      hintStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w100, fontSize: 18),
                    ),
                    style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w300),
                    onChanged: (value) {
                      setState(() {
                        filter = value;
                      });
                    },
                  ),
                ),
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData, // Callback when the user pulls to refresh
                child: FirebaseAnimatedList(
                  query: ref.orderByChild('userName'), // Sort by username
                  itemBuilder: (context, snapshot, animation, index) {
                    if (SessionController().userId.toString() == snapshot.key) {
                      return Container(); // Exclude the current user
                    }
                    final userName = snapshot.child('userName').value?.toString() ?? "";
                    final email = snapshot.child('email').value?.toString() ?? "";
                    final image = snapshot.child('profile').value?.toString() ?? "";
                    final receiverId = snapshot.key ?? "";

                    // Check if the user's name contains the filter text
                    if (userName.toLowerCase().contains(filter.toLowerCase())) {
                      return _buildUserTile(
                        name: userName,
                        image: image,
                        email: email,
                        receiverId: receiverId,
                      );
                    } else {
                      return Container(); // Hide if not matching the filter
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTile({
    required String name,
    required String image,
    required String email,
    required String receiverId,
  }) {
    return Card(
      elevation: 0, //for box
      color: Color(0xFFe5f3fd),
      child: ListTile(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: MessagesScreen(
              name: name,
              image: image,
              email: email,
              receiverId: receiverId,
            ),
            withNavBar: false,
          );
        },
        leading: GestureDetector(
          onTap: () {
            // Navigate to the user's profile screen
            _navigateToUserProfile(receiverId);
          },
          child: Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black87)],
              border: Border.all(color: Colors.pink),
            ),
            child: CachedNetworkImage(
              imageUrl: image, // The URL of the user's profile image
              placeholder: (context, url) => Icon(CupertinoIcons.person_alt, color: Colors.white),
              errorWidget: (context, url, error) => Icon(CupertinoIcons.person_alt, color: Colors.white),
              imageBuilder: (context, imageProvider) => ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image(
                  fit: BoxFit.cover,
                  image: imageProvider,
                ),
              ),
            ),
          ),
        ),
        title: Text(name),
        subtitle: Text(email),
      ),
    );
  }

  void _navigateToUserProfile(String userId) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: ProfileScreen2(userId: userId),
      withNavBar: false, // Set this to true to include the persistent navigation bar
    );
  }

}

