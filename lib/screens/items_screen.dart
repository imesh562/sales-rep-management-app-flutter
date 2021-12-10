import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/components/exception_manage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'item_profile.dart';

User? loggedInUser;
final _firestore = FirebaseFirestore.instance;
var userRole;

class ItemsList extends StatefulWidget {
  static String id = 'itemsList';
  @override
  _ItemsListState createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
  bool showSpinner = false;
  late StreamSubscription subscription;
  GlobalKey<FormState> _key = GlobalKey();

  ScrollController controller = ScrollController();
  String searchText = "";

  int orderBy = 1;
  var orderByText = 'Name';

  late String name;
  // ignore: non_constant_identifier_names
  late String english_name;
  late double price;

  @override
  void initState() {
    super.initState();
    loggedInUser = FirebaseAuth.instance.currentUser;
    subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      checkConnection(hasInternet, context);
    });
    getUserRole();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
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
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: appBarComponenet(mediaData, 'Items List'),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.only(left: 14.0),
                    width: mediaData.size.width * 0.7,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Search',
                        labelStyle: loginCredentials,
                        prefixIcon: Icon(
                          FontAwesomeIcons.search,
                          color: Color(0xFF9A57B4),
                        ),
                        errorStyle: TextStyle(fontSize: 12, height: 0.3),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF9A57B4)),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF9A57B4)),
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
                          child: Text("Disabled"),
                          value: 3,
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
                        } else {
                          if (this.mounted)
                            setState(() {
                              orderBy = 3;
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
      floatingActionButton: (userRole.toString() == 'admin')
          ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFA562BF),
                    offset: Offset.zero,
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                elevation: 10.0,
                tooltip: 'Add',
                child: Icon(
                  Icons.add,
                  color: Color(0xFF9A57B4),
                ),
                onPressed: () {
                  Alert(
                      context: context,
                      title: "Add New Item",
                      content: Form(
                        key: _key,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Name',
                              ),
                              onChanged: (value) {
                                if (this.mounted)
                                  setState(() {
                                    name = value;
                                  });
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                                labelText: 'English Name (Bill Name)',
                              ),
                              onChanged: (value) {
                                if (this.mounted)
                                  setState(() {
                                    english_name = value;
                                  });
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                bool englishValid = RegExp(
                                        r'^(?:[a-zA-Z]|\P{L})+$',
                                        unicode: true)
                                    .hasMatch(value!);
                                if (value.isEmpty) {
                                  return "Name is required";
                                } else if (value.length < 2) {
                                  return "Name should have at least 2 characters.";
                                } else if (!englishValid) {
                                  return "Please enter in English Characters";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Price',
                              ),
                              onChanged: (value) {
                                final number = num.tryParse(value);
                                if (number != null) {
                                  if (this.mounted)
                                    setState(() {
                                      price = double.parse(value);
                                    });
                                }
                              },
                              keyboardType: TextInputType.number,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                final number = num.tryParse(value!);
                                if (value.isEmpty) {
                                  return "Price is required";
                                } else if (number == null) {
                                  return "Enter a valid price";
                                } else if (double.parse(value) == 0) {
                                  return "Enter a valid price";
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
                          onPressed: () async {
                            bool validation = false;
                            // ignore: unnecessary_null_comparison
                            if (_key.currentState!.validate() != null) {
                              validation = _key.currentState!.validate();
                            }
                            if (validation) {
                              String items = '';
                              QuerySnapshot querySnapshot = await _firestore
                                  .collection('items')
                                  .where('name', isGreaterThanOrEqualTo: name)
                                  .where('name', isLessThan: name + 'z')
                                  .orderBy('name', descending: true)
                                  .get();
                              var list = querySnapshot.docs;
                              if (list.isNotEmpty) {
                                list.forEach((element) {
                                  items += element['name'] +
                                      ' Rs.' +
                                      element['price'].toString() +
                                      '\n';
                                });
                              }
                              if (items == '') {
                                // ignore: unnecessary_statements
                                _sendToServer('false');
                              } else {
                                Alert(
                                  context: context,
                                  type: AlertType.warning,
                                  title: "Warning",
                                  desc: "Following Items Have Similar Names\n" +
                                      items +
                                      "Do you still want to edit this item?",
                                  style: AlertStyle(
                                      descStyle: TextStyle(
                                          fontSize:
                                              mediaData.size.height * 0.02)),
                                  buttons: [
                                    DialogButton(
                                      child: Text(
                                        "Yes",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      onPressed: () {
                                        // ignore: unnecessary_statements
                                        _sendToServer('true');
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
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                      },
                                      width: 120,
                                    )
                                  ],
                                ).show();
                              }
                            }
                          },
                          child: Text(
                            "Submit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        )
                      ]).show();
                },
              ),
            )
          : null,
    );
  }

  _sendToServer(String check) async {
    if (this.mounted)
      setState(() {
        showSpinner = true;
      });
    try {
      await _firestore.collection('items').doc().set({
        'name': name,
        'english_name': english_name,
        'price': price,
        'status': 'enable',
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (this.mounted)
        setState(() {
          showSpinner = false;
        });
      Navigator.of(context, rootNavigator: true).pop();
      Alert(
        context: context,
        type: AlertType.success,
        title: "Successful",
        desc: "Item added successfuly",
        buttons: [
          DialogButton(
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              if (check == 'true') {
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.of(context, rootNavigator: true).pop();
              } else {
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
            width: 120,
          )
        ],
      ).show();
    } catch (e) {
      if (this.mounted)
        setState(() {
          showSpinner = false;
        });
      ExceptionManagement.registerExceptions(
        context: context,
        error: e.toString(),
      );
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

Stream<QuerySnapshot> searchData(String string, String orderByText) async* {
  var _search = _firestore
      .collection('items')
      .where('name', isGreaterThanOrEqualTo: string)
      .where('name', isLessThan: string + 'z')
      .orderBy('name', descending: true)
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
                  .collection('items')
                  .orderBy('name', descending: true)
                  .snapshots()
              : orderByText == 'Date'
                  ? _firestore
                      .collection('items')
                      .orderBy('timestamp', descending: false)
                      .snapshots()
                  : _firestore
                      .collection('items')
                      .orderBy('status', descending: true)
                      .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final items = snapshot.data!.docs.reversed;
        List<Widget> repList = [];
        for (var item in items) {
          final itemName = item['name'];
          final itemEnglishName = item['english_name'];
          final itemPrice = item['price'];
          final itemStatus = item['status'];
          final itemID = item.reference.id;

          repList.add(repListBuilder(itemName, itemPrice.toString(), mediaData,
              context, itemStatus, itemID, itemEnglishName.toString()));
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

Widget repListBuilder(String name, String price, MediaQueryData mediaData,
    BuildContext context, String status, String itemID, String englishName) {
  GlobalKey<FormState> _key1 = GlobalKey();
  var _keyName = TextEditingController();
  var _keyEnglishName = TextEditingController();
  var _keyPrice = TextEditingController();

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
    menuOffset: 10.0, // Offset value to show menuItem from the selected item
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
              name: ItemProfile.id,
            ),
            screen: ItemProfile(
              name,
              price,
              status,
              itemID,
            ),
            withNavBar: true,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
      ),
      if (userRole.toString() == 'admin')
        status == 'enable'
            ? FocusedMenuItem(
                title: Text("Disable Item"),
                trailingIcon: Icon(
                  Icons.pause_circle,
                  color: Colors.red,
                ),
                onPressed: () async {
                  await _firestore
                      .collection("items")
                      .doc(itemID)
                      .update({'status': 'disable'});
                },
              )
            : FocusedMenuItem(
                title: Text("Enable Item"),
                trailingIcon: Icon(
                  Icons.play_circle,
                  color: Colors.lightGreen,
                ),
                onPressed: () async {
                  await _firestore
                      .collection("items")
                      .doc(itemID)
                      .update({'status': 'enable'});
                },
              ),
      if (userRole.toString() == 'admin')
        FocusedMenuItem(
          title: Text("Edit"),
          trailingIcon: Icon(Icons.edit),
          onPressed: () {
            _keyName.text = name;
            _keyEnglishName.text = englishName;
            _keyPrice.text = price;
            Alert(
                context: context,
                title: "Update Item",
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
                          labelText: 'English Name (Bill Name)',
                        ),
                        controller: _keyEnglishName,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          bool englishValid =
                              RegExp(r'^(?:[a-zA-Z]|\P{L})+$', unicode: true)
                                  .hasMatch(value!);
                          if (value.isEmpty) {
                            return "Name is required";
                          } else if (value.length < 2) {
                            return "Name should have at least 2 characters.";
                          } else if (!englishValid) {
                            return "Please enter in English Characters";
                          } else {
                            return null;
                          }
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price',
                        ),
                        controller: _keyPrice,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          final number = num.tryParse(value!);
                          if (value.isEmpty) {
                            return "Price is required";
                          } else if (number == null) {
                            return "Enter a valid price";
                          } else if (double.parse(value) == 0) {
                            return "Enter a valid price";
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
                    onPressed: () async {
                      bool validation = false;
                      // ignore: unnecessary_null_comparison
                      if (_key1.currentState!.validate() != null) {
                        validation = _key1.currentState!.validate();
                      }
                      if (validation) {
                        String items = '';
                        QuerySnapshot querySnapshot = await _firestore
                            .collection('items')
                            .where('name',
                                isGreaterThanOrEqualTo: _keyName.text)
                            .where('name', isLessThan: _keyName.text + 'z')
                            .orderBy('name', descending: true)
                            .get();
                        var list = querySnapshot.docs;
                        if (list.isNotEmpty) {
                          list.forEach((element) {
                            if (element.reference.id != itemID) {
                              items += element['name'] +
                                  ' Rs.' +
                                  element['price'].toString() +
                                  '\n';
                            }
                          });
                        }
                        if (items == '') {
                          _updateData(_keyName.text, (_keyPrice.text), context,
                              itemID, _keyEnglishName.text);
                        } else {
                          Alert(
                            context: context,
                            type: AlertType.warning,
                            title: "Warning",
                            desc: "Following Items Have Similar Names\n" +
                                items +
                                "Do you still want to edit this item?",
                            style: AlertStyle(
                                descStyle: TextStyle(
                                    fontSize: mediaData.size.height * 0.02)),
                            buttons: [
                              DialogButton(
                                child: Text(
                                  "Yes",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                onPressed: () {
                                  _updateData(_keyName.text, (_keyPrice.text),
                                      context, itemID, _keyEnglishName.text);
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
                                width: 120,
                              )
                            ],
                          ).show();
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
            image: AssetImage('assets/images/cupcake1.jpg'),
            alignment: Alignment.topRight,
            fit: BoxFit.fitHeight,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.2), BlendMode.dstATop),
          )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 14.0),
            child: Row(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: mediaData.size.height * 0.028,
                    fontFamily: 'Exo2',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                status == 'enable'
                    ? Icon(
                        Icons.play_circle,
                        color: Color(0xFF9A57B4),
                      )
                    : Icon(
                        Icons.pause_circle,
                        color: Colors.red,
                      ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2.0, left: 14.0),
            child: Text(
              'Rs.$price',
              style: TextStyle(
                fontSize: mediaData.size.height * 0.025,
                fontFamily: 'Exo2',
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

_updateData(String keyName, String keyPrice, BuildContext context,
    String itemID, String englishName) async {
  try {
    await _firestore.collection('items').doc(itemID).update({
      'name': keyName,
      'price': double.parse(keyPrice),
      'english_name': englishName,
    });
    Navigator.of(context, rootNavigator: true).pop();
    Alert(
      context: context,
      type: AlertType.success,
      title: "Successful",
      desc: "Item updated successfully",
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
