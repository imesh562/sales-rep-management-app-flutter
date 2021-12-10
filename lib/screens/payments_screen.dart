import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/components/exception_manage.dart';
import 'package:dk_brothers/components/tiles.dart';
import 'package:dk_brothers/screens/payments.dart';
import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

User? loggedInUser1;
String selectedID = "";
String selectedName = "";

// ignore: must_be_immutable
class PaymentScreen extends StatefulWidget {
  static String id = 'payment_screen';
  var userRoleDash;

  PaymentScreen(this.userRoleDash);
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late StreamSubscription subscription;
  bool showSpinner = false;
  final _firestore = FirebaseFirestore.instance;

  GlobalKey<FormState> _key = GlobalKey();
  GlobalKey<FormState> _amountKey = GlobalKey();
  TextEditingController amountController = TextEditingController();

  int orderBy = 1;
  var orderByText = 'Name';

  late Color btnColor1;
  late Color btnColor2;
  var paymentMethod = "";
  late double amount;
  late String chequeNum;
  late String bankName;
  DateTime? selectedDate;
  late String shopName;
  late String telNum;
  late String location;
  bool internet = true;
  late String repNameFull;

  @override
  void initState() {
    super.initState();
    colorAssign();
    subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      checkConnection(hasInternet, context);
      checkInternet(hasInternet);
    });
    loggedInUser1 = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  colorAssign() {
    btnColor1 = widget.userRoleDash.toString() == 'admin'
        ? Color(0xFF509877)
        : Color(0xFF2aa7df);
    btnColor2 = widget.userRoleDash.toString() == 'admin'
        ? Color(0xFF509877)
        : Color(0xFF2aa7df);
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              width: mediaData.size.width * 0.95,
              height: mediaData.size.height * 0.3,
              margin: EdgeInsets.only(
                left: mediaData.size.width * 0.04,
                right: mediaData.size.width * 0.04,
                top: mediaData.size.height * 0.01,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: boxShadowsReps(),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            top: mediaData.size.height * 0.02,
                            bottom: mediaData.size.height * 0.005,
                            right: mediaData.size.width * 0.02,
                            left: mediaData.size.width * 0.02),
                        child: ShopDropDown(_firestore),
                        width: mediaData.size.width * 0.8,
                        height: mediaData.size.height * 0.075,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Container(
                            height: mediaData.size.height * 0.1,
                            width: mediaData.size.width * 0.8,
                            child: Form(
                              key: _amountKey,
                              child: TextFormField(
                                controller: amountController,
                                style: TextStyle(
                                    fontSize: mediaData.size.height * 0.03),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: kPaymentTextField,
                                validator: (value) {
                                  final numericRegex = RegExp(
                                      r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
                                  final numericRegex1 =
                                      RegExp(r'^[0-9]+[0-9]*$');
                                  if (value!.isEmpty) {
                                    return "Payment amount is required";
                                  } else if (!numericRegex.hasMatch(value) ||
                                      !numericRegex1.hasMatch(value)) {
                                    return 'Enter a valid value';
                                  } else if (double.parse(value) <= 0) {
                                    return 'Enter a valid value';
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    if (this.mounted)
                                      setState(() {
                                        amount = double.parse(value);
                                      });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: roundButton(btnColor1, mediaData),
                        onPressed: () {
                          if (paymentMethod != 'cash') {
                            if (this.mounted)
                              setState(() {
                                btnColor1 =
                                    widget.userRoleDash.toString() == 'admin'
                                        ? Color(0xFF7a459d)
                                        : Color(0xFF7a459d);
                                btnColor2 =
                                    widget.userRoleDash.toString() == 'admin'
                                        ? Color(0xFF509877)
                                        : Color(0xFF2aa7df);
                                paymentMethod = 'cash';
                              });
                          }
                        },
                        child: Text(
                          'Cash',
                          style: TextStyle(
                            fontFamily: 'Exo2',
                            fontSize: mediaData.size.height * 0.026,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: mediaData.size.width * 0.045,
                      ),
                      ElevatedButton(
                        style: roundButton(btnColor2, mediaData),
                        onPressed: () {
                          chequeForm(mediaData);
                        },
                        child: Text(
                          'Cheque',
                          style: TextStyle(
                            fontFamily: 'Exo2',
                            fontSize: mediaData.size.height * 0.026,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: mediaData.size.width * 0.045,
                      ),
                      ElevatedButton(
                        child: Icon(Icons.check),
                        style: roundButton1(
                            widget.userRoleDash.toString() == 'admin'
                                ? Color(0xFF7a459d)
                                : Color(0xFF7a459d),
                            mediaData),
                        onPressed: () {
                          Alert(
                            context: context,
                            type: AlertType.warning,
                            title: "Confirm",
                            desc: "Confirm the Payment?",
                            buttons: [
                              DialogButton(
                                child: Text(
                                  "Yes",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                onPressed: () async {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  bool amountCheck = false;
                                  // ignore: unnecessary_null_comparison
                                  if (_amountKey.currentState!
                                          // ignore: unnecessary_null_comparison
                                          .validate() !=
                                      null) {
                                    amountCheck =
                                        _amountKey.currentState!.validate();
                                  }
                                  // ignore: unnecessary_statements
                                  if (amountCheck) {
                                    if (this.mounted)
                                      setState(() {
                                        showSpinner = true;
                                      });
                                    try {
                                      _orderConfirm(selectedID, paymentMethod,
                                          context, selectedName);
                                      // ignore: unused_catch_clause
                                    } on Exception catch (e) {
                                      showTopSnackBar(
                                          context,
                                          CustomSnackBar.error(
                                            message: 'ERROR',
                                            textStyle: TextStyle(
                                              fontFamily: 'Exo2',
                                              fontSize: 20.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                          showOutAnimationDuration:
                                              Duration(milliseconds: 500));
                                      if (this.mounted)
                                        setState(() {
                                          showSpinner = false;
                                        });
                                    }
                                    if (this.mounted)
                                      setState(
                                        () {
                                          showSpinner = false;
                                        },
                                      );
                                  }
                                },
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: mediaData.size.height * 0.01),
              child: Text(
                'Recent Payments',
                style: TextStyle(
                  fontFamily: 'Exo2',
                  fontSize: mediaData.size.height * 0.03,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GetRecentPayments(widget.userRoleDash),
          ],
        ),
      ),
    );
  }

  chequeForm(MediaQueryData mediaData) {
    Alert(
        context: context,
        title: "Cheque Details",
        style: AlertStyle(
          titleStyle: TextStyle(
            fontFamily: 'Exo2',
          ),
        ),
        content: Form(
          key: _key,
          child: Column(
            children: <Widget>[
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cheque Number',
                  labelStyle: TextStyle(
                    fontFamily: 'Exo2',
                  ),
                ),
                onSaved: (value) {
                  if (this.mounted)
                    setState(() {
                      chequeNum = value!;
                    });
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  final number = num.tryParse(value!);
                  if (value.isEmpty) {
                    return "Cheque Number is required";
                  } else if (value.length != 6) {
                    return "Cheque Number should have 6 characters.";
                  } else if (number == null) {
                    return "Cheque Number is not valid.";
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                onSaved: (value) {
                  if (this.mounted)
                    setState(() {
                      bankName = value!;
                    });
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Bank name is required";
                  } else if (value.length < 3) {
                    return "Bank name should have at least 2 characters.";
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                    labelText: 'Bank',
                    labelStyle: TextStyle(
                      fontFamily: 'Exo2',
                    )),
              ),
              Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.only(top: 10.0, right: 10.0)),
                      onPressed: () {
                        _selectDate1(context);
                      },
                      icon: Icon(Icons.calendar_today),
                      label: selectedDate == null
                          ? Text("Withdraw Date")
                          : Text("Withdraw Date: " +
                              selectedDate.toString().substring(0, 10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              bool validation = false;
              // ignore: unnecessary_null_comparison
              if (_key.currentState!.validate() != null) {
                validation = _key.currentState!.validate();
              }
              if (selectedDate == null) {
                Fluttertoast.showToast(
                    msg: "Please select a Withdraw Date",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1);
              }
              // ignore: unnecessary_statements
              if (validation && selectedDate != null) {
                _key.currentState!.save();
                if (this.mounted)
                  setState(() {
                    btnColor1 = widget.userRoleDash.toString() == 'admin'
                        ? Color(0xFF509877)
                        : Color(0xFF2aa7df);
                    btnColor2 = widget.userRoleDash.toString() == 'admin'
                        ? Color(0xFF7a459d)
                        : Color(0xFF7a459d);
                    paymentMethod = 'cheque';
                  });
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
            child: Text(
              "Submit",
              style: TextStyle(
                color: Colors.white,
                fontSize: mediaData.size.height * 0.025,
                fontFamily: 'Exo2',
              ),
            ),
          )
        ]).show();
  }

  void checkInternet(bool hasInternet) {
    if (this.mounted)
      setState(() {
        internet = hasInternet;
      });
  }

  _orderConfirm(String selectedID1, String paymentMethod, BuildContext context,
      String selectedName) async {
    if (selectedID1 == "" || paymentMethod == "") {
      Alert(
        context: context,
        type: AlertType.warning,
        title: "Warning",
        desc: "Please select a shop and Payment method",
        buttons: [
          DialogButton(
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            width: 120,
          )
        ],
      ).show();
    } else {
      if (internet) {
        await getUserData();
        await _orderToDB();
        if (this.mounted)
          setState(() {
            selectedID = "";
            selectedName = "";
            paymentMethod = "";
            amount = 0;
            chequeNum = "";
            bankName = "";
            selectedDate = null;
            shopName = "";
            telNum = "";
            location = "";
          });
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    Payments(0, widget.userRoleDash)));
      } else {
        Alert(
          context: context,
          type: AlertType.warning,
          title: "Warning",
          desc: "No Internet",
          buttons: [
            DialogButton(
              child: Text(
                "Ok",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              width: 120,
            )
          ],
        ).show();
      }
    }
  }

  getUserData() async {
    await _firestore
        .collection("users")
        .doc(loggedInUser1!.uid)
        .get()
        .then((result) {
      var name = result.get('name');
      if (this.mounted)
        setState(() {
          repNameFull = name;
        });
    });
  }

  _orderToDB() async {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);
    DateTime time = new DateTime(
        now.year, now.month, now.day, now.hour, now.minute, now.second);
    if (paymentMethod == 'cash') {
      try {
        await _firestore.collection('payments').doc().set({
          'shop_id': selectedID,
          'date': date.toString().substring(0, 10),
          'time': time.toString().substring(10, 19),
          'shop_name': selectedName,
          'payment': amount,
          'payment_method': paymentMethod,
          'rep_name': repNameFull,
          'rep_id': loggedInUser1!.uid,
          'status': 'enable',
        });
      } catch (e) {
        ExceptionManagement.registerExceptions(
          context: context,
          error: e.toString(),
        );
      }
    }
    if (paymentMethod == 'cheque') {
      try {
        await _firestore.collection('payments').doc().set({
          'shop_id': selectedID,
          'date': date.toString().substring(0, 10),
          'time': time.toString().substring(10, 19),
          'shop_name': selectedName,
          'payment': amount,
          'payment_method': paymentMethod,
          'rep_name': repNameFull,
          'rep_id': loggedInUser1!.uid,
          'cheque_num': chequeNum,
          'bank': bankName,
          'withdrawDate': selectedDate,
          'cheque_status': 'pending',
          'status': 'enable',
        });
      } catch (e) {
        ExceptionManagement.registerExceptions(
          context: context,
          error: e.toString(),
        );
      }
    }
  }

  _selectDate1(BuildContext context) async {
    DateTime now = new DateTime.now();
    DateTime finalDate = new DateTime(now.year, now.month, now.day);
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: finalDate,
      firstDate: finalDate,
      currentDate: finalDate,
      lastDate: new DateTime(now.year + 5, now.month, now.day),
    );
    if (selected != null) {
      if (this.mounted)
        setState(() {
          selectedDate = selected;
        });
    }
  }
}

// ignore: must_be_immutable
class ShopDropDown extends StatefulWidget {
  ShopDropDown(this.firestore);
  FirebaseFirestore firestore;
  @override
  _ShopDropDownState createState() => _ShopDropDownState();
}

class _ShopDropDownState extends State<ShopDropDown> {
  List<String> shopNameList = [];
  List<String> shopIDList = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.firestore
          .collection('shops')
          .orderBy('shop_name', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          shopNameList.clear();
          shopIDList.clear();
          final shops = snapshot.data!.docs.reversed;
          for (var shop in shops) {
            final shopName = shop['shop_name'];
            final shopStatus = shop['status'];
            final shopID = shop.reference.id;
            if (shopStatus != 'disable') {
              shopNameList.add(shopName);
              shopIDList.add(shopID);
            }
          }
          return TextDropdownFormField(
            options: shopNameList,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.arrow_drop_down),
              labelText: "Select Shop",
              labelStyle: TextStyle(
                fontFamily: 'Exo2',
              ),
              contentPadding: EdgeInsets.all(
                MediaQuery.of(context).size.height * 0.02,
              ),
            ),
            onChanged: (dynamic value) {
              var listIndex = shopNameList.indexOf(value);
              if (this.mounted)
                setState(() {
                  selectedName = value;
                  selectedID = shopIDList[listIndex];
                });
            },
            dropdownHeight: MediaQuery.of(context).size.height * 0.4,
          );
        }
        return TextDropdownFormField(
          options: [],
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.arrow_drop_down),
            labelText: "No Shops",
            labelStyle: TextStyle(
              fontFamily: 'Exo2',
            ),
          ),
          dropdownHeight: 120,
        );
      },
    );
  }
}
