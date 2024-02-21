import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:tech_media/res/color.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/view/dashboard/chat/chat.dart';
import 'package:tech_media/view/dashboard/chat/user/user_list_screen.dart';
import 'package:tech_media/view/dashboard/profile/profile.dart';
import 'package:tech_media/view/dashboard/chat/user/user_list_screen.dart';
import 'package:tech_media/view/dashboard/tools/tools.dart';
import 'package:tech_media/view/dashboard/vantageAI/vantage.dart';
import 'package:tech_media/view/dashboard/tasks/tasks.dart';
import 'package:tech_media/view_model/services/session_manager.dart';

import 'home/home.dart';
import 'notifications/notifications.dart';

class DashboardScreen extends StatefulWidget {
  final String userUID; // Add the userUID parameter

  DashboardScreen({required this.userUID, Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {


  final controller = PersistentTabController(initialIndex: 0);
  List <Widget>_buildScreen(){

    return [
      HomeScreen(userUID: widget.userUID), // Pass userUID to HomeScreen
      TaskScreen(userUID: widget.userUID,),
      LearningToolsScreen(),
      UserListScreen(),
      Vantage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItem(){
    return[
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.home, size: 24),
        title: ("Home"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),

      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.calendar_today),
        title: ("Tasks"),
        activeColorPrimary: CupertinoColors.systemPurple,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),

      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.book),
        title: ("Tools"),
        activeColorPrimary: CupertinoColors.activeOrange,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),

      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.chat_bubble_2),
        title: ("Contacts"),
        activeColorPrimary: CupertinoColors.destructiveRed,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),

      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.chart_bar),
        title: ("V Stats"),
        activeColorPrimary: CupertinoColors.activeGreen,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return PersistentTabView(
        context,
        screens: _buildScreen(),
          items: _navBarItem(),
      controller: controller,
      backgroundColor: Color(0xFFe5f3fd),
      decoration: NavBarDecoration(
        colorBehindNavBar: Color(0xFFe5f3fd),
        borderRadius: BorderRadius.circular(2),
    ),
      navBarStyle: NavBarStyle.style3, //style 1,3,6



    );
  }
}
