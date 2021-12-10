import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/screens/confirm_order.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';

final _firestore = FirebaseFirestore.instance;
User? loggedInUser1;

// ignore: must_be_immutable
class NewOrder extends StatefulWidget {
  var userRoleDash;

  NewOrder(this.userRoleDash);

  @override
  _NewOrderState createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  String searchText = "";
  ScrollController controller = ScrollController();
  int orderBy = 1;
  var orderByText = 'Name';
  bool showSpinnerDash = false;
  late DateTime now;
  late DateTime today;
  var assignedMap = new Map();
  List orderIDs = [];

  @override
  void initState() {
    super.initState();
    loggedInUser1 = FirebaseAuth.instance.currentUser;
    now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    waitingList();
  }

  waitingList() async {
    if (this.mounted)
      setState(() {
        RepsStreamState.quantityMap.clear();
      });
    await todayAssigns();
    await todaySales();
    await todayOrders();
  }

  todayAssigns() async {
    if (this.mounted)
      setState(() {
        showSpinnerDash = true;
        assignedMap.clear();
      });
    await _firestore
        .collection('daily_items')
        .where('date', isEqualTo: today.toString().substring(0, 10))
        .where('rep_id', isEqualTo: loggedInUser1!.uid)
        .get()
        .then((data) {
      if (data.docs.isNotEmpty) {
        data.docs.forEach((element) {
          if (this.mounted)
            setState(() {
              assignedMap[element['item_id']] = element['quantity'];
            });
        });
      }
    });
    if (this.mounted)
      setState(() {
        showSpinnerDash = false;
      });
  }

  todaySales() async {
    if (this.mounted)
      setState(() {
        showSpinnerDash = true;
        orderIDs.clear();
      });
    await _firestore
        .collection('orders')
        .where('date', isEqualTo: today.toString().substring(0, 10))
        .where('rep_id', isEqualTo: loggedInUser1!.uid)
        .get()
        .then((data) {
      if (data.docs.isNotEmpty) {
        data.docs.forEach((element) {
          if (this.mounted)
            setState(() {
              orderIDs.add(element.id);
            });
        });
      }
    });
    if (this.mounted)
      setState(() {
        showSpinnerDash = false;
      });
  }

  todayOrders() async {
    if (this.mounted)
      setState(() {
        showSpinnerDash = true;
      });
    orderIDs.forEach((element) async {
      await _firestore
          .collection('order_items')
          .where('order_id', isEqualTo: element)
          .get()
          .then((data) {
        if (data.docs.isNotEmpty) {
          data.docs.forEach((element) {
            if (this.mounted)
              setState(() {
                assignedMap[element['item_id']] =
                    assignedMap[element['item_id']] - element['quantity'];
              });
          });
        }
      });
    });
    if (this.mounted)
      setState(() {
        showSpinnerDash = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinnerDash,
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
              controller,
              searchText,
              orderByText,
              widget.userRoleDash,
              assignedMap,
            ),
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
                        onPressed: () {
                          Map itemList = RepsStreamState.quantityMap;
                          for (var value in itemList.values) {
                            if (value > 0) {
                              Route route = MaterialPageRoute(
                                  builder: (context) => ConfirmOrder(
                                      itemList, widget.userRoleDash));
                              Navigator.push(context, route)
                                  .then((value) => waitingList());
                              break;
                            }
                          }
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
  Map assignedMap;
  RepsStream(this.controller, this.searchText, this.orderByText,
      this.userRoleDash, this.assignedMap);

  @override
  RepsStreamState createState() => RepsStreamState();
}

class RepsStreamState extends State<RepsStream> {
  static var quantityMap = new Map();
  late Timer timer;
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
            if (widget.assignedMap.containsKey(itemID)) {
              repList.add(
                repListBuilder(
                  itemName,
                  itemPrice.toString(),
                  mediaData,
                  context,
                  itemStatus,
                  itemID,
                  quantityMap,
                  widget.userRoleDash,
                  widget.assignedMap[itemID],
                ),
              );
            }
          }
        }
        return widget.assignedMap.isNotEmpty
            ? Expanded(
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
              )
            : Expanded(
                child: Container(
                  child: Center(
                      child: Text(
                    'Items Not Assigned Yet',
                    style: TextStyle(
                      fontFamily: 'Exo2',
                      fontSize: mediaData.size.height * 0.023,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
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
      String userRole,
      int maxValue) {
    var _keyName = TextEditingController();
    var _keyPrice = TextEditingController();
    _keyName.text = name;
    _keyPrice.text = price;

    return Container(
      margin: EdgeInsets.only(top: 10.0),
      width: mediaData.size.width * 0.95,
      height: mediaData.size.height * 0.16,
      decoration: BoxDecoration(
        boxShadow: boxShadowsReps(),
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: mediaData.size.height * 0.008,
                left: mediaData.size.width * 0.04),
            child: Text(
              name,
              style: TextStyle(
                fontSize: mediaData.size.height * 0.028,
                fontFamily: 'Exo2',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: mediaData.size.height * 0.004,
                left: mediaData.size.width * 0.04),
            child: Text(
              'Stock : ' + maxValue.toString(),
              style: TextStyle(
                fontSize: mediaData.size.height * 0.0225,
                fontFamily: 'Exo2',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: mediaData.size.width * 0.04),
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
                              if (quantityMap[itemID] < maxValue) {
                                quantityMap[itemID] += 1;
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
                        heroTag: 'quantityHeroTag2$itemID',
                        mini: true,
                        backgroundColor: userRole.toString() == 'admin'
                            ? Color(0xFF7a459d)
                            : Color(0xFF7a459d),
                        child: Icon(Icons.add),
                        onPressed: () {
                          if (this.mounted)
                            setState(() {
                              if (quantityMap[itemID] < maxValue) {
                                quantityMap[itemID] += 1;
                              }
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
