import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/view/ADMIN/ADMIN%20DASHBOARD/admin_chat/admin_user/UserDetails.dart';
import 'package:tech_media/view/dashboard/profile/ProfileScreen2.dart';
import 'package:tech_media/view/dashboard/profile/profile.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/color.dart';
import 'package:tech_media/view/dashboard/chat/message_screen.dart';
import 'package:tech_media/view_model/services/session_manager.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tech_media/view/dashboard/chat/messages_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({Key? key}) : super(key: key);

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
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

  String calculateEngagementStatus(DataSnapshot snapshot) {
    // Implement your logic to calculate engagement status based on user activities
    // You can retrieve user activities from the snapshot and analyze them
    // For example, count the number of read and write operations within a timeframe

    // Dummy implementation: Assuming engagement status based on the last activity timestamp
    final lastActivityTimestamp = snapshot.child('lastActivityTimestamp').value as int?;
    if (lastActivityTimestamp != null) {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final timeDifference = currentTime - lastActivityTimestamp;

      // Customize the threshold values as needed
      if (timeDifference <= Duration(days: 7).inMilliseconds) {
        return 'Active';
      } else if (timeDifference <= Duration(days: 30).inMilliseconds) {
        return 'Moderate';
      } else {
        return 'Inactive';
      }
    } else {
      return 'Inactive'; // Assuming inactive if no activity timestamp is available
    }
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
            'User Management',
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
                      // Calculate engagement status based on user activities
                      String engagementStatus = calculateEngagementStatus(snapshot); // Implement this method

                      return _buildUserTile(
                        name: userName,
                        image: image,
                        email: email,
                        receiverId: receiverId,
                        engagementStatus: engagementStatus,
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
    required String engagementStatus,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: GestureDetector(
        onTap: () {
          // Navigate to the user's profile screen
          _navigateToUserProfile(receiverId);
        },
        child: Card(
          elevation: 1,
          color: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // User Image
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black87)],
                    border: Border.all(color: Colors.deepOrange),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: image,
                    placeholder: (context, url) => Icon(CupertinoIcons.person, color: Colors.white, size: 26,),
                    errorWidget: (context, url, error) => Icon(CupertinoIcons.person, color: Colors.white, size: 26,),
                    imageBuilder: (context, imageProvider) => ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image(
                        fit: BoxFit.cover,
                        image: imageProvider,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 3),
                      Text(
                        email,
                        style: TextStyle(fontSize: 13, color: Colors.white54),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Engagement: $engagementStatus',
                        style: TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                // Delete Button
                IconButton(
                  onPressed: () {
                    // Implement the delete functionality here
                    _deleteUser(receiverId);
                  },
                  icon: Icon(Icons.delete, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  void _deleteUser(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this user?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Perform deletion when the user confirms
                Navigator.of(context).pop(); // Close the dialog
                _performDeleteUser(userId);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _performDeleteUser(String userId) {
    DatabaseReference userRef = FirebaseDatabase.instance.reference().child('User').child(userId);
    userRef.remove().then((_) {
      // User successfully deleted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User deleted successfully'),
          behavior: SnackBarBehavior.floating, // Set the behavior to floating
          margin: EdgeInsets.only(bottom: 17), // Adjust the margin to position it higher
        ),
      );
    }).catchError((error) {
      // Error occurred while deleting the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User deleted successfully'),
          behavior: SnackBarBehavior.floating, // Set the behavior to floating
          margin: EdgeInsets.only(bottom: 17), // Adjust the margin to position it higher
        ),
      );
    });
  }



  void _navigateToUserProfile(String userId) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: AdminUserDetails(userId: userId),
      withNavBar: false, // Set this to true to include the persistent navigation bar
    );
  }

}
