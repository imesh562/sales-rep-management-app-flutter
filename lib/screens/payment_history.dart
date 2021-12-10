import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/components/lists.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';

User? loggedInUser1;

// ignore: must_be_immutable
class PaymentHistory extends StatefulWidget {
  static String id = 'payment_history';
  var userRoleDash;

  PaymentHistory(this.userRoleDash);
  @override
  _PaymentHistoryState createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  late StreamSubscription subscription;
  bool showSpinner = false;
  final _firestore = FirebaseFirestore.instance;

  DateTime? calendarDate;
  String searchText = "";

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
        body: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(
                      top: mediaData.size.height * 0.015,
                      left: mediaData.size.width * 0.04,
                    ),
                    width: mediaData.size.width * 0.7,
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
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: mediaData.size.height * 0.015,
                    left: mediaData.size.width * 0.04,
                  ),
                  child: TextButton(
                    onPressed: () {
                      _selectDate(context);
                    },
                    child: Icon(
                      Icons.calendar_today,
                      size: mediaData.size.height * 0.05,
                      color: Color(
                        0xFF509877,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            GetEventsForDay(
              _firestore,
              searchText,
              calendarDate,
              widget.userRoleDash,
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
                              calendarDate = null;
                            });
                        },
                        icon: Icon(Icons.refresh),
                        label: Text(
                          'Reset Calender',
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
          calendarDate = selected;
        });
    }
  }
}
