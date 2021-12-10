import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/components/exception_manage.dart';
import 'package:dk_brothers/screens/order_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'edit1.dart';

User? loggedInUser1;

// ignore: must_be_immutable
class ViewOrder extends StatefulWidget {
  static String id = 'view_order';

  var discount;
  var orderID;
  var paymentMethod;
  var orderDate;
  var payment;
  var shopId;
  var shopName;
  var time;
  var bank;
  var chequeNum;
  var withdrawDate;
  var repName;
  var repID;
  var paymentID;
  var userRoleDash;

  ViewOrder(
    this.shopId,
    this.shopName,
    this.orderDate,
    this.time,
    this.payment,
    this.paymentMethod,
    this.orderID,
    this.discount,
    this.repName,
    this.repID,
    this.paymentID,
    this.userRoleDash,
  );
  ViewOrder.cheque(
    this.shopId,
    this.shopName,
    this.orderDate,
    this.time,
    this.payment,
    this.paymentMethod,
    this.orderID,
    this.discount,
    this.bank,
    this.chequeNum,
    this.withdrawDate,
    this.repName,
    this.repID,
    this.paymentID,
    this.userRoleDash,
  );
  ViewOrder.credit(
    this.shopId,
    this.shopName,
    this.orderDate,
    this.time,
    this.payment,
    this.paymentMethod,
    this.orderID,
    this.discount,
    this.repName,
    this.repID,
    this.userRoleDash,
  );
  @override
  _ViewOrderState createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  late StreamSubscription subscription;
  bool showSpinner = false;
  final _firestore = FirebaseFirestore.instance;
  List orderList = [];
  List freeList = [];
  double total = 0;
  double discountedTotal = 0;
  late List<String> wordList;
  var userRole;

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
    wordList = widget.repName.split(" ");
    await getorderData();
    await getUserRole();
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
        appBar: appBarComponenet(mediaData, widget.shopName),
        body: Container(
          margin: EdgeInsets.only(top: mediaData.size.height * 0.02),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(
                  mediaData.size.width * 0.025,
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: mediaData.size.width * 0.04,
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
                                'ID',
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
                                'Date',
                                style: TextStyle(
                                    fontFamily: 'Exo2',
                                    fontWeight: FontWeight.bold,
                                    fontSize: mediaData.size.height * 0.021),
                              ),
                            ),
                            discountedTotal < total
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        bottom: mediaData.size.height * 0.015),
                                    child: Text(
                                      'Total\n',
                                      style: TextStyle(
                                          fontFamily: 'Exo2',
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              mediaData.size.height * 0.021),
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                        bottom: mediaData.size.height * 0.015),
                                    child: Text(
                                      'Total',
                                      style: TextStyle(
                                          fontFamily: 'Exo2',
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              mediaData.size.height * 0.021),
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
                                'Balance',
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
                                ': ' + widget.orderID,
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
                                ': ' + widget.orderDate,
                                style: TextStyle(
                                    fontFamily: 'Exo2',
                                    fontWeight: FontWeight.bold,
                                    fontSize: mediaData.size.height * 0.021),
                              ),
                            ),
                            discountedTotal < total
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        bottom: mediaData.size.height * 0.015),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text: ': Rs. ',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  mediaData.size.height * 0.021,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: total.toStringAsFixed(1),
                                                style: TextStyle(
                                                    fontFamily: 'Exo2',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        mediaData.size.height *
                                                            0.021,
                                                    decoration: TextDecoration
                                                        .lineThrough),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          ': Rs. ' + getTotal(),
                                          style: TextStyle(
                                              fontFamily: 'Exo2',
                                              fontWeight: FontWeight.bold,
                                              fontSize: mediaData.size.height *
                                                  0.021),
                                        ),
                                      ],
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                        bottom: mediaData.size.height * 0.015),
                                    child: Text(
                                      ': Rs. ' + total.toString(),
                                      style: TextStyle(
                                          fontFamily: 'Exo2',
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              mediaData.size.height * 0.021),
                                    ),
                                  ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: mediaData.size.height * 0.015),
                              child: Text(
                                ': Rs. ' + widget.payment,
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
                                ': Rs. ' + getBalance().toStringAsFixed(2),
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
                                'Discount',
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
                                ': ' + widget.time.toString().substring(0, 6),
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
                                ': ' + widget.discount.toString() + '%',
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
                                ': ' + widget.paymentMethod,
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
                                ': ' + wordList[0],
                                style: TextStyle(
                                    fontFamily: 'Exo2',
                                    fontWeight: FontWeight.bold,
                                    fontSize: mediaData.size.height * 0.021),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        DateTime date = DateTime.fromMicrosecondsSinceEpoch(
                            widget.withdrawDate.microsecondsSinceEpoch);
                        Alert(
                          context: context,
                          type: AlertType.info,
                          title: "Cheque Info",
                          desc: 'Bank : ' +
                              widget.bank +
                              '\n Cheque Number : ' +
                              widget.chequeNum +
                              '\n Withdraw Date : ' +
                              date.toString().substring(0, 10) +
                              '\n',
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
                        child: widget.paymentMethod == 'cheque'
                            ? Padding(
                                padding: EdgeInsets.only(
                                    bottom: mediaData.size.height * 0.015),
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
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                      vertical: mediaData.size.height * 0.01),
                  itemCount: orderList.length,
                  itemBuilder: (context, index) {
                    Map itemList = orderList[index];
                    var discount = itemList['discount'];
                    // ignore: unused_local_variable
                    var englishName = itemList['english_name'];
                    var itemId = itemList['item_id'];
                    var name = itemList['name'];
                    // ignore: unused_local_variable
                    var orderId = itemList['order_id'];
                    var price = itemList['price'];
                    var quantity = itemList['quantity'];
                    var total = quantity * price;
                    var itemDiscountedTotal = (price * quantity) -
                        ((discount / 100) * (price * quantity));
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(25.0),
                        boxShadow: boxShadowsReps(),
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: mediaData.size.height * 0.02,
                        vertical: mediaData.size.height * 0.005,
                      ),
                      child: ListTile(
                        leading: Padding(
                          padding: EdgeInsets.only(
                            top: mediaData.size.height * 0.01,
                          ),
                          child: Text((index + 1).toString()),
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontSize: mediaData.size.height * 0.023,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: freeList
                                .where((data) =>
                                    data['item_id'] == itemId &&
                                    data['quantity'] > 0)
                                .any((element) => true)
                            ? itemDiscountedTotal < total &&
                                    itemDiscountedTotal > 0 &&
                                    discount != widget.discount
                                ? RichText(
                                    text: TextSpan(
                                      text: "Rs. $price * $quantity ",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: mediaData.size.height * 0.019,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: '-' +
                                                discount.toString() +
                                                "%  ",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize:
                                                  mediaData.size.height * 0.019,
                                            )),
                                        TextSpan(
                                            text: '+' +
                                                freeList
                                                    .where((data) =>
                                                        data['item_id'] ==
                                                        itemId)
                                                    .first['quantity']
                                                    .toString() +
                                                " Free",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize:
                                                  mediaData.size.height * 0.019,
                                            )),
                                      ],
                                    ),
                                  )
                                : RichText(
                                    text: TextSpan(
                                      text: "Rs. $price * $quantity + ",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: mediaData.size.height * 0.019,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: freeList
                                                    .where((data) =>
                                                        data['item_id'] ==
                                                        itemId)
                                                    .first['quantity']
                                                    .toString() +
                                                " Free",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize:
                                                  mediaData.size.height * 0.019,
                                            )),
                                      ],
                                    ),
                                  )
                            : itemDiscountedTotal < total &&
                                    itemDiscountedTotal > 0 &&
                                    discount != widget.discount
                                ? RichText(
                                    text: TextSpan(
                                      text: "Rs. $price * $quantity ",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: mediaData.size.height * 0.019,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                '-' + discount.toString() + "%",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize:
                                                  mediaData.size.height * 0.019,
                                            )),
                                      ],
                                    ),
                                  )
                                : Text("Rs. $price * $quantity"),
                        trailing: itemDiscountedTotal < total &&
                                itemDiscountedTotal > 0
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: 'Rs. ',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              mediaData.size.height * 0.019),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: total.toStringAsFixed(2),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                mediaData.size.height * 0.019,
                                            color: Colors.black,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Rs. ' +
                                        itemDiscountedTotal.toStringAsFixed(2),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            mediaData.size.height * 0.019),
                                  ),
                                ],
                              )
                            : Text(
                                'Rs. ' + total.toStringAsFixed(2),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: mediaData.size.height * 0.019),
                              ),
                      ),
                    );
                  },
                ),
              ),
              if ((loggedInUser1!.uid.toString() == widget.repID.toString()) ||
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
                              if (widget.paymentMethod == 'cash') {
                                pushNewScreenWithRouteSettings(
                                  context,
                                  settings: RouteSettings(
                                    name: Edit1.id,
                                  ),
                                  screen: Edit1(
                                    orderList,
                                    widget.shopName,
                                    widget.orderID,
                                    widget.payment,
                                    widget.discount,
                                    widget.paymentMethod,
                                    widget.shopId,
                                    widget.repName,
                                    widget.paymentID,
                                    widget.userRoleDash,
                                    widget.repID,
                                    widget.orderDate,
                                  ),
                                  withNavBar: true,
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              }
                              if (widget.paymentMethod == 'cheque') {
                                pushNewScreenWithRouteSettings(
                                  context,
                                  settings: RouteSettings(
                                    name: Edit1.id,
                                  ),
                                  screen: Edit1.cheque(
                                    orderList,
                                    widget.shopName,
                                    widget.orderID,
                                    widget.payment,
                                    widget.discount,
                                    widget.paymentMethod,
                                    widget.shopId,
                                    widget.bank,
                                    widget.chequeNum,
                                    widget.withdrawDate,
                                    widget.repName,
                                    widget.paymentID,
                                    widget.userRoleDash,
                                    widget.repID,
                                    widget.orderDate,
                                  ),
                                  withNavBar: true,
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              }
                              if (widget.paymentMethod == 'credit') {
                                pushNewScreenWithRouteSettings(
                                  context,
                                  settings: RouteSettings(
                                    name: Edit1.id,
                                  ),
                                  screen: Edit1.credit(
                                    orderList,
                                    widget.shopName,
                                    widget.orderID,
                                    widget.payment,
                                    widget.discount,
                                    widget.paymentMethod,
                                    widget.shopId,
                                    widget.repName,
                                    widget.userRoleDash,
                                    widget.repID,
                                    widget.orderDate,
                                  ),
                                  withNavBar: true,
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              }
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
                                      await removeOrder();
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

  getUserRole() async {
    if (this.mounted)
      setState(() {
        showSpinner = true;
      });
    await _firestore
        .collection("users")
        .doc(loggedInUser1!.uid)
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

  getorderData() async {
    if (this.mounted)
      setState(() {
        showSpinner = true;
      });
    QuerySnapshot querySnapshot = await _firestore
        .collection("order_items")
        .where('order_id', isEqualTo: widget.orderID.toString())
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      var a = querySnapshot.docs[i];
      Map orderItems = {
        'discount': a['discount'],
        'english_name': a['english_name'],
        'item_id': a['item_id'],
        'name': a['name'],
        'order_id': a['order_id'],
        'price': a['price'],
        'quantity': a['quantity'],
      };
      if (this.mounted)
        setState(() {
          orderList.add(orderItems);
          total += a['price'] * a['quantity'];
          discountedTotal += (a['price'] * a['quantity']) -
              ((a['discount'] / 100) * (a['price'] * a['quantity']));
        });
    }

    QuerySnapshot querySnapshot1 = await _firestore
        .collection("free_items")
        .where('order_id', isEqualTo: widget.orderID.toString())
        .get();
    for (int i = 0; i < querySnapshot1.docs.length; i++) {
      var a = querySnapshot1.docs[i];
      Map orderItems1 = {
        'english_name': a['english_name'],
        'item_id': a['item_id'],
        'name': a['name'],
        'order_id': a['order_id'],
        'quantity': a['quantity'],
      };
      if (this.mounted)
        setState(() {
          freeList.add(orderItems1);
        });
    }
    if (this.mounted)
      setState(() {
        showSpinner = false;
      });
  }

  getTotal() {
    if (discountedTotal < total && discountedTotal > 0) {
      return discountedTotal.toStringAsFixed(1);
    } else {
      return total.toString();
    }
  }

  getBalance() {
    var finalT = getTotal();
    finalT = double.parse(widget.payment) - double.parse(finalT);
    return finalT;
  }

  removeOrder() async {
    try {
      if (widget.paymentMethod == 'credit') {
        await _firestore
            .collection('orders')
            .doc(widget.orderID)
            .update({'status': 'disable'});
      } else {
        await _firestore.collection('orders').doc(widget.orderID).update({
          'status': 'disable',
        });
        await _firestore.collection('payments').doc(widget.paymentID).update({
          'status': 'disable',
        });
      }
      Navigator.of(context, rootNavigator: true).pop();
      Alert(
        context: context,
        type: AlertType.success,
        title: "Successful",
        desc: "Order Removed",
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
                    return OrderScreen(0, widget.userRoleDash);
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
