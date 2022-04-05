import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

final _firestore = FirebaseFirestore.instance;

// ignore: must_be_immutable
class AssignItems extends StatefulWidget {
  static String id = 'assign_items';
  var userRoleDash;
  var repID;

  AssignItems(this.userRoleDash, this.repID);

  @override
  _AssignItemsState createState() => _AssignItemsState();
}

class _AssignItemsState extends State<AssignItems> {
  String searchText = "";

  ScrollController controller = ScrollController();
  int orderBy = 1;
  var orderByText = 'Name';
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: appBarComponenet(mediaData, 'Assign Items'),
        body: Column(
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
                                : Color(0xFF7a459d),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: widget.userRoleDash.toString() == 'admin'
                                ? Color(0xFF7a459d)
                                : Color(0xFF7a459d),
                          ),
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
                      ],
                      onChanged: (value) {
                        if (value == 1) {
                          if (this.mounted)
                            setState(() {
                              orderBy = 1;
                              orderByText = 'Name';
                            });
                        } else {
                          if (this.mounted)
                            setState(() {
                              orderBy = 2;
                              orderByText = 'Date';
                            });
                        }
                      }),
                ),
              ],
            ),
            RepsStream(
                controller, searchText, orderByText, widget.userRoleDash),
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[200],
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFA562BF),
                      offset: Offset.zero,
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                // color: Colors.grey[200],
                padding: EdgeInsets.all(mediaData.size.height * 0.02),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () async {
                          if (this.mounted)
                            setState(() {
                              showSpinner = true;
                            });
                          Map itemList = RepsStreamState.quantityMap;
                          itemList.removeWhere((key, value) => value == 0);
                          if (itemList.isNotEmpty) {
                            DateTime now = DateTime.now();
                            DateTime today =
                                DateTime(now.year, now.month, now.day);
                            itemList.forEach((k, v) async {
                              await _firestore
                                  .collection('daily_items')
                                  .doc()
                                  .set({
                                'rep_id': widget.repID,
                                'date': today.toString().substring(0, 10),
                                'item_id': k,
                                'quantity': itemList[k],
                              });
                            });
                            await _firestore
                                .collection('users')
                                .doc(
                                  widget.repID,
                                )
                                .update({
                              'last_assign': today.toString().substring(0, 10),
                            });
                            Alert(
                              context: context,
                              type: AlertType.success,
                              title: "Successful",
                              desc: "Items assigned successfuly",
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "Ok",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () {
                                    int count = 0;
                                    Navigator.of(context)
                                        .popUntil((_) => count++ >= 1);
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
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
                              desc:
                                  "Please select quantity for assigning items.",
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
                          }
                          if (this.mounted) if (this.mounted)
                            setState(() {
                              showSpinner = false;
                            });
                        },
                        icon: Icon(Icons.check),
                        label: Text(
                          'Confirm',
                          style: TextStyle(
                            fontFamily: 'Exo2',
                            fontSize: mediaData.size.height * 0.026,
                            fontWeight: FontWeight.bold,
                          ),
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
                      width: mediaData.size.width * 0.1,
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          if (this.mounted)
                            setState(() {
                              RepsStreamState.quantityMap.keys.forEach((key) {
                                RepsStreamState.quantityMap[key] = 0;
                              });
                            });
                        },
                        icon: Icon(Icons.restore),
                        label: Text(
                          'Reset',
                          style: TextStyle(
                            fontFamily: 'Exo2',
                            fontSize: mediaData.size.height * 0.026,
                            fontWeight: FontWeight.bold,
                          ),
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
class RepsStream extends StatefulWidget {
  var controller;
  String searchText;
  String orderByText;
  var userRoleDash;
  RepsStream(
      this.controller, this.searchText, this.orderByText, this.userRoleDash);

  @override
  RepsStreamState createState() => RepsStreamState();
}

class RepsStreamState extends State<RepsStream> {
  static var quantityMap = new Map();
  late Timer timer;
  @override
  void initState() {
    super.initState();
    if (this.mounted)
      setState(() {
        quantityMap.clear();
      });
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return StreamBuilder<QuerySnapshot>(
      // ignore: unnecessary_null_comparison
      stream: (widget.searchText != "")
          ? searchData(widget.searchText, widget.orderByText)
          : widget.orderByText == 'Name'
              ? _firestore
                  .collection('items')
                  .orderBy('name', descending: true)
                  .snapshots()
              : _firestore
                  .collection('items')
                  .orderBy('timestamp', descending: false)
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
          final itemPrice = item['price'];
          final itemStatus = item['status'];
          final itemID = item.reference.id;

          if (itemStatus != 'disable') {
            if (!quantityMap.containsKey(itemID)) {
              quantityMap[itemID] = 0;
            }

            repList.add(repListBuilder(
                itemName,
                itemPrice.toString(),
                mediaData,
                context,
                itemStatus,
                itemID,
                quantityMap,
                widget.userRoleDash));
          }
        }
        return Expanded(
          child: Container(
            child: ListView.builder(
              controller: widget.controller,
              itemCount: repList.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Align(
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

  Widget repListBuilder(
      String name,
      String price,
      MediaQueryData mediaData,
      BuildContext context,
      String status,
      String itemID,
      Map quantityMap,
      String userRole) {
    var _keyName = TextEditingController();
    var _keyPrice = TextEditingController();
    _keyName.text = name;
    _keyPrice.text = price;

    return Container(
      margin: EdgeInsets.only(top: 10.0),
      width: mediaData.size.width * 0.95,
      height: mediaData.size.height * 0.15,
      decoration: BoxDecoration(
        boxShadow: boxShadowsReps(),
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Padding(
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
                ],
              ),
            ),
          ),
          SizedBox(
            height: mediaData.size.height * 0.014,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTapDown: (TapDownDetails details) {
                        timer =
                            Timer.periodic(Duration(milliseconds: 200), (t) {
                          if (this.mounted)
                            setState(() {
                              if (quantityMap[itemID] > 0) {
                                quantityMap[itemID] -= 1;
                              }
                            });
                        });
                      },
                      onTapUp: (TapUpDetails details) {
                        timer.cancel();
                      },
                      onTapCancel: () {
                        timer.cancel();
                      },
                      child: FloatingActionButton(
                        heroTag: 'quantityHeroTag1$itemID',
                        mini: true,
                        backgroundColor: userRole.toString() == 'admin'
                            ? Color(0xFF7a459d)
                            : Color(0xFF7a459d),
                        child: Icon(Icons.remove),
                        onPressed: () {
                          if (this.mounted)
                            setState(() {
                              if (quantityMap[itemID] > 0) {
                                quantityMap[itemID] -= 1;
                              }
                            });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: mediaData.size.width * 0.035),
                      child: Text(
                        quantityMap[itemID].toString(),
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    GestureDetector(
                      onTapDown: (TapDownDetails details) {
                        timer =
                            Timer.periodic(Duration(milliseconds: 200), (t) {
                          if (this.mounted)
                            setState(() {
                              quantityMap[itemID] += 1;
                            });
                        });
                      },
                      onTapUp: (TapUpDetails details) {
                        timer.cancel();
                      },
                      onTapCancel: () {
                        timer.cancel();
                      },
                      child: FloatingActionButton(
                        heroTag: 'quantityHeroTag2$itemID',
                        mini: true,
                        backgroundColor: userRole.toString() == 'admin'
                            ? Color(0xFF7a459d)
                            : Color(0xFF7a459d),
                        child: Icon(Icons.add),
                        onPressed: () {
                          if (this.mounted)
                            setState(() {
                              quantityMap[itemID] += 1;
                            });
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
