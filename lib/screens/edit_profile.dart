import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/components/exception_manage.dart';
import 'package:dk_brothers/components/profile_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

User? loggedInUser1;

// ignore: must_be_immutable
class EditProfilePage extends StatefulWidget {
  static String id = 'edit_profile';
  var repID;
  var name;
  var email;
  var telNumber;
  var imgURL;
  var repRole;

  EditProfilePage(
    this.repID,
    this.name,
    this.email,
    this.telNumber,
    this.imgURL,
    this.repRole,
  );
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late StreamSubscription subscription;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;
  GlobalKey<FormState> _key = GlobalKey();
  String name = '';
  String mobile = '';
  File? image;
  bool showSpinner = false;

  void initState() {
    super.initState();
    subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      checkConnection(hasInternet, context);
    });
    loggedInUser1 = FirebaseAuth.instance.currentUser;
    name = widget.name;
    mobile = widget.telNumber;
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
      extendBodyBehindAppBar: true,
      appBar: appBarComponenet(mediaData, 'Edit Profile'),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Container(
          height: mediaData.size.height,
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
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: mediaData.size.height * 0.01,
              ),
              image == null
                  ? ProfileWidget(
                      imagePath: widget.imgURL,
                      isEdit: true,
                      onClicked: () async {
                        var selectedImage = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        setState(() {
                          if (selectedImage != null) {
                            image = File(selectedImage.path);
                          }
                        });
                      },
                    )
                  : ProfileWidget2(
                      image: image!,
                      isEdit: true,
                      onClicked: () async {
                        var selectedImage = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        setState(() {
                          if (selectedImage != null) {
                            image = File(selectedImage.path);
                          }
                        });
                      },
                    ),
              SizedBox(
                height: mediaData.size.height * 0.01,
              ),
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
                padding: EdgeInsets.only(
                    left: mediaData.size.width * 0.04,
                    right: mediaData.size.width * 0.04,
                    top: mediaData.size.height * 0.1),
                child: Column(
                  children: [
                    Form(
                      key: _key,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Full Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: mediaData.size.height * 0.025,
                                fontFamily: 'Exo2',
                                color: Color(0xFF158E85),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: mediaData.size.height * 0.005,
                          ),
                          TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Name is required";
                              } else if (value.length < 3) {
                                return "Name should have at least 3 characters.";
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {
                              if (this.mounted)
                                setState(() {
                                  name = value;
                                });
                            },
                            keyboardType: TextInputType.name,
                            maxLength: 24,
                            style: TextStyle(
                              fontFamily: 'Exo2',
                              fontSize: 18.0,
                              color: Color(0xFF158E85),
                            ),
                            initialValue: widget.name,
                            maxLines: 1,
                            decoration: InputDecoration(
                              counterText: "",
                              suffixIcon: Icon(
                                FontAwesomeIcons.userAlt,
                                color: Color(0xFF158E85),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          SizedBox(
                            height: mediaData.size.height * 0.025,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Mobile Number',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: mediaData.size.height * 0.025,
                                fontFamily: 'Exo2',
                                color: Color(0xFF158E85),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: mediaData.size.height * 0.005,
                          ),
                          TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
                            onChanged: (value) {
                              if (this.mounted)
                                setState(() {
                                  mobile = value;
                                });
                            },
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: TextStyle(
                              fontFamily: 'Exo2',
                              fontSize: 18.0,
                              color: Color(0xFF158E85),
                            ),
                            initialValue: widget.telNumber,
                            maxLines: 1,
                            decoration: InputDecoration(
                              counterText: "",
                              suffixIcon: Icon(
                                Icons.phone,
                                color: Color(0xFF158E85),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: mediaData.size.height * 0.025,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(5.0),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            (EdgeInsets.all(15.0))),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Color(0xFF158E85)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
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
                      height: mediaData.size.height * 0.025,
                    ),
                    if (widget.repRole != 'admin')
                      GestureDetector(
                        onTap: () {
                          _auth.sendPasswordResetEmail(email: widget.email);
                          Alert(
                            context: context,
                            type: AlertType.success,
                            title: "Successful",
                            desc:
                                "A password reset link has been sent to your email.",
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
                                width: 120,
                              )
                            ],
                          ).show();
                        },
                        child: Text(
                          'Reset Password',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: mediaData.size.height * 0.025,
                            fontFamily: 'Exo2',
                            color: Color(0xFF158E85),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _sendToServer() async {
    if (this.mounted)
      setState(() {
        showSpinner = true;
      });
    var downloadURL = 'null';
    try {
      if (image != null) {
        if (widget.imgURL != 'null') {
          await _storage.refFromURL(widget.imgURL).delete();
          var imgSnap = await _storage
              .ref()
              .child('user_images/' + widget.repID)
              .putFile(image!);
          downloadURL = await imgSnap.ref.getDownloadURL();
        } else {
          var imgSnap = await _storage
              .ref()
              .child('user_images/' + widget.repID)
              .putFile(image!);
          downloadURL = await imgSnap.ref.getDownloadURL();
        }
      } else {
        downloadURL = widget.imgURL;
      }
      await _firestore.collection('users').doc(widget.repID).update({
        'name': name,
        'img_url':
            image == null && widget.imgURL == 'null' ? 'null' : downloadURL,
        'mobile_num': mobile,
      });
      Alert(
        context: context,
        type: AlertType.success,
        title: "Successful",
        desc: "User details updated successfuly",
        buttons: [
          DialogButton(
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              int count = 0;
              Navigator.of(context).popUntil((_) => count++ >= 1);
              Navigator.of(context, rootNavigator: true).pop();
            },
            width: 120,
          )
        ],
      ).show();
      if (this.mounted)
        setState(() {
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
}
