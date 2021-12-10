import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/components/exception_manage.dart';
import 'package:dk_brothers/screens/payments.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'edit_payment.dart';

User? loggedInUser1;

// ignore: must_be_immutable
class ViewPayment extends StatefulWidget {
  static String id = 'view_payment';
  var paymentID;
  var userRoleDash;

  ViewPayment(
    this.paymentID,
    this.userRoleDash,
  );

  @override
  _ViewPaymentState createState() => _ViewPaymentState();
}

class _ViewPaymentState extends State<ViewPayment> {
  late StreamSubscription subscription;
  bool showSpinner = false;
  final _firestore = FirebaseFirestore.instance;
  late List<String> wordList;

  var repNameShort = "";
  var repName = "";
  var date = "";
  var payment = 0.0;
  var paymentMethod = "";
  var shopID = "";
  var shopName = "";
  var time = "00:00:00";
  var orderID = "";
  var bank = "";
  var chequeNum = "";
  var withdrawDate = Timestamp(0, 0);
  var chequeStatus = 'pending';
  var userRole;
  var repID;

  bool showEdit = true;

  late Color btnColor1;
  late Color btnColor2;
  late Color btnColor3;

  @override
  void initState() {
    super.initState();
    subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      checkConnection(hasInternet, context);
    });
    loggedInUser1 = FirebaseAuth.instance.currentUser;
    waitingList();
  }

  waitingList() async {
    await getPaymentData();
    wordList = repName.split(" ");
    repNameShort = wordList[0];
    await getUserRole();
  }

  getPaymentData() async {
    if (this.mounted)
      setState(() {
        showSpinner = true;
      });
    await _firestore
        .collection("payments")
        .doc(widget.paymentID)
        .get()
        .then((result) {
      if (this.mounted)
        setState(() {
          repName = result.get('rep_name');
          date = result.get('date');
          payment = result.get('payment');
          paymentMethod = result.get('payment_method');
          shopID = result.get('shop_id');
          shopName = result.get('shop_name');
          time = result.get('time');
          repID = result.get('rep_id');
          if ((result.data() as Map<String, dynamic>).containsKey('order_id')) {
            orderID = result.get('order_id');
          }
          if (paymentMethod == 'cheque') {
            bank = result.get('bank');
            chequeNum = result.get('cheque_num');
            withdrawDate = result.get('withdrawDate');
            chequeStatus = result.get('cheque_status');
            if (chequeStatus == 'pending') {
              btnColor1 = widget.userRoleDash.toString() == 'admin'
                  ? Color(0xFF7a459d)
                  : Color(0xFF7a459d);
              btnColor2 = widget.userRoleDash.toString() == 'admin'
                  ? Color(0xFF509877)
                  : Color(0xFF2aa7df);
              btnColor3 = widget.userRoleDash.toString() == 'admin'
                  ? Color(0xFF509877)
                  : Color(0xFF2aa7df);
              chequeStatus = 'pending';
            }
            if (chequeStatus == 'returned') {
              btnColor1 = widget.userRoleDash.toString() == 'admin'
                  ? Color(0xFF509877)
                  : Color(0xFF2aa7df);
              btnColor2 = widget.userRoleDash.toString() == 'admin'
                  ? Color(0xFF7a459d)
                  : Color(0xFF7a459d);
              btnColor3 = widget.userRoleDash.toString() == 'admin'
                  ? Color(0xFF509877)
                  : Color(0xFF2aa7df);
              chequeStatus = 'returned';
            }
            if (chequeStatus == 'completed') {
              btnColor1 = widget.userRoleDash.toString() == 'admin'
                  ? Color(0xFF509877)
                  : Color(0xFF2aa7df);
              btnColor2 = widget.userRoleDash.toString() == 'admin'
                  ? Color(0xFF509877)
                  : Color(0xFF2aa7df);
              btnColor3 = widget.userRoleDash.toString() == 'admin'
                  ? Color(0xFF7a459d)
                  : Color(0xFF7a459d);
              chequeStatus = 'completed';
            }
          }
        });
    });
    if (this.mounted)
      setState(() {
        showSpinner = false;
      });
  }

  getUserRole() async {
    await _firestore
        .collection("users")
        .doc(loggedInUser1!.uid)
        .get()
        .then((result) {
      var role = result.get('role');
      if (this.mounted)
        setState(() {
          userRole = role;
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
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: appBarComponenet(mediaData, shopName),
        body: Container(
          margin: EdgeInsets.only(top: mediaData.size.height * 0.015),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(
                  mediaData.size.width * 0.025,
                ),
                margin: EdgeInsets.only(
                  left: mediaData.size.width * 0.04,
                  right: mediaData.size.width * 0.04,
                  bottom: mediaData.size.width * 0.015,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: boxShadowsReps(),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: mediaData.size.height * 0.015),
                              child: Text(
                                'Date',
                                style: TextStyle(
                                    fontFamily: 'Exo2',
                                    fontWeight: FontWeight.bold,
                                    fontSize: mediaData.size.height * 0.021),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: mediaData.size.height * 0.015),
                              child: Text(
                                'Payment',
                                style: TextStyle(
                                    fontFamily: 'Exo2',
                                    fontWeight: FontWeight.bold,
                                    fontSize: mediaData.size.height * 0.021),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: mediaData.size.height * 0.015),
                              child: Text(
                                'Rep',
                                style: TextStyle(
                                    fontFamily: 'Exo2',
                                    fontWeight: FontWeight.bold,
                                    fontSize: mediaData.size.height * 0.021),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: mediaData.size.width * 0.025,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: mediaData.size.height * 0.015),
                              child: Text(
                                ': ' + date,
                                style: TextStyle(
                                    fontFamily: 'Exo2',
                                    fontWeight: FontWeight.bold,
                                    fontSize: mediaData.size.height * 0.021),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: mediaData.size.height * 0.015),
                              child: Text(
                                ': Rs. ' + payment.toString(),
                                style: TextStyle(
                                    fontFamily: 'Exo2',
                                    fontWeight: FontWeight.bold,
                                    fontSize: mediaData.size.height * 0.021),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: mediaData.size.height * 0.015),
                              child: Text(
                                ': ' + repNameShort,
                                style: TextStyle(
                                    fontFamily: 'Exo2',
                                    fontWeight: FontWeight.bold,
                                    fontSize: mediaData.size.height * 0.021),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: mediaData.size.width * 0.075,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: mediaData.size.height * 0.015),
                              child: Text(
                                'Time',
                                style: TextStyle(
                                    fontFamily: 'Exo2',
                                    fontWeight: FontWeight.bold,
                                    fontSize: mediaData.size.height * 0.021),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: mediaData.size.height * 0.015),
                              child: Text(
                                'Type',
                                style: TextStyle(
                                    fontFamily: 'Exo2',
                                    fontWeight: FontWeight.bold,
                                    fontSize: mediaData.size.height * 0.021),
                              ),
                            ),
                            orderID != ""
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        bottom: mediaData.size.height * 0.015),
                                    child: Text(
                                      'Order ID',
                                      style: TextStyle(
                                          fontFamily: 'Exo2',
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              mediaData.size.height * 0.021),
                                    ),
                                  )
                                : Text(""),
                          ],
                        ),
                        SizedBox(
                          width: mediaData.size.width * 0.025,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: mediaData.size.height * 0.015),
                              child: Text(
                                ': ' + time.toString().substring(0, 6),
                                style: TextStyle(
                                    fontFamily: 'Exo2',
                                    fontWeight: FontWeight.bold,
                                    fontSize: mediaData.size.height * 0.021),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: mediaData.size.height * 0.015),
                              child: Text(
                                ': ' + paymentMethod,
                                style: TextStyle(
                                    fontFamily: 'Exo2',
                                    fontWeight: FontWeight.bold,
                                    fontSize: mediaData.size.height * 0.021),
                              ),
                            ),
                            orderID != ""
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        bottom: mediaData.size.height * 0.015),
                                    child: Text(
                                      ': ' + orderID.toString(),
                                      style: TextStyle(
                                          fontFamily: 'Exo2',
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              mediaData.size.height * 0.021),
                                    ),
                                  )
                                : Text(""),
                          ],
                        )
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        DateTime date = DateTime.fromMicrosecondsSinceEpoch(
                            withdrawDate.microsecondsSinceEpoch);
                        Alert(
                          context: context,
                          type: AlertType.info,
                          title: "Cheque Info",
                          desc: 'Bank : ' +
                              bank +
                              '\n Cheque Number : ' +
                              chequeNum +
                              '\n Withdraw Date : ' +
                              date.toString().substring(0, 10) +
                              '\n Status : ' +
                              chequeStatus,
                          buttons: [
                            DialogButton(
                              child: Text(
                                "Ok",
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
                        child: paymentMethod == 'cheque'
                            ? Padding(
                                padding: EdgeInsets.only(
                                    top: mediaData.size.height * 0.0075),
                                child: Text(
                                  'View Cheque Info',
                                  style: TextStyle(
                                      color: Colors.lightBlue,
                                      fontFamily: 'Exo2',
                                      fontWeight: FontWeight.bold,
                                      fontSize: mediaData.size.height * 0.021),
                                ),
                              )
                            : Text(''),
                      ),
                    )
                  ],
                ),
              ),
              paymentMethod == 'cheque' && userRole.toString() == 'admin'
                  ? Container(
                      width: mediaData.size.width * 0.95,
                      height: mediaData.size.height * 0.14,
                      margin: EdgeInsets.only(
                        left: mediaData.size.width * 0.04,
                        right: mediaData.size.width * 0.04,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: boxShadowsReps(),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: mediaData.size.height * 0.01),
                            child: Text(
                              'Change Cheque Status',
                              style: TextStyle(
                                fontFamily: 'Exo2',
                                fontWeight: FontWeight.bold,
                                fontSize: mediaData.size.height * 0.025,
                              ),
                            ),
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: roundButton(btnColor1, mediaData),
                                  onPressed: () async {
                                    if (chequeStatus != 'pending') {
                                      try {
                                        if (this.mounted)
                                          setState(() {
                                            showSpinner = true;
                                            chequeStatus = 'pending';
                                          });
                                        await _firestore
                                            .collection('payments')
                                            .doc(widget.paymentID.toString())
                                            .update({
                                          'cheque_status': chequeStatus,
                                        });
                                        if (this.mounted)
                                          setState(() {
                                            btnColor1 = widget.userRoleDash
                                                        .toString() ==
                                                    'admin'
                                                ? Color(0xFF7a459d)
                                                : Color(0xFF7a459d);
                                            btnColor2 = widget.userRoleDash
                                                        .toString() ==
                                                    'admin'
                                                ? Color(0xFF509877)
                                                : Color(0xFF2aa7df);
                                            btnColor3 = widget.userRoleDash
                                                        .toString() ==
                                                    'admin'
                                                ? Color(0xFF509877)
                                                : Color(0xFF2aa7df);
                                            showSpinner = false;
                                          });
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
                                    }
                                  },
                                  child: Text(
                                    'Pending',
                                    style: TextStyle(
                                      fontFamily: 'Exo2',
                                      fontSize: mediaData.size.height * 0.023,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: mediaData.size.width * 0.035,
                                ),
                                ElevatedButton(
                                  style: roundButton(btnColor2, mediaData),
                                  onPressed: () async {
                                    if (chequeStatus != 'returned') {
                                      try {
                                        if (this.mounted)
                                          setState(() {
                                            showSpinner = true;
                                            chequeStatus = 'returned';
                                          });
                                        await _firestore
                                            .collection('payments')
                                            .doc(widget.paymentID.toString())
                                            .update({
                                          'cheque_status': chequeStatus,
                                        });
                                        if (this.mounted)
                                          setState(() {
                                            btnColor1 = widget.userRoleDash
                                                        .toString() ==
                                                    'admin'
                                                ? Color(0xFF509877)
                                                : Color(0xFF2aa7df);
                                            btnColor2 = widget.userRoleDash
                                                        .toString() ==
                                                    'admin'
                                                ? Color(0xFF7a459d)
                                                : Color(0xFF7a459d);
                                            btnColor3 = widget.userRoleDash
                                                        .toString() ==
                                                    'admin'
                                                ? Color(0xFF509877)
                                                : Color(0xFF2aa7df);
                                            showSpinner = false;
                                          });
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
                                    }
                                  },
                                  child: Text(
                                    'Returned',
                                    style: TextStyle(
                                      fontFamily: 'Exo2',
                                      fontSize: mediaData.size.height * 0.023,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: mediaData.size.width * 0.035,
                                ),
                                ElevatedButton(
                                  style: roundButton(btnColor3, mediaData),
                                  onPressed: () async {
                                    if (chequeStatus != 'completed') {
                                      try {
                                        if (this.mounted)
                                          setState(() {
                                            showSpinner = true;
                                            chequeStatus = 'completed';
                                          });
                                        await _firestore
                                            .collection('payments')
                                            .doc(widget.paymentID.toString())
                                            .update({
                                          'cheque_status': chequeStatus,
                                        });
                                        if (this.mounted)
                                          setState(() {
                                            btnColor1 = widget.userRoleDash
                                                        .toString() ==
                                                    'admin'
                                                ? Color(0xFF509877)
                                                : Color(0xFF2aa7df);
                                            btnColor2 = widget.userRoleDash
                                                        .toString() ==
                                                    'admin'
                                                ? Color(0xFF509877)
                                                : Color(0xFF2aa7df);
                                            btnColor3 = widget.userRoleDash
                                                        .toString() ==
                                                    'admin'
                                                ? Color(0xFF7a459d)
                                                : Color(0xFF7a459d);
                                            showSpinner = false;
                                          });
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
                                    }
                                  },
                                  child: Text(
                                    'Completed',
                                    style: TextStyle(
                                      fontFamily: 'Exo2',
                                      fontSize: mediaData.size.height * 0.023,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Text(''),
              paymentMethod == 'cash'
                  ? EditPayment(
                      showEdit,
                      shopName,
                      orderID,
                      payment,
                      paymentMethod,
                      shopID,
                      repName,
                      widget.paymentID,
                      widget.userRoleDash,
                      repID,
                    )
                  : EditPayment.cheque(
                      showEdit,
                      shopName,
                      orderID,
                      payment,
                      paymentMethod,
                      shopID,
                      bank,
                      chequeNum,
                      withdrawDate,
                      repName,
                      widget.paymentID,
                      widget.userRoleDash,
                      repID,
                    ),
              if ((loggedInUser1!.uid.toString() == repID.toString()) ||
                  userRole.toString() == 'admin')
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
                                  if (showEdit == false) {
                                    showEdit = true;
                                  } else {
                                    showEdit = false;
                                  }
                                });
                            },
                            icon: Icon(Icons.edit),
                            label: Text(
                              'Edit',
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
                              Alert(
                                context: context,
                                type: AlertType.warning,
                                title: "Warning",
                                desc:
                                    "Are you sure you want to remove this order?",
                                buttons: [
                                  DialogButton(
                                    child: Text(
                                      "Yes",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    onPressed: () async {
                                      await removePayment();
                                    },
                                    width: 120,
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
                            icon: Icon(Icons.delete),
                            label: Text(
                              'Remove',
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
      ),
    );
  }

  removePayment() async {
    try {
      if (orderID == "") {
        await _firestore
            .collection('payments')
            .doc(widget.paymentID)
            .update({'status': 'disable'});
      } else {
        await _firestore
            .collection('payments')
            .doc(widget.paymentID)
            .update({'status': 'disable'});
        if (paymentMethod == 'cash') {
          _firestore.collection('orders').doc(orderID.toString()).update({
            'payment_id': FieldValue.delete(),
            'payment': 0,
            'payment_method': 'credit',
          });
        } else {
          _firestore.collection('orders').doc(orderID.toString()).update({
            'payment_id': FieldValue.delete(),
            'bank': FieldValue.delete(),
            'cheque_num': FieldValue.delete(),
            'withdrawDate': FieldValue.delete(),
            'payment': 0,
            'payment_method': 'credit',
          });
        }
      }
      Navigator.of(context, rootNavigator: true).pop();
      Alert(
        context: context,
        type: AlertType.success,
        title: "Successful",
        desc: "Payment Removed",
        buttons: [
          DialogButton(
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(
                  builder: (BuildContext context) {
                    return Payments(0, widget.userRoleDash);
                  },
                ),
              );
            },
            width: 120,
          )
        ],
      ).show();
    } catch (e) {
      ExceptionManagement.registerExceptions(
        context: context,
        error: e.toString(),
      );
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
