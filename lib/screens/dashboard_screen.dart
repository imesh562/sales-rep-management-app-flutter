import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/screens/attendance.dart';
import 'package:dk_brothers/screens/items_screen.dart';
import 'package:dk_brothers/screens/order_screen.dart';
import 'package:dk_brothers/screens/payments.dart';
import 'package:dk_brothers/screens/scan_qr.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'login_screen.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

User? loggedInUser;

class Dashboard extends StatefulWidget {
  static String id = 'dashboard';
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late StreamSubscription subscription;
  bool showSpinnerDash = false;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  var userRoleDash;
  bool showSpinner = false;
  @override
  void initState() {
    super.initState();
    loggedInUser = FirebaseAuth.instance.currentUser;
    subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      checkConnection(hasInternet, context);
    });
    getUserRole();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  getUserRole() async {
    if (this.mounted)
      setState(() {
        showSpinner = true;
      });
    await _firestore
        .collection("users")
        .doc(loggedInUser!.uid)
        .get()
        .then((result) {
      var role = result.get('role');
      if (this.mounted)
        setState(() {
          userRoleDash = role;
          showSpinner = false;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: appBarComponenet(mediaData, 'Main Menu'),
        body: ModalProgressHUD(
          inAsyncCall: showSpinnerDash,
          child: Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: mediaData.size.width * 0.03,
                    bottom: mediaData.size.width * 0.025,
                    left: mediaData.size.width * 0.025,
                    right: mediaData.size.width * 0.025,
                  ),
                  child: Stack(
                    children: [
                      ClipPath(
                        clipper: ClipperCustom(),
                        child: Container(
                          width: mediaData.size.width * 0.95,
                          height: mediaData.size.height * 0.35,
                          decoration: topCardsBGDash(userRoleDash.toString() ==
                                  'admin'
                              ? 'assets/logos/nandana_v2_green_bliack_outline.png'
                              : 'assets/logos/nandana_v2_blue.png'),
                        ),
                      ),
                      ClipPath(
                        clipper: ClipperCustom2(),
                        child: GestureDetector(
                          onTap: () {
                            Alert(
                              context: context,
                              type: AlertType.warning,
                              title: "LOGOUT",
                              desc: "Are you sure you want to log out?",
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "Yes",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () {
                                    if (this.mounted)
                                      setState(() {
                                        showSpinnerDash = true;
                                      });
                                    _auth.signOut();
                                    pushNewScreenWithRouteSettings(
                                      context,
                                      settings: RouteSettings(
                                        name: LoginScreen.id,
                                      ),
                                      screen: LoginScreen(),
                                      withNavBar: false,
                                      pageTransitionAnimation:
                                          PageTransitionAnimation.cupertino,
                                    );
                                  },
                                  color: Colors.deepOrange,
                                ),
                                DialogButton(
                                  child: Text(
                                    "No",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  },
                                  color: Color(0xFF5B9FDE),
                                )
                              ],
                            ).show();
                          },
                          child: Container(
                            width: mediaData.size.width * 0.95,
                            height: mediaData.size.height * 0.35,
                            decoration: topCardsBGDash(userRoleDash
                                        .toString() ==
                                    'admin'
                                ? 'assets/logos/nandana_v2_green_bliack_outline.png'
                                : 'assets/logos/nandana_v2_blue.png'),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 20.0, bottom: 15),
                                child: Icon(
                                  Icons.logout_rounded,
                                  size: mediaData.size.width * 0.13,
                                  color: userRoleDash.toString() == 'admin'
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: mediaData.size.height * 0.01,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: mediaData.size.width * 0.025,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  pushNewScreenWithRouteSettings(
                                    context,
                                    settings: RouteSettings(
                                      name: OrderScreen.id,
                                    ),
                                    screen: OrderScreen(0, userRoleDash),
                                    withNavBar: true,
                                    pageTransitionAnimation:
                                        PageTransitionAnimation.cupertino,
                                  );
                                },
                                child: DashItem(
                                  mediaData,
                                  'Orders',
                                  'assets/images/orders.png',
                                  0.02,
                                  0.133,
                                  0.01,
                                  userRoleDash,
                                ),
                              ),
                              SizedBox(
                                width: mediaData.size.width * 0.05,
                              ),
                              GestureDetector(
                                onTap: () {
                                  pushNewScreenWithRouteSettings(
                                    context,
                                    settings: RouteSettings(
                                      name: ItemsList.id,
                                    ),
                                    screen: ItemsList(),
                                    withNavBar: true,
                                    pageTransitionAnimation:
                                        PageTransitionAnimation.cupertino,
                                  );
                                },
                                child: DashItem(
                                    mediaData,
                                    'Items',
                                    'assets/images/basket.png',
                                    0.005,
                                    0.1275,
                                    0.005,
                                    userRoleDash),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: mediaData.size.height * 0.02,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: mediaData.size.width * 0.025,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  pushNewScreenWithRouteSettings(
                                    context,
                                    settings: RouteSettings(
                                      name: Payments.id,
                                    ),
                                    screen: Payments(0, userRoleDash),
                                    withNavBar: true,
                                    pageTransitionAnimation:
                                        PageTransitionAnimation.cupertino,
                                  );
                                },
                                child: DashItem(
                                    mediaData,
                                    'Payments',
                                    'assets/images/payments.png',
                                    0.01,
                                    0.14,
                                    0.006,
                                    userRoleDash),
                              ),
                              SizedBox(
                                width: mediaData.size.width * 0.05,
                              ),
                              GestureDetector(
                                onTap: () {
                                  (userRoleDash.toString() == 'admin')
                                      ? pushNewScreenWithRouteSettings(
                                          context,
                                          settings: RouteSettings(
                                            name: Attendance.id,
                                          ),
                                          screen: Attendance(userRoleDash),
                                          withNavBar: true,
                                          pageTransitionAnimation:
                                              PageTransitionAnimation.cupertino,
                                        )
                                      : pushNewScreenWithRouteSettings(
                                          context,
                                          settings: RouteSettings(
                                            name: ScanQR.id,
                                          ),
                                          screen: ScanQR(userRoleDash),
                                          withNavBar: true,
                                          pageTransitionAnimation:
                                              PageTransitionAnimation.cupertino,
                                        );
                                },
                                child: DashItem(
                                    mediaData,
                                    (userRoleDash.toString() == 'admin')
                                        ? 'Attendance'
                                        : 'Scan QR',
                                    (userRoleDash.toString() == 'admin')
                                        ? 'assets/images/attendance.png'
                                        : 'assets/images/QR.png',
                                    0,
                                    (userRoleDash.toString() == 'admin')
                                        ? 0.128
                                        : 0.131,
                                    (userRoleDash.toString() == 'admin')
                                        ? 0.015
                                        : 0.01,
                                    userRoleDash),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class DashItem extends StatelessWidget {
  DashItem(
    this.mediaData,
    this.text,
    this.image,
    this.padd,
    this.scale,
    this.padd1,
    this.role,
  );
  MediaQueryData mediaData;
  var text;
  var image;
  var padd;
  var padd1;
  var scale;
  var role;
  final List<Color> adminColors = [Color(0xFF70aa8f), Color(0xFFd1e4db)];
  final List<Color> repColors = [Color(0xFF6dc2f8), Color(0xFFbbd0ff)];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: mediaData.size.height * 0.185,
      width: mediaData.size.width * 0.445,
      decoration: BoxDecoration(
        borderRadius: BorderRadiusDirectional.circular(25.0),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.bottomRight,
          colors: role == 'admin' ? adminColors : repColors,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset.zero,
            blurRadius: 5,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: mediaData.size.width * 0.032),
                child: Text(
                  text,
                  textAlign: TextAlign.start,
                  style: krepReg.copyWith(
                    color: role == 'admin' ? Colors.black : Colors.white,
                    fontSize: mediaData.size.height * 0.032,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  right: mediaData.size.width * padd,
                  bottom: mediaData.size.height * padd1,
                ),
                child: Image.asset(
                  image,
                  height: mediaData.size.height * scale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
