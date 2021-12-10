import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/components/exception_manage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'attendance_lists.dart';

User? loggedInUser1;

// ignore: must_be_immutable
class ScanQR extends StatefulWidget {
  static String id = 'order_screen';
  var userRoleDash;

  ScanQR(this.userRoleDash);
  @override
  _ScanQRState createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  late StreamSubscription subscription;
  bool showSpinner = false;
  final _firestore = FirebaseFirestore.instance;
  String searchText = "";
  DateTime? selectedDate;
  String qrValue = "unknown";
  String repNameFull = "";

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

  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
    if (this.mounted)
      setState(() {
        qrValue = barcodeScanRes;
      });
    await checkShop(barcodeScanRes);
  }

  Future<void> checkShop(barcodeScanRes) async {
    if (this.mounted)
      setState(() {
        showSpinner = true;
      });
    QuerySnapshot querySnapshot = await _firestore.collection("shops").get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      var a = querySnapshot.docs[i];
      if (qrValue == a.id) {
        DateTime now = new DateTime.now();
        DateTime date = new DateTime(now.year, now.month, now.day);
        DateTime time = new DateTime(
            now.year, now.month, now.day, now.hour, now.minute, now.second);
        try {
          QuerySnapshot document1 = await _firestore
              .collection('attendance')
              .where("shop_id", isEqualTo: a.id)
              .where(
                "date",
                isEqualTo: date.toString().substring(0, 10),
              )
              .get();
          if (document1.docs.isEmpty) {
            await _firestore
                .collection("users")
                .doc(loggedInUser1!.uid)
                .get()
                .then((result) {
              if (this.mounted)
                setState(() {
                  repNameFull = result.get('name');
                });
            });
            await _firestore.collection('attendance').doc().set({
              'shop_id': a.id,
              'shop_name': a.get('shop_name'),
              'date': date.toString().substring(0, 10),
              'time': time.toString().substring(10, 19),
              'rep_name': repNameFull,
              'rep_id': loggedInUser1!.uid,
            });
            await _firestore.collection('shops').doc(a.id).update({
              'last_visit': date.toString().substring(0, 10),
            });
            Alert(
              context: context,
              type: AlertType.success,
              title: "Successful",
              desc: "Attendance marked successfuly",
              buttons: [
                DialogButton(
                  child: Text(
                    "Ok",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () {
                    if (this.mounted)
                      setState(() {
                        showSpinner = false;
                      });
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  width: 120,
                )
              ],
            ).show();
          } else {
            Alert(
              context: context,
              type: AlertType.warning,
              title: "Warning",
              desc: "Attendance already recorded !",
              buttons: [
                DialogButton(
                  child: Text(
                    "Ok",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () {
                    if (this.mounted)
                      setState(() {
                        showSpinner = false;
                      });
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  width: 120,
                )
              ],
            ).show();
          }
        } catch (e) {
          if (this.mounted)
            setState(() {
              showSpinner = false;
            });
          ExceptionManagement.registerExceptions(
            context: context,
            error: e.toString(),
          );
        }
        break;
      }
    }
    if (this.mounted)
      setState(() {
        showSpinner = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: appBarComponenet(mediaData, 'Scan QR'),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(
                mediaData.size.width * 0.025,
              ),
              margin: EdgeInsets.symmetric(
                horizontal: mediaData.size.width * 0.04,
                vertical: mediaData.size.width * 0.05,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: boxShadowsReps(),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Row(
                children: [
                  Container(
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
            AttendanceList(
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
                          scanQR();
                        },
                        icon: Icon(Icons.qr_code),
                        label: Text(
                          'Scan QR',
                          style: TextStyle(
                              fontSize: mediaData.size.height * 0.026),
                        ),
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor:
                              widget.userRoleDash.toString() == 'admin'
                                  ? Color(0xFF509877)
                                  : Color(0xFF2aa7df),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: mediaData.size.width * 0.05,
                    ),
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
