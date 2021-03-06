import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/screens/rep_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

User? loggedInUser;
final _firestore = FirebaseFirestore.instance;
var userRole = "";

class AllReps extends StatefulWidget {
  static String id = 'all_reps';
  @override
  _AllRepsState createState() => _AllRepsState();
}

class _AllRepsState extends State<AllReps> {
  bool showSpinnerDash = false;
  late StreamSubscription subscription;
  bool showSpinner = false;

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
    getUserRole();
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
          userRole = role;
          showSpinner = false;
        });
    });
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
      body: ModalProgressHUD(
        inAsyncCall: showSpinnerDash,
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.only(
                      left: mediaData.size.width * 0.03,
                    ),
                    width: mediaData.size.width * 0.7,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Search',
                        labelStyle: loginCredentials,
                        prefixIcon: Icon(
                          FontAwesomeIcons.search,
                          color: Color(0xFF04DBDD),
                        ),
                        errorStyle: TextStyle(fontSize: 12, height: 0.3),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF04DBDD)),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF04DBDD)),
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
                          child: Text("Location"),
                          value: 3,
                        ),
                        DropdownMenuItem(
                          child: Text("Removed"),
                          value: 4,
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
                              orderBy = 4;
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
            child: Column(
              children: [
                Text(
                  'No Data',
                  style: krepReg.copyWith(color: Colors.black),
                ),
                SizedBox(
                  height: 20.0,
                ),
                CircularProgressIndicator(
                  backgroundColor: Colors.lightBlueAccent,
                ),
              ],
            ),
          );
        }
        final reps = snapshot.data!.docs.reversed;
        List<Widget> repList = [];
        for (var rep in reps) {
          final repEmail = rep['email'];
          final repMobile = rep['mobile_num'];
          final repname = rep['name'];
          final repStatus = rep['status'];
          final repRole = rep['role'];
          final imgURL = rep['img_url'];
          final lastAssign = rep['last_assign'];
          final repID = rep.reference.id;

          repList.add(repListBuilder(
              repname,
              repEmail,
              repMobile,
              mediaData,
              context,
              repStatus,
              repID,
              repRole,
              imgURL,
              lastAssign,
              today,
              repEmail));
        }
        return Expanded(
          child: Container(
            child: ListView.builder(
              controller: controller,
              itemCount: repList.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Align(
                  heightFactor: 0.8,
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
  String email,
  String telNumber,
  MediaQueryData mediaData,
  BuildContext context,
  String repStatus,
  String repID,
  String repRole,
  String imgURL,
  String lastAssign,
  String today,
  String eMail,
) {
  return GestureDetector(
    onTap: () {
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
