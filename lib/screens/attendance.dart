import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';

import 'attendance_list_admin.dart';

User? loggedInUser1;

// ignore: must_be_immutable
class Attendance extends StatefulWidget {
  static String id = 'order_screen';
  var userRoleDash;

  Attendance(this.userRoleDash);
  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  late StreamSubscription subscription;
  bool showSpinner = false;
  final _firestore = FirebaseFirestore.instance;
  String searchText = "";
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      checkConnection(hasInternet, context);
    });
    loggedInUser1 = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: appBarComponenet(mediaData, 'Attendance'),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(
                mediaData.size.width * 0.025,
              ),
              margin: EdgeInsets.only(
                right: mediaData.size.width * 0.04,
                left: mediaData.size.width * 0.04,
                top: mediaData.size.width * 0.025,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: boxShadowsReps(),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Row(
                children: [
                  Container(
                    width: mediaData.size.width * 0.68,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Search',
                        labelStyle: loginCredentials,
                        prefixIcon: Icon(
                          FontAwesomeIcons.search,
                          color: widget.userRoleDash.toString() == 'admin'
                              ? Color(0xFF7a459d)
                              : Color(0xFF7a459d),
                        ),
                        errorStyle: TextStyle(fontSize: 12, height: 0.3),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: widget.userRoleDash.toString() == 'admin'
                                  ? Color(0xFF7a459d)
                                  : Color(0xFF7a459d)),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: widget.userRoleDash.toString() == 'admin'
                                  ? Color(0xFF7a459d)
                                  : Color(0xFF7a459d)),
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
                  TextButton(
                    onPressed: () {
                      _selectDate(context);
                    },
                    child: Icon(
                      Icons.calendar_today,
                      size: mediaData.size.height * 0.05,
                      color: widget.userRoleDash.toString() == 'admin'
                          ? widget.userRoleDash.toString() == 'admin'
                              ? Color(0xFF509877)
                              : Color(0xFF2aa7df)
                          : Color(0xFF2aa7df),
                    ),
                  ),
                ],
              ),
            ),
            AttendanceListAdmin(
              _firestore,
              searchText,
              selectedDate,
              loggedInUser1!.uid,
            ),
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: Container(
                color: Colors.grey[200],
                padding: EdgeInsets.all(mediaData.size.height * 0.02),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          if (this.mounted)
                            setState(() {
                              selectedDate = null;
                            });
                        },
                        icon: Icon(Icons.view_agenda),
                        label: Text(
                          'View All',
                          style: TextStyle(
                              fontSize: mediaData.size.height * 0.026),
                        ),
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor:
                              widget.userRoleDash.toString() == 'admin'
                                  ? Color(0xFF7a459d)
                                  : Color(0xFF7a459d),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _selectDate(BuildContext context) async {
    DateTime now = new DateTime.now();
    DateTime finalDate = new DateTime(now.year, now.month, now.day);
    String strDt = "2021-10-01 00:00:00.000";
    DateTime parseDt = DateTime.parse(strDt);
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: finalDate,
      firstDate: parseDt,
      currentDate: finalDate,
      lastDate: finalDate,
    );
    if (selected != null) {
      if (this.mounted)
        setState(() {
          selectedDate = selected;
        });
    }
  }
}
