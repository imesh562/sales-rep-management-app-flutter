import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/components/exception_manage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

User? loggedInUser1;

class ShopRegister extends StatefulWidget {
  static String id = 'rep_registert';

  @override
  _ShopRegisterState createState() => _ShopRegisterState();
}

class _ShopRegisterState extends State<ShopRegister> {
  late StreamSubscription subscription;
  String shopName = "", telephone = "", location = "";
  GlobalKey<FormState> _key = GlobalKey();
  bool showSpinner = false;
  bool textEdit = true;
  bool shopExist = false;
  final _firestore = FirebaseFirestore.instance;

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
        body: Stack(
          children: [
            Container(
              height: mediaData.size.height * 0.375,
              width: mediaData.size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF04DBDD),
                    Color(0xFFC9FFFF),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: mediaData.size.height * 0.1,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 30.0,
                          right: 12.0,
                        ),
                        child: Hero(
                          tag: 'addShop',
                          child: Icon(
                            Icons.add_business,
                            color: Color(0xFF00c1c4),
                            size: mediaData.size.height * 0.08,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(
                      'Add New',
                      style: krepReg,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(
                      'Store',
                      style: krepReg,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: mediaData.size.height * 0.65,
                  width: mediaData.size.width,
                  decoration: BoxDecoration(
                    boxShadow: boxShadows(),
                    color: Colors.white,
                    borderRadius: BorderRadiusDirectional.only(
                      topEnd: Radius.circular(65.0),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _key,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 35.0,
                          ),
                          Text(
                            "Enter shops data.",
                            textAlign: TextAlign.start,
                            style: loginLight.copyWith(
                                fontSize: mediaData.size.height * 0.025),
                          ),
                          SizedBox(height: 35.0),
                          SizedBox(
                            height: 70.0,
                            width: mediaData.size.width * 0.8,
                            child: TextFormField(
                              enabled: textEdit,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.name,
                              onChanged: (value) {
                                if (this.mounted)
                                  setState(() {
                                    shopName = value;
                                  });
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Name is required";
                                } else if (value.length < 3) {
                                  return "Name should have at least 2 characters.";
                                } else {
                                  return null;
                                }
                              },
                              maxLength: 24,
                              decoration: kRegisterFields.copyWith(
                                labelText: 'Shop Name',
                                labelStyle: TextStyle(
                                  fontFamily: 'Exo2',
                                  fontSize: 15.0,
                                  color: Color(0xFF00c1c4),
                                ),
                                suffixIcon: Icon(
                                  Icons.store,
                                  color: Color(0xFF00c1c4),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 70.0,
                            width: mediaData.size.width * 0.8,
                            child: TextFormField(
                              enabled: textEdit,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.phone,
                              onChanged: (value) {
                                if (this.mounted)
                                  setState(() {
                                    telephone = value;
                                  });
                              },
                              validator: (value) {
                                bool mobileValid =
                                    RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)')
                                        .hasMatch(value!);
                                if (value.isEmpty) {
                                  return "Contact Number is required";
                                } else if (!mobileValid) {
                                  return "Please enter a valid Contact number";
                                } else {
                                  return null;
                                }
                              },
                              maxLength: 10,
                              decoration: kRegisterFields.copyWith(
                                labelText: 'Contact Number',
                                labelStyle: TextStyle(
                                  fontFamily: 'Exo2',
                                  color: Color(0xFF00c1c4),
                                ),
                                suffixIcon: Icon(
                                  Icons.phone,
                                  color: Color(0xFF00c1c4),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 70.0,
                            width: mediaData.size.width * 0.8,
                            child: TextFormField(
                              enabled: textEdit,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.name,
                              onChanged: (value) {
                                if (this.mounted)
                                  setState(() {
                                    location = value;
                                  });
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Location is required";
                                } else if (value.length < 3) {
                                  return "Location should have at least 2 characters.";
                                } else {
                                  return null;
                                }
                              },
                              maxLength: 24,
                              decoration: kRegisterFields.copyWith(
                                labelText: 'Location',
                                labelStyle: TextStyle(
                                  fontFamily: 'Exo2',
                                  fontSize: 15.0,
                                  color: Color(0xFF00c1c4),
                                ),
                                suffixIcon: Icon(
                                  Icons.location_pin,
                                  color: Color(0xFF00c1c4),
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(5.0),
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  (EdgeInsets.all(15.0))),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xFF00c1c4)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(
                                    color: Color(0xFF00c1c4),
                                  ),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              bool validation = false;
                              // ignore: unnecessary_null_comparison
                              if (_key.currentState!.validate() != null) {
                                validation = _key.currentState!.validate();
                              }
                              if (validation) {
                                QuerySnapshot querySnapshot =
                                    await _firestore.collection("shops").get();
                                var list = querySnapshot.docs;
                                for (var element in list) {
                                  if (element['shop_name'] == shopName) {
                                    shopExist = true;
                                    break;
                                  } else {
                                    shopExist = false;
                                  }
                                }
                                if (shopExist) {
                                  Alert(
                                    context: context,
                                    type: AlertType.warning,
                                    title: "Warning",
                                    desc: "Shop already exists.",
                                    buttons: [
                                      DialogButton(
                                        child: Text(
                                          "Ok",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop();
                                        },
                                        width: 120,
                                      )
                                    ],
                                  ).show();
                                } else {
                                  _sendToServer();
                                }
                              }
                            },
                            child: Text(
                              'CONFIRM',
                              style: TextStyle(
                                fontFamily: 'Exo2',
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _sendToServer() async {
    if (this.mounted)
      setState(() {
        showSpinner = true;
        textEdit = false;
      });
    try {
      await _firestore.collection('shops').doc().set({
        'location': location,
        'shop_name': shopName,
        'status': 'enable',
        'tel_number': telephone,
        'rep_id': loggedInUser1!.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'last_visit': "null",
      });
      if (this.mounted)
        setState(() {
          showSpinner = false;
          textEdit = true;
        });
      Alert(
        context: context,
        type: AlertType.success,
        title: "Successful",
        desc: "Shop added successfuly",
        buttons: [
          DialogButton(
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.pop(context);
            },
            width: 120,
          )
        ],
      ).show();
    } catch (e) {
      if (this.mounted)
        setState(() {
          showSpinner = false;
          textEdit = true;
        });
      ExceptionManagement.registerExceptions(
        context: context,
        error: e.toString(),
      );
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
