import 'dart:io';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/components/exception_manage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'bottom_nav.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return WillPopScope(
      onWillPop: () {
        exit(0);
      },
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Container(
            decoration: loginBackground(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Image.asset(
                      'assets/images/log_img2.png',
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: 20.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(10.0),
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(
                        right: mediaData.size.height * 0.018,
                        left: mediaData.size.height * 0.018,
                        bottom: mediaData.size.height * 0.018,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(mediaData.size.height * 0.013),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'LOGIN',
                              style: loginBold,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              'Enter your username and password.',
                              style: loginLight,
                            ),
                            SizedBox(height: 10.0),
                            SizedBox(
                              height: 60.0,
                              child: TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  email = value;
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
                                decoration: kLoginFields.copyWith(
                                  labelText: 'E-mail',
                                  labelStyle: TextStyle(
                                    fontFamily: 'Exo2',
                                  ),
                                  suffixIcon: Icon(
                                    FontAwesomeIcons.solidEnvelope,
                                    color: Color(0xFF5B9FDE),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            SizedBox(
                              height: 50.0,
                              child: TextField(
                                obscureText: true,
                                onChanged: (value) {
                                  password = value;
                                },
                                maxLength: 16,
                                decoration: kLoginFields.copyWith(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(
                                    fontFamily: 'Exo2',
                                  ),
                                  suffixIcon: Icon(
                                    FontAwesomeIcons.userLock,
                                    color: Color(0xFF5B9FDE),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(5.0),
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    (EdgeInsets.all(15.0))),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Color(0xFF5B9FDE)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                      color: Color(0xFF5B9FDE),
                                    ),
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                if (this.mounted)
                                  setState(() {
                                    showSpinner = true;
                                  });
                                try {
                                  final UserCredential? existingUser =
                                      await _auth.signInWithEmailAndPassword(
                                          email: email, password: password);
                                  if (existingUser != null) {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, BottomNavBar.id, (r) => false);
                                  } else {
                                    if (this.mounted)
                                      setState(() {
                                        showSpinner = false;
                                      });
                                  }
                                } catch (e) {
                                  if (this.mounted)
                                    setState(() {
                                      email = "";
                                      password = "";
                                      showSpinner = false;
                                    });
                                  String error = e.toString();
                                  ExceptionManagement.loginExceptions(
                                      context: context, error: error);
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
