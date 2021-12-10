import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/screens/login_screen.dart';
import 'package:dk_brothers/screens/rep_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dk_brothers/screens/cheque_diary.dart';
import 'package:dk_brothers/screens/sales_rep_screen.dart';
import 'package:dk_brothers/screens/shop_screen.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'analysis_screen.dart';
import 'dashboard_screen.dart';

var _firestore = FirebaseFirestore.instance;

class BottomNavBar extends StatefulWidget {
  static String id = 'bottom_nav';

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  String? status;
  String? repID;
  final _auth = FirebaseAuth.instance;

  Future<String?> getRole() async {
    // ignore: await_only_futures
    User? loggedUserChoose = await FirebaseAuth.instance.currentUser;
    String? userRole;

    // ignore: unused_local_variable
    if (loggedUserChoose != null) {
      final currentUser =
          await _firestore.collection('users').doc(loggedUserChoose.uid).get();
      userRole = currentUser['role'];
      status = currentUser['status'];
      repID = loggedUserChoose.uid;
    }
    return userRole;
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    PersistentTabController _controller;
    _controller = PersistentTabController(initialIndex: 0);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Container(
      child: FutureBuilder(
        future: getRole(),
        builder: (context, snapshot) {
          if (snapshot.data == 'admin') {
            return roleTypes(
              context,
              _controller,
              mediaData,
              _buildScreensAdmin,
              _navBarsItemsAdmin,
            );
          } else if (snapshot.data == 'rep') {
            if (status == 'enable') {
              return roleTypes(
                context,
                _controller,
                mediaData,
                _buildScreensReps,
                _navBarsItemsReps,
              );
            } else {
              _auth.signOut();
              return AlertDialog(
                title: new Text("Alert!!"),
                content:
                    new Text("You are no longer authorized to use this app."),
                actions: <Widget>[
                  new TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, LoginScreen.id);
                    },
                  ),
                ],
              );
            }
          } else {
            return ModalProgressHUD(
              inAsyncCall: true,
              child: Container(
                height: mediaData.size.height,
                width: mediaData.size.width,
                color: Colors.white,
              ),
            );
          }
        },
      ),
    );
  }

  PersistentTabView roleTypes(
      BuildContext context,
      PersistentTabController _controller,
      MediaQueryData mediaData,
      List<Widget> Function() buildScreens,
      List<PersistentBottomNavBarItem> Function(MediaQueryData mediaData)
          navBarsItems) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: buildScreens(),
      items: navBarsItems(mediaData),
      confineInSafeArea: false,
      navBarHeight: mediaData.size.height * 0.1,
      backgroundColor: Colors.white, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardShows:
          true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
        boxShadow: boxShadows(),
      ),
      popAllScreensOnTapOfSelectedTab: false,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: ItemAnimationProperties(
        // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: ScreenTransitionAnimation(
        // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle:
          NavBarStyle.style9, // Choose the nav bar style with this property.
    );
  }

  List<Widget> _buildScreensAdmin() {
    return [
      Dashboard(),
      Shops(),
      SalesRep(),
      ChequeDiary(),
      Analysis(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItemsAdmin(
      MediaQueryData mediaData) {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.dashboard),
        title: ("Menu"),
        activeColorPrimary: Colors.black54,
        inactiveColorPrimary: Color(0xFF5B9FDE),
        textStyle: TextStyle(
          fontSize: mediaData.size.height * 0.02,
          fontFamily: 'Exo2',
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.store),
        title: ("Shops"),
        activeColorPrimary: Colors.black54,
        inactiveColorPrimary: Color(0xFF5B9FDE),
        textStyle: TextStyle(
          fontSize: mediaData.size.height * 0.02,
          fontFamily: 'Exo2',
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person),
        title: ("Reps"),
        activeColorPrimary: Colors.black54,
        inactiveColorPrimary: Color(0xFF5B9FDE),
        textStyle: TextStyle(
          fontSize: mediaData.size.height * 0.02,
          fontFamily: 'Exo2',
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.calendar_today),
        title: ("Cheques"),
        activeColorPrimary: Colors.black54,
        inactiveColorPrimary: Color(0xFF5B9FDE),
        textStyle: TextStyle(
          fontSize: mediaData.size.height * 0.02,
          fontFamily: 'Exo2',
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.bar_chart),
        title: ("Analysis"),
        activeColorPrimary: Colors.black54,
        inactiveColorPrimary: Color(0xFF5B9FDE),
        textStyle: TextStyle(
          fontSize: mediaData.size.height * 0.02,
          fontFamily: 'Exo2',
        ),
      ),
    ];
  }

  List<Widget> _buildScreensReps() {
    return [
      Dashboard(),
      Shops(),
      ChequeDiary(),
      RepProfile(repID),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItemsReps(MediaQueryData mediaData) {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.dashboard),
        title: ("Menu"),
        activeColorPrimary: Colors.black54,
        inactiveColorPrimary: Color(0xFF5B9FDE),
        textStyle: TextStyle(
          fontSize: mediaData.size.height * 0.02,
          fontFamily: 'Exo2',
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.store),
        title: ("Shops"),
        activeColorPrimary: Colors.black54,
        inactiveColorPrimary: Color(0xFF5B9FDE),
        textStyle: TextStyle(
          fontSize: mediaData.size.height * 0.02,
          fontFamily: 'Exo2',
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.calendar_today),
        title: ("Cheques"),
        activeColorPrimary: Colors.black54,
        inactiveColorPrimary: Color(0xFF5B9FDE),
        textStyle: TextStyle(
          fontSize: mediaData.size.height * 0.02,
          fontFamily: 'Exo2',
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person),
        title: ("Profile"),
        activeColorPrimary: Colors.black54,
        inactiveColorPrimary: Color(0xFF5B9FDE),
        textStyle: TextStyle(
          fontSize: mediaData.size.height * 0.02,
          fontFamily: 'Exo2',
        ),
      ),
    ];
  }
}
