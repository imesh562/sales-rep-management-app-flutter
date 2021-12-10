import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/screens/assign_items.dart';
import 'package:dk_brothers/screens/rep_profile.dart';
import 'package:dk_brothers/screens/rep_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:url_launcher/url_launcher.dart';

import 'edit_assigned.dart';

User? loggedInUser;
final _firestore = FirebaseFirestore.instance;

class SalesRep extends StatefulWidget {
  static String id = 'sales_Representatives';
  @override
  _SalesRepState createState() => _SalesRepState();
}

class _SalesRepState extends State<SalesRep> {
  bool showSpinnerDash = false;
  late StreamSubscription subscription;

  ScrollController controller = ScrollController();
  String searchText = "";
  bool closeTopContainers = false;
  int orderBy = 1;
  var orderByText = 'Name';
  late DateTime now;
  late DateTime today;

  @override
  void initState() {
    super.initState();
    loggedInUser = FirebaseAuth.instance.currentUser;
    subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      checkConnection(hasInternet, context);
    });
    controller.addListener(() {
      if (this.mounted)
        setState(() {
          closeTopContainers = controller.offset > 10;
        });
    });
    now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: appBarComponenet(mediaData, 'Sales Representatives'),
      body: ModalProgressHUD(
        inAsyncCall: showSpinnerDash,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: mediaData.size.width * 0.03,
                bottom: mediaData.size.width * 0.025,
                left: mediaData.size.width * 0.025,
                right: mediaData.size.width * 0.025,
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: closeTopContainers ? 0 : 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: mediaData.size.width,
                  alignment: Alignment.topCenter,
                  height: closeTopContainers ? 0 : mediaData.size.height * 0.35,
                  child: Stack(
                    children: [
                      ClipPath(
                        clipper: ClipperCustom(),
                        child: Container(
                          width: mediaData.size.width * 0.95,
                          height: mediaData.size.height * 0.35,
                          decoration: topCardsBG(
                            Color(0xFFDAECEC),
                            Color(0xFF79CCCA),
                          ),
                          child: Image.asset(
                            'assets/images/salesmen1.png',
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ),
                      ClipPath(
                        clipper: ClipperCustom2(),
                        child: GestureDetector(
                          onTap: () {
                            pushNewScreenWithRouteSettings(
                              context,
                              settings: RouteSettings(
                                name: RegisterRep.id,
                              ),
                              screen: RegisterRep(),
                              withNavBar: true,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          child: Container(
                            width: mediaData.size.width * 0.95,
                            height: mediaData.size.height * 0.35,
                            decoration: topCardsBG(
                              Color(0xFFDAECEC),
                              Color(0xFF79CCCA),
                            ),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 35.0, bottom: 15),
                                child: Hero(
                                  tag: 'addRep',
                                  child: Icon(
                                    Icons.person_add,
                                    size: mediaData.size.width * 0.1,
                                    color: Color(0xFF147a73),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.only(left: 14.0),
                    width: mediaData.size.width * 0.7,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Search',
                        labelStyle: loginCredentials,
                        prefixIcon: Icon(
                          FontAwesomeIcons.search,
                          color: Color(0xFF79CCCA),
                        ),
                        errorStyle: TextStyle(fontSize: 12, height: 0.3),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF79CCCA)),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF79CCCA)),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                      ),
                      onChanged: (value) {
                        if (this.mounted)
                          setState(() {
                            searchText = value;
                          });
                      },
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20.0),
                  child: DropdownButton(
                      value: orderBy,
                      autofocus: true,
                      items: [
                        DropdownMenuItem(
                          child: Text("Name"),
                          value: 1,
                        ),
                        DropdownMenuItem(
                          child: Text("Date"),
                          value: 2,
                        ),
                        DropdownMenuItem(
                          child: Text("Disabled"),
                          value: 3,
                        ),
                      ],
                      onChanged: (value) {
                        if (value == 1) {
                          if (this.mounted)
                            setState(() {
                              orderBy = 1;
                              orderByText = 'Name';
                            });
                        } else if (value == 2) {
                          if (this.mounted)
                            setState(() {
                              orderBy = 2;
                              orderByText = 'Date';
                            });
                        } else {
                          if (this.mounted)
                            setState(() {
                              orderBy = 3;
                              orderByText = 'Removed';
                            });
                        }
                      }),
                ),
              ],
            ),
            RepsStream(
              controller,
              searchText,
              orderByText,
              today.toString().substring(0, 10),
            ),
            SizedBox(
              height: mediaData.size.height * 0.015,
            ),
          ],
        ),
      ),
    );
  }
}

Stream<QuerySnapshot> searchData(String string, String orderByText) async* {
  var _search = _firestore
      .collection('users')
      .where('name', isGreaterThanOrEqualTo: string)
      .where('name', isLessThan: string + 'z')
      .orderBy('name', descending: true)
      .snapshots();
  yield* _search;
}

// ignore: must_be_immutable
class RepsStream extends StatelessWidget {
  var controller;
  String searchText;
  String orderByText;
  String today;
  RepsStream(this.controller, this.searchText, this.orderByText, this.today);

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return StreamBuilder<QuerySnapshot>(
      // ignore: unnecessary_null_comparison
      stream: (searchText != "")
          ? searchData(searchText, orderByText)
          : orderByText == 'Name'
              ? _firestore
                  .collection('users')
                  .orderBy('name', descending: true)
                  .snapshots()
              : orderByText == 'Date'
                  ? _firestore
                      .collection('users')
                      .orderBy('timestamp', descending: false)
                      .snapshots()
                  : _firestore
                      .collection('users')
                      .orderBy('status', descending: true)
                      .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final reps = snapshot.data!.docs.reversed;
        List<Widget> repList = [];
        for (var rep in reps) {
          final repEmail = rep['email'];
          final repMobile = rep['mobile_num'];
          final repname = rep['name'];
          final repRole = rep['role'];
          final repStatus = rep['status'];
          final imgURL = rep['img_url'];
          final lastAssign = rep['last_assign'];
          final repID = rep.reference.id;

          repList.add(repListBuilder(repname, repEmail, repMobile, mediaData,
              context, repStatus, repID, today, repRole, imgURL, lastAssign));
        }
        return Expanded(
          child: Container(
            child: ListView.builder(
              controller: controller,
              itemCount: repList.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Align(
                  heightFactor: 0.85,
                  alignment: Alignment.topCenter,
                  child: repList[index],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

Widget buildImage(MediaQueryData mediaData, imagePath) {
  if (imagePath.isNotEmpty && imagePath != 'null') {
    final image = NetworkImage(imagePath);
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image,
          fit: BoxFit.cover,
          width: mediaData.size.height * 0.14,
          height: mediaData.size.height * 0.14,
          colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.8), BlendMode.dstATop),
        ),
      ),
    );
  } else {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: AssetImage('assets/images/saleREP.png'),
          fit: BoxFit.cover,
          width: mediaData.size.height * 0.15,
          height: mediaData.size.height * 0.15,
          colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.4), BlendMode.dstATop),
        ),
      ),
    );
  }
}

Widget repListBuilder(
  String name,
  String eMail,
  String telNumber,
  MediaQueryData mediaData,
  BuildContext context,
  String repStatus,
  String repID,
  String today,
  String repRole,
  String imgURL,
  String lastAssign,
) {
  return FocusedMenuHolder(
    openWithTap: true,
    menuWidth: MediaQuery.of(context).size.width * 0.50,
    blurSize: 5.0,
    menuItemExtent: 45,
    menuBoxDecoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(15.0))),
    duration: Duration(milliseconds: 100),
    animateMenuItems: true,
    blurBackgroundColor: Colors.black54,
    menuOffset: 10.0, // Offset value to show menuItem from the selected item
    bottomOffsetHeight: mediaData.size.height *
        0.1, // Offset height to consider, for showing the menu item ( for example bottom navigation bar), so that the popup menu will be shown on top of selected item.
    menuItems: <FocusedMenuItem>[
      lastAssign == today
          ? FocusedMenuItem(
              title: Text("Edit Assigned Items"),
              trailingIcon: Icon(Icons.add_shopping_cart),
              onPressed: () {
                pushNewScreenWithRouteSettings(
                  context,
                  settings: RouteSettings(
                    name: EditAssign.id,
                  ),
                  screen: EditAssign('admin', repID),
                  withNavBar: true,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
            )
          : FocusedMenuItem(
              title: Text("Assign Items"),
              trailingIcon: Icon(Icons.add_shopping_cart),
              onPressed: () {
                pushNewScreenWithRouteSettings(
                  context,
                  settings: RouteSettings(
                    name: AssignItems.id,
                  ),
                  screen: AssignItems('admin', repID),
                  withNavBar: true,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
            ),
      FocusedMenuItem(
        title: Text("View Profile"),
        trailingIcon: Icon(Icons.bar_chart),
        onPressed: () {
          pushNewScreenWithRouteSettings(
            context,
            settings: RouteSettings(
              name: RepProfile.id,
            ),
            screen: RepProfile(repID),
            withNavBar: true,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
      ),
      FocusedMenuItem(
        title: Text("Send Email"),
        trailingIcon: Icon(Icons.email),
        onPressed: () {
          final Uri emailLaunchUri = Uri(
            scheme: 'mailto',
            path: eMail,
          );
          launch(emailLaunchUri.toString());
        },
      ),
      FocusedMenuItem(
        title: Text("Call"),
        trailingIcon: Icon(Icons.call),
        onPressed: () {
          final Uri telLaunchUri = Uri(
            scheme: 'tel',
            path: telNumber,
          );
          launch(telLaunchUri.toString());
        },
      ),
      if (repRole != 'admin')
        repStatus == 'enable'
            ? FocusedMenuItem(
                title: Text("Disable Rep"),
                trailingIcon: Icon(
                  Icons.pause_circle,
                  color: Colors.red,
                ),
                onPressed: () async {
                  await _firestore
                      .collection("users")
                      .doc(repID)
                      .update({'status': 'disable'});
                },
              )
            : FocusedMenuItem(
                title: Text("Enable Rep"),
                trailingIcon: Icon(
                  Icons.play_circle,
                  color: Colors.lightGreen,
                ),
                onPressed: () async {
                  await _firestore
                      .collection("users")
                      .doc(repID)
                      .update({'status': 'enable'});
                },
              ),
    ],
    onPressed: () {},
    child: Container(
      margin: EdgeInsets.only(top: 10.0),
      width: mediaData.size.width * 0.95,
      height: mediaData.size.height * 0.15,
      decoration: BoxDecoration(
        boxShadow: boxShadowsReps(),
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: buildImage(mediaData, imgURL),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: repRole == 'admin'
                    ? EdgeInsets.only(top: 5.0, left: 14.0)
                    : EdgeInsets.only(top: 8.0, left: 14.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: mediaData.size.height * 0.034,
                        fontFamily: 'Exo2',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (repRole != 'admin')
                      repStatus == 'enable'
                          ? Icon(
                              Icons.play_circle,
                              color: Color(0xFF79CCCA),
                            )
                          : Icon(
                              Icons.pause_circle,
                              color: Colors.red,
                            ),
                  ],
                ),
              ),
              if (repRole == 'admin')
                Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: Text(
                    '(Admin)',
                    style: TextStyle(
                      fontSize: mediaData.size.height * 0.0225,
                      fontFamily: 'Exo2',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 14.0),
                child: Text(
                  eMail,
                  style: TextStyle(
                    fontSize: mediaData.size.height * 0.02,
                    fontFamily: 'Exo2',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: Text(
                  telNumber,
                  style: TextStyle(
                    fontSize: mediaData.size.height * 0.02,
                    fontFamily: 'Exo2',
                  ),
                ),
              ),
              lastAssign == today && repRole == 'rep'
                  ? Padding(
                      padding: const EdgeInsets.only(left: 14.0),
                      child: Text(
                        'Assigned',
                        style: TextStyle(
                          fontSize: mediaData.size.height * 0.022,
                          fontFamily: 'Exo2',
                          color: Color(0xFF79CCCA),
                        ),
                      ),
                    )
                  : Text(''),
            ],
          ),
        ],
      ),
    ),
  );
}
