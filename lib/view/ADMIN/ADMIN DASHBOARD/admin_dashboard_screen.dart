import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:tech_media/res/color.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/view/dashboard/chat/chat.dart';
import 'package:tech_media/view_model/services/session_manager.dart';
import 'package:tech_media/view/ADMIN/ADMIN DASHBOARD/admin_home/admin_home.dart';
import 'package:tech_media/view/ADMIN/ADMIN DASHBOARD/admin_tasks/admin_tasks.dart';
import 'package:tech_media/view/ADMIN/ADMIN DASHBOARD/admin_tools/admin_tools.dart';
import 'package:tech_media/view/ADMIN/ADMIN DASHBOARD/admin_vantageAI/admin_vantage.dart';

import 'admin_chat/admin_user/AdminUserLIst.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);


  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {


  final controller = PersistentTabController(initialIndex: 0);
  List <Widget>_buildScreen(){

    return [
      AdminHomeScreen(),
      // AdminTaskScreen(),
      // AdminLearningToolsScreen(),
      AdminUserListScreen(),
      AdminVantage(),
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

      // PersistentBottomNavBarItem(
      //   icon: Icon(CupertinoIcons.news),
      //   title: ("Tasks"),
      //   activeColorPrimary: CupertinoColors.systemPurple,
      //   inactiveColorPrimary: CupertinoColors.systemGrey,
      // ),

      // PersistentBottomNavBarItem(
      //   icon: Icon(CupertinoIcons.book),
      //   title: ("Tools"),
      //   activeColorPrimary: CupertinoColors.systemYellow,
      //   inactiveColorPrimary: CupertinoColors.systemGrey,
      // ),

      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.person_3),
        title: ("Users"),
        activeColorPrimary: CupertinoColors.systemPink,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),

      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.graph_square),
        title: ("Statistics"),
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
        borderRadius: BorderRadius.circular(15),
    ),
      navBarStyle: NavBarStyle.style3, //style 1,3,6



    );
  }
}
