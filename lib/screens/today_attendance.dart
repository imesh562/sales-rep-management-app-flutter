import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/today_attendance_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';

User? loggedInUser1;

// ignore: must_be_immutable
class TodayAttendance extends StatefulWidget {
  static String id = 'order_screen';
  var userRoleDash;

  TodayAttendance(this.userRoleDash);
  @override
  _TodayAttendanceState createState() => _TodayAttendanceState();
}

class _TodayAttendanceState extends State<TodayAttendance> {
  late StreamSubscription subscription;
  bool showSpinner = false;
  final _firestore = FirebaseFirestore.instance;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      checkConnection(hasInternet, context);
    });
    loggedInUser1 = FirebaseAuth.instance.currentUser;
    setState(() {
      DateTime now = new DateTime.now();
      selectedDate = new DateTime(now.year, now.month, now.day);
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
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: appBarComponenet(mediaData, 'Today Attendance'),
        body: Column(
          children: [
            TodayAttendanceList(
              _firestore,
              selectedDate,
            ),
          ],
        ),
      ),
    );
  }
}
