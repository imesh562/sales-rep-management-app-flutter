import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/components/exception_manage.dart';
import 'package:dk_brothers/screens/shop_profile.dart';
import 'package:dk_brothers/screens/shop_register.dart';
import 'package:dk_brothers/screens/view_qr.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

User? loggedInUser;
final _firestore = FirebaseFirestore.instance;
var userRole = "";

class Shops extends StatefulWidget {
  static String id = 'shops';
  @override
  _ShopsState createState() => _ShopsState();
}

class _ShopsState extends State<Shops> {
  bool showSpinnerDash = false;
  late StreamSubscription subscription;
  bool showSpinner = false;

  ScrollController controller = ScrollController();
  String searchText = "";
  bool closeTopContainers = false;
  int orderBy = 1;
  var orderByText = 'Name';

  @override
  void initState() {
    super.initState();
    loggedInUser = FirebaseAuth.instance.currentUser;
    subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      checkConnection(hasInternet, context);
    });
    controller.addListener(() {
      if (this.mounted)
        setState(() {
          closeTopContainers = controller.offset > 10;
        });
    });
    getUserRole();
  }

  getUserRole() async {
    if (this.mounted)
      setState(() {
        showSpinner = true;
      });
    await _firestore
        .collection("users")
        .doc(loggedInUser!.uid)
        .get()
        .then((result) {
      var role = result.get('role');
      if (this.mounted)
        setState(() {
          userRole = role;
          showSpinner = false;
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
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: appBarComponenet(mediaData, 'Shops'),
      body: ModalProgressHUD(
        inAsyncCall: showSpinnerDash,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: mediaData.size.width * 0.03,
                bottom: mediaData.size.width * 0.025,
                left: mediaData.size.width * 0.025,
                right: mediaData.size.width * 0.025,
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: closeTopContainers ? 0 : 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: mediaData.size.width,
                  alignment: Alignment.topCenter,
                  height: closeTopContainers ? 0 : mediaData.size.height * 0.35,
                  child: Stack(
                    children: [
                      ClipPath(
                        clipper: ClipperCustom(),
                        child: Container(
                          width: mediaData.size.width * 0.95,
                          height: mediaData.size.height * 0.35,
                          decoration: topCardsBG1('assets/images/topBG1.jpg'),
                          child: Image.asset(
                            'assets/images/shop.png',
                            alignment: Alignment.topLeft,
                          ),
                        ),
                      ),
                      ClipPath(
                        clipper: ClipperCustom2(),
                        child: GestureDetector(
                          onTap: () {
                            pushNewScreenWithRouteSettings(
                              context,
                              settings: RouteSettings(
                                name: ShopRegister.id,
                              ),
                              screen: ShopRegister(),
                              withNavBar: true,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          child: Container(
                            width: mediaData.size.width * 0.95,
                            height: mediaData.size.height * 0.35,
                            decoration: topCardsBG1('assets/images/topBG1.jpg'),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 30.0, bottom: 15),
                                child: Hero(
                                  tag: 'addShop',
                                  child: Icon(
                                    Icons.add_business,
                                    size: mediaData.size.width * 0.1,
                                    color: Color(0xFF076869),
                                  ),
                                ),
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
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.only(
                      left: mediaData.size.width * 0.03,
                    ),
                    width: mediaData.size.width * 0.7,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Search',
                        labelStyle: loginCredentials,
                        prefixIcon: Icon(
                          FontAwesomeIcons.search,
                          color: Color(0xFF04DBDD),
                        ),
                        errorStyle: TextStyle(fontSize: 12, height: 0.3),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF04DBDD)),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF04DBDD)),
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
                  padding: EdgeInsets.all(20.0),
                  child: DropdownButton(
                      value: orderBy,
                      autofocus: true,
                      items: [
                        DropdownMenuItem(
                          child: Text("Name"),
                          value: 1,
                        ),
                        DropdownMenuItem(
                          child: Text("Date"),
                          value: 2,
                        ),
                        DropdownMenuItem(
                          child: Text("Location"),
                          value: 3,
                        ),
                        DropdownMenuItem(
                          child: Text("Removed"),
                          value: 4,
                        ),
                      ],
                      onChanged: (value) {
                        if (value == 1) {
                          if (this.mounted)
                            setState(() {
                              orderBy = 1;
                              orderByText = 'Name';
                            });
                        } else if (value == 2) {
                          if (this.mounted)
                            setState(() {
                              orderBy = 2;
                              orderByText = 'Date';
                            });
                        } else if (value == 3) {
                          if (this.mounted)
                            setState(() {
                              orderBy = 3;
                              orderByText = 'Location';
                            });
                        } else {
                          if (this.mounted)
                            setState(() {
                              orderBy = 4;
                              orderByText = 'Removed';
                            });
                        }
                      }),
                ),
              ],
            ),
            RepsStream(controller, searchText, orderByText),
            SizedBox(
              height: mediaData.size.height * 0.015,
            ),
          ],
        ),
      ),
    );
  }
}

Stream<QuerySnapshot> searchData(String string, String orderByText) async* {
  var _search = _firestore
      .collection('shops')
      .where('shop_name', isGreaterThanOrEqualTo: string)
      .where('shop_name', isLessThan: string + 'z')
      .orderBy('shop_name', descending: true)
      .snapshots();
  yield* _search;
}

// ignore: must_be_immutable
class RepsStream extends StatelessWidget {
  var controller;
  String searchText;
  String orderByText;
  RepsStream(this.controller, this.searchText, this.orderByText);
  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return StreamBuilder<QuerySnapshot>(
      // ignore: unnecessary_null_comparison
      stream: (searchText != "")
          ? searchData(searchText, orderByText)
          : orderByText == 'Name'
              ? _firestore
                  .collection('shops')
                  .orderBy('shop_name', descending: true)
                  .snapshots()
              : orderByText == 'Date'
                  ? _firestore
                      .collection('shops')
                      .orderBy('timestamp', descending: false)
                      .snapshots()
                  : orderByText == 'Location'
                      ? _firestore
                          .collection('shops')
                          .orderBy('location', descending: true)
                          .snapshots()
                      : _firestore
                          .collection('shops')
                          .orderBy('status', descending: true)
                          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Column(
              children: [
                Text(
                  'No Data',
                  style: krepReg.copyWith(color: Colors.black),
                ),
                SizedBox(
                  height: 20.0,
                ),
                CircularProgressIndicator(
                  backgroundColor: Colors.lightBlueAccent,
                ),
              ],
            ),
          );
        }
        final reps = snapshot.data!.docs.reversed;
        List<Widget> repList = [];
        for (var rep in reps) {
          final shopLocation = rep['location'];
          final shopName = rep['shop_name'];
          final shopTel = rep['tel_number'];
          final repID = rep['rep_id'];
          final shopStatus = rep['status'];
          final lastVisit = rep['last_visit'];
          final shopID = rep.reference.id;

          repList.add(repListBuilder(
            shopLocation,
            shopName,
            shopTel,
            mediaData,
            context,
            shopID,
            shopStatus,
            reps,
            repID,
            lastVisit,
          ));
        }
        return Expanded(
          child: Container(
            child: ListView.builder(
              controller: controller,
              itemCount: repList.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Align(
                  heightFactor: 0.8,
                  alignment: Alignment.topCenter,
                  child: repList[index],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

Widget repListBuilder(
  String location,
  String name,
  String telNumber,
  MediaQueryData mediaData,
  BuildContext context,
  String shopID,
  shopStatus,
  Iterable<QueryDocumentSnapshot<Object?>> reps,
  repID,
  String lastVisit,
) {
  int balance = 0;

  GlobalKey<FormState> _key1 = GlobalKey();
  var _keyName = TextEditingController();
  var _keyLocation = TextEditingController();
  var _keyNumber = TextEditingController();
  bool shopExist = false;
  var now = DateTime.now();
  var today = DateTime(now.year, now.month, now.day);

  return FocusedMenuHolder(
    openWithTap: true,
    menuWidth: MediaQuery.of(context).size.width * 0.50,
    blurSize: 5.0,
    menuItemExtent: 45,
    menuBoxDecoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(15.0))),
    duration: Duration(milliseconds: 100),
    animateMenuItems: true,
    blurBackgroundColor: Colors.black54,
    menuOffset: 5.0, // Offset value to show menuItem from the selected item
    bottomOffsetHeight: mediaData.size.height *
        0.1, // Offset height to consider, for showing the menu item ( for example bottom navigation bar), so that the popup menu will be shown on top of selected item.
    menuItems: <FocusedMenuItem>[
      FocusedMenuItem(
        title: Text("View Analysis"),
        trailingIcon: Icon(Icons.bar_chart),
        onPressed: () {
          pushNewScreenWithRouteSettings(
            context,
            settings: RouteSettings(
              name: ShopProfile.id,
            ),
            screen: ShopProfile(
              location,
              name,
              telNumber,
              shopID,
              shopStatus,
            ),
            withNavBar: true,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
      ),
      if (userRole.toString() == 'admin')
        FocusedMenuItem(
          title: Text("View QR Code"),
          trailingIcon: Icon(Icons.qr_code),
          onPressed: () {
            pushNewScreenWithRouteSettings(
              context,
              settings: RouteSettings(
                name: ViewQR.id,
              ),
              screen: ViewQR(
                shopID: shopID,
                shopName: name,
                location: location,
              ),
              withNavBar: true,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
        ),
      FocusedMenuItem(
        title: Text("Call"),
        trailingIcon: Icon(Icons.call),
        onPressed: () {
          final Uri telLaunchUri = Uri(
            scheme: 'tel',
            path: telNumber,
          );
          launch(telLaunchUri.toString());
        },
      ),
      if ((loggedInUser!.uid.toString() == repID.toString()) ||
          userRole.toString() == 'admin')
        FocusedMenuItem(
          title: Text("Edit"),
          trailingIcon: Icon(Icons.edit),
          onPressed: () {
            _keyName.text = name;
            _keyLocation.text = location;
            _keyNumber.text = telNumber;
            Alert(
                context: context,
                title: "Update Shop Details",
                content: Form(
                  key: _key1,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Name',
                        ),
                        controller: _keyName,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Name is required";
                          } else if (value.length < 2) {
                            return "Name should have at least 2 characters.";
                          } else {
                            return null;
                          }
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Location',
                        ),
                        controller: _keyLocation,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Location is required";
                          } else if (value.length < 2) {
                            return "Location should have at least 2 characters.";
                          } else {
                            return null;
                          }
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Telephone',
                        ),
                        controller: _keyNumber,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                      ),
                    ],
                  ),
                ),
                buttons: [
                  DialogButton(
                    onPressed: () {
                      bool validation = false;
                      // ignore: unnecessary_null_comparison
                      if (_key1.currentState!.validate() != null) {
                        validation = _key1.currentState!.validate();
                      }
                      if (validation) {
                        for (var element in reps) {
                          if (element['shop_name'] == _keyName.text) {
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
                        } else {
                          _updateData(_keyName.text, _keyLocation.text,
                              _keyNumber.text, context, shopID);
                        }
                      }
                    },
                    child: Text(
                      "Submit",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ]).show();
          },
        ),
      if (balance == 0 && (loggedInUser!.uid.toString() == repID.toString()) ||
          userRole.toString() == 'admin')
        if (shopStatus == 'enable')
          FocusedMenuItem(
            title: Text("Remove"),
            trailingIcon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () async {
              Alert(
                context: context,
                type: AlertType.warning,
                title: "Remove",
                desc: "Are you sure you want to remove this shop?",
                buttons: [
                  DialogButton(
                    child: Text(
                      "Yes",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () async {
                      await _firestore
                          .collection("shops")
                          .doc(shopID)
                          .update({'status': 'disable'});
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    color: Colors.deepOrange,
                  ),
                  DialogButton(
                    child: Text(
                      "No",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    color: Color(0xFF5B9FDE),
                  )
                ],
              ).show();
            },
          ),
      if (shopStatus == 'disable')
        FocusedMenuItem(
          title: Text("Add"),
          trailingIcon: Icon(
            Icons.add,
            color: Colors.green,
          ),
          onPressed: () async {
            Alert(
              context: context,
              type: AlertType.warning,
              title: "Add",
              desc: "Are you sure you want to add this shop?",
              buttons: [
                DialogButton(
                  child: Text(
                    "Yes",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () async {
                    await _firestore
                        .collection("shops")
                        .doc(shopID)
                        .update({'status': 'enable'});
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  color: Colors.deepOrange,
                ),
                DialogButton(
                  child: Text(
                    "No",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  color: Color(0xFF5B9FDE),
                )
              ],
            ).show();
          },
        ),
    ],
    onPressed: () {},
    child: Container(
      margin: EdgeInsets.only(top: 10.0),
      width: mediaData.size.width * 0.95,
      height: mediaData.size.height * 0.15,
      decoration: BoxDecoration(
        boxShadow: boxShadowsReps(),
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage('assets/images/store.png'),
          alignment: Alignment.topRight,
          colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.45), BlendMode.dstATop),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 14.0),
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: mediaData.size.height * 0.034,
                    fontFamily: 'Exo2',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              shopStatus == 'enable'
                  ? Icon(
                      Icons.play_circle,
                      color: Color(0xFF04DBDD),
                    )
                  : Icon(
                      Icons.pause_circle,
                      color: Colors.red,
                    ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2.0, left: 14.0),
            child: Text(
              location,
              style: TextStyle(
                fontSize: mediaData.size.height * 0.02,
                fontFamily: 'Exo2',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14.0),
            child: Text(
              telNumber,
              style: TextStyle(
                fontSize: mediaData.size.height * 0.02,
                fontFamily: 'Exo2',
              ),
            ),
          ),
          lastVisit == today.toString().substring(0, 10)
              ? Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: Text(
                    'Visited',
                    style: TextStyle(
                      fontSize: mediaData.size.height * 0.022,
                      fontFamily: 'Exo2',
                      color: Color(0xFF04DBDD),
                    ),
                  ),
                )
              : Text(''),
        ],
      ),
    ),
  );
}

_updateData(String keyName, String keyLocation, String keyNumber,
    BuildContext context, String shopID) async {
  try {
    await _firestore.collection('shops').doc(shopID).update({
      'shop_name': keyName,
      'location': keyLocation,
      'tel_number': keyNumber,
    });
    await _firestore
        .collection("orders")
        .where("shop_id", isEqualTo: shopID)
        .get()
        .then((value) {
      value.docs.forEach((result) async {
        await _firestore.collection('orders').doc(result.id).update({
          'shop_name': keyName,
        });
      });
    });
    Navigator.of(context, rootNavigator: true).pop();
    Alert(
      context: context,
      type: AlertType.success,
      title: "Successful",
      desc: "Shop updated successfully",
      buttons: [
        DialogButton(
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
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
