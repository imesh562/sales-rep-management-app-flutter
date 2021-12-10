import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/components/exception_manage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';

User? loggedInUser1;
User? loggedInUser2;

class RegisterRep extends StatefulWidget {
  static String id = 'rep_registert';

  @override
  _RegisterRepState createState() => _RegisterRepState();
}

class _RegisterRepState extends State<RegisterRep> {
  late StreamSubscription subscription;
  String name = "", email = "", mobile = "", password = "", confirmPass = "";
  GlobalKey<FormState> _key = GlobalKey();
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  bool textEdit = true;
  File? image;

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
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFFb8dbdb),
                    Color(0xFF85c1c1),
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
                          tag: 'addRep',
                          child: Icon(
                            Icons.person_add,
                            color: Color(0xFF158E85),
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
                      'Sales Representative',
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
                            height: 20.0,
                          ),
                          Text(
                            "Enter sales representative's data.",
                            textAlign: TextAlign.start,
                            style: loginLight.copyWith(
                                fontSize: mediaData.size.height * 0.025),
                          ),
                          SizedBox(height: 25.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 70.0,
                                width: mediaData.size.width * 0.675,
                                child: TextFormField(
                                  enabled: textEdit,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  keyboardType: TextInputType.name,
                                  onChanged: (value) {
                                    if (this.mounted)
                                      setState(() {
                                        name = value;
                                      });
                                  },
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Name is required";
                                    } else if (value.length < 3) {
                                      return "Name should have at least 3 characters.";
                                    } else {
                                      return null;
                                    }
                                  },
                                  maxLength: 24,
                                  decoration: kRegisterFields.copyWith(
                                    labelText: 'Full Name',
                                    labelStyle: TextStyle(
                                      fontFamily: 'Exo2',
                                      fontSize: 15.0,
                                      color: Color(0xFF158E85),
                                    ),
                                    suffixIcon: Icon(
                                      FontAwesomeIcons.userAlt,
                                      color: Color(0xFF158E85),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: mediaData.size.width * 0.025,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  var selectedImage = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  setState(() {
                                    if (selectedImage != null) {
                                      image = File(selectedImage.path);
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: mediaData.size.height * 0.025,
                                  ),
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: mediaData.size.height * 0.05,
                                    color: Color(0xFF158E85),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 70.0,
                            width: mediaData.size.width * 0.8,
                            child: TextFormField(
                              enabled: textEdit,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) {
                                if (this.mounted)
                                  setState(() {
                                    email = value;
                                  });
                              },
                              validator: (value) {
                                bool emailValid = RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value!);
                                if (value.isEmpty) {
                                  return "Email is required";
                                } else if (!emailValid) {
                                  return "Please enter a valid email address.";
                                } else {
                                  return null;
                                }
                              },
                              maxLength: 254,
                              decoration: kRegisterFields.copyWith(
                                labelText: 'E-mail',
                                labelStyle: TextStyle(
                                  fontFamily: 'Exo2',
                                  color: Color(0xFF158E85),
                                ),
                                suffixIcon: Icon(
                                  FontAwesomeIcons.solidEnvelope,
                                  color: Color(0xFF158E85),
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
                                    mobile = value;
                                  });
                              },
                              validator: (value) {
                                bool mobileValid =
                                    RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)')
                                        .hasMatch(value!);
                                if (value.isEmpty) {
                                  return "Mobile Number is required";
                                } else if (!mobileValid) {
                                  return "Please enter a valid mobile number";
                                } else {
                                  return null;
                                }
                              },
                              maxLength: 10,
                              decoration: kRegisterFields.copyWith(
                                labelText: 'Mobile Number',
                                labelStyle: TextStyle(
                                  fontFamily: 'Exo2',
                                  color: Color(0xFF158E85),
                                ),
                                suffixIcon: Icon(
                                  FontAwesomeIcons.phone,
                                  color: Color(0xFF158E85),
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
                              obscureText: true,
                              onChanged: (value) {
                                if (this.mounted)
                                  setState(() {
                                    password = value;
                                  });
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please type a password.";
                                } else if (value.length < 6) {
                                  return "Password should contain atleast 6 characters";
                                } else {
                                  return null;
                                }
                              },
                              maxLength: 16,
                              decoration: kRegisterFields.copyWith(
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  fontFamily: 'Exo2',
                                  color: Color(0xFF158E85),
                                ),
                                suffixIcon: Icon(
                                  FontAwesomeIcons.userLock,
                                  color: Color(0xFF158E85),
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
                              obscureText: true,
                              onChanged: (value) {
                                if (this.mounted)
                                  setState(() {
                                    confirmPass = value;
                                  });
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please retype the password.";
                                } else if (value != password) {
                                  return "Passwords do not match.";
                                } else {
                                  return null;
                                }
                              },
                              maxLength: 16,
                              decoration: kRegisterFields.copyWith(
                                labelText: 'Confirm Password',
                                labelStyle: TextStyle(
                                  fontFamily: 'Exo2',
                                  color: Color(0xFF158E85),
                                ),
                                suffixIcon: Icon(
                                  FontAwesomeIcons.userLock,
                                  color: Color(0xFF158E85),
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
                                  Color(0xFF158E85)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(
                                    color: Color(0xFF158E85),
                                  ),
                                ),
                              ),
                            ),
                            onPressed: () {
                              bool validation = false;
                              // ignore: unnecessary_null_comparison
                              if (_key.currentState!.validate() != null) {
                                validation = _key.currentState!.validate();
                              }
                              // ignore: unnecessary_statements
                              validation ? _sendToServer() : null;
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
                          SizedBox(
                            height: mediaData.size.height * 0.1,
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
    var downloadURL = 'null';
    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      loggedInUser2 = FirebaseAuth.instance.currentUser;
      if (image != null) {
        var imgSnap = await _storage
            .ref()
            .child('user_images/' + loggedInUser2!.uid)
            .putFile(image!);
        downloadURL = await imgSnap.ref.getDownloadURL();
      }
      // ignore: unnecessary_null_comparison
      if (newUser != null) {
        await _firestore.collection('users').doc(loggedInUser2!.uid).set({
          'img_url': downloadURL,
          'email': email,
          'mobile_num': mobile,
          'name': name,
          'role': 'rep',
          'status': 'enable',
          'last_assign': 'null',
          'timestamp': FieldValue.serverTimestamp(),
        });
        _auth.signOut();
        final currentUser =
            await _firestore.collection('users').doc(loggedInUser1!.uid).get();
        final currentUserEmail = currentUser['email'];
        final currentUserPW = currentUser['pw'];
        // ignore: unused_local_variable
        final UserCredential? existingUser =
            await _auth.signInWithEmailAndPassword(
          email: currentUserEmail,
          password: currentUserPW,
        );
        Navigator.pop(context);
      }
      if (this.mounted)
        setState(() {
          showSpinner = false;
          textEdit = true;
        });
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
    }
  }
}
