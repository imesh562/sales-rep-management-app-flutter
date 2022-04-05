import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/screens/view_orders.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

// ignore: must_be_immutable
class OrderHistory extends StatefulWidget {
  var userRoleDash;

  OrderHistory(this.userRoleDash);

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  final _firestore = FirebaseFirestore.instance;
  late List events;
  String searchText = "";
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(
              mediaData.size.width * 0.025,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: mediaData.size.width * 0.04,
              vertical: mediaData.size.width * 0.05,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: boxShadowsReps(),
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Row(
              children: [
                Container(
                  width: mediaData.size.width * 0.68,
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
                                : Color(0xFF7a459d)),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: widget.userRoleDash.toString() == 'admin'
                                ? Color(0xFF7a459d)
                                : Color(0xFF7a459d)),
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
                TextButton(
                  onPressed: () {
                    _selectDate(context);
                  },
                  child: Icon(
                    Icons.calendar_today,
                    size: mediaData.size.height * 0.05,
                    color: widget.userRoleDash.toString() == 'admin'
                        ? widget.userRoleDash.toString() == 'admin'
                            ? Color(0xFF509877)
                            : Color(0xFF2aa7df)
                        : Color(0xFF2aa7df),
                  ),
                ),
              ],
            ),
          ),
          GetEventsForDay(
            _firestore,
            searchText,
            selectedDate,
            widget.userRoleDash,
          ),
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
                        if (this.mounted)
                          setState(() {
                            selectedDate = null;
                          });
                      },
                      icon: Icon(Icons.refresh),
                      label: Text(
                        'Reset Calender',
                        style:
                            TextStyle(fontSize: mediaData.size.height * 0.026),
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
    );
  }

  _selectDate(BuildContext context) async {
    DateTime now = new DateTime.now();
    DateTime finalDate = new DateTime(now.year, now.month, now.day);
    String strDt = "2021-10-01 00:00:00.000";
    DateTime parseDt = DateTime.parse(strDt);
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: finalDate,
      firstDate: parseDt,
      currentDate: finalDate,
      lastDate: finalDate,
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
class GetEventsForDay extends StatelessWidget {
  var controller;
  var firestore;
  var searchText;
  var selectedDate;
  var userRoleDash;
  GetEventsForDay(
      this.firestore, this.searchText, this.selectedDate, this.userRoleDash);

  Stream<QuerySnapshot> searchData() async* {
    if (searchText != "" && selectedDate != null) {
      var _search = firestore
          .collection('orders')
          .where('shop_name', isGreaterThanOrEqualTo: searchText)
          .where('shop_name', isLessThan: searchText + 'z')
          .orderBy('shop_name', descending: false)
          .snapshots();
      yield* _search;
    }

    if (searchText != "" && selectedDate == null) {
      var _search = firestore
          .collection('orders')
          .where('shop_name', isGreaterThanOrEqualTo: searchText)
          .where('shop_name', isLessThan: searchText + 'z')
          .orderBy('shop_name', descending: false)
          .snapshots();
      yield* _search;
    }

    if (selectedDate != null && searchText == "") {
      var _search1 = firestore
          .collection('orders')
          .where('date', isEqualTo: selectedDate.toString().substring(0, 10))
          .orderBy('time', descending: false)
          .snapshots();
      yield* _search1;
    }

    if (searchText == "" && selectedDate == null) {
      var _search2 = firestore
          .collection('orders')
          .orderBy('date', descending: false)
          .orderBy('time', descending: false)
          .snapshots();
      yield* _search2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: searchData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final orders = snapshot.data!.docs.reversed;
        List<Widget> orderList = [];
        for (var item in orders) {
          final orderDate = item['date'];
          final payment = item['payment'];
          final payment_total = item['payment_total'];
          final paymentMethod = item['payment_method'];
          final shopId = item['shop_id'];
          final shopName = item['shop_name'];
          final discount = item['discount'];
          final time = item['time'];
          final status = item['status'];
          final repName = item['rep_name'];
          final repID = item['rep_id'];
          final orderID = item.reference.id;

          if (selectedDate == null && status == 'enable') {
            if (paymentMethod == 'cash') {
              orderList.add(repListBuilder(
                orderDate,
                payment.toString(),
                payment_total.toString(),
                context,
                paymentMethod.toString(),
                shopId,
                orderID,
                shopName,
                discount,
                time,
                repName,
                repID,
                item['payment_id'],
                userRoleDash,
              ));
            }
            if (paymentMethod == 'cheque') {
              orderList.add(repListBuilder1(
                orderDate,
                payment.toString(),
                payment_total.toString(),
                context,
                paymentMethod.toString(),
                shopId,
                orderID,
                shopName,
                discount,
                time,
                item['bank'],
                item['cheque_num'],
                item['withdrawDate'],
                repName,
                repID,
                item['payment_id'],
                userRoleDash,
              ));
            }
            if (paymentMethod == 'credit') {
              orderList.add(repListBuilder2(
                orderDate,
                payment.toString(),
                payment_total.toString(),
                context,
                paymentMethod.toString(),
                shopId,
                orderID,
                shopName,
                discount,
                time,
                repName,
                repID,
                userRoleDash,
              ));
            }
          } else if (status == 'enable') {
            if (selectedDate.toString().substring(0, 10) == orderDate) {
              if (paymentMethod == 'cash') {
                orderList.add(repListBuilder(
                  orderDate,
                  payment.toString(),
                  payment_total.toString(),
                  context,
                  paymentMethod.toString(),
                  shopId,
                  orderID,
                  shopName,
                  discount,
                  time,
                  repName,
                  repID,
                  item['payment_id'],
                  userRoleDash,
                ));
              }
              if (paymentMethod == 'cheque') {
                orderList.add(repListBuilder1(
                  orderDate,
                  payment.toString(),
                  payment_total.toString(),
                  context,
                  paymentMethod.toString(),
                  shopId,
                  orderID,
                  shopName,
                  discount,
                  time,
                  item['bank'],
                  item['cheque_num'],
                  item['withdrawDate'],
                  repName,
                  repID,
                  item['payment_id'],
                  userRoleDash,
                ));
              }
              if (paymentMethod == 'credit') {
                orderList.add(repListBuilder2(
                  orderDate,
                  payment.toString(),
                  payment_total.toString(),
                  context,
                  paymentMethod.toString(),
                  shopId,
                  orderID,
                  shopName,
                  discount,
                  time,
                  repName,
                  repID,
                  userRoleDash,
                ));
              }
            }
          }
        }
        return Expanded(
          child: Container(
            child: ListView.builder(
              controller: controller,
              itemCount: orderList.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: orderList[index],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget repListBuilder(
    orderDate,
    String payment,
    String payment_total,
    BuildContext context,
    String paymentMethod,
    shopId,
    String orderID,
    shopName,
    discount,
    time,
    repName,
    repID,
    paymentID,
    userRoleDash,
  ) {
    final mediaData = MediaQuery.of(context);

    return GestureDetector(
      onTap: () {
        pushNewScreenWithRouteSettings(
          context,
          settings: RouteSettings(
            name: ViewOrder.id,
          ),
          screen: ViewOrder(
            shopId,
            shopName,
            orderDate,
            time,
            payment,
            payment_total,
            paymentMethod,
            orderID,
            discount,
            repName,
            repID,
            paymentID,
            userRoleDash,
          ),
          withNavBar: true,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: mediaData.size.height * 0.015),
        width: mediaData.size.width * 0.95,
        height: mediaData.size.height * 0.15,
        decoration: BoxDecoration(
            boxShadow: boxShadowsReps(),
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage('assets/images/viewOrder.png'),
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
              child: Text(
                shopName,
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.028,
                  fontFamily: 'Exo2',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 14.0),
              child: Text(
                'Date \t\t\t\t\t\t\t: ' + orderDate.substring(0, 10),
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.02,
                  fontFamily: 'Exo2',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 1.0, left: 14.0),
              child: Text(
                'Payment \t: Rs.' + payment,
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.02,
                  fontFamily: 'Exo2',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 14.0),
              child: Text(
                'Order ID \t\t: $orderID',
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.02,
                  fontFamily: 'Exo2',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget repListBuilder1(
    orderDate,
    String payment,
    String payment_total,
    BuildContext context,
    String paymentMethod,
    shopId,
    String orderID,
    shopName,
    discount,
    time,
    bank,
    chequeNum,
    withdrawDate,
    repName,
    repID,
    paymentID,
    userRoleDash,
  ) {
    final mediaData = MediaQuery.of(context);

    return GestureDetector(
      onTap: () {
        pushNewScreenWithRouteSettings(
          context,
          settings: RouteSettings(
            name: ViewOrder.id,
          ),
          screen: ViewOrder.cheque(
            shopId,
            shopName,
            orderDate,
            time,
            payment,
            payment_total,
            paymentMethod,
            orderID,
            discount,
            bank,
            chequeNum,
            withdrawDate,
            repName,
            repID,
            paymentID,
            userRoleDash,
          ),
          withNavBar: true,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: mediaData.size.height * 0.015),
        width: mediaData.size.width * 0.95,
        height: mediaData.size.height * 0.15,
        decoration: BoxDecoration(
            boxShadow: boxShadowsReps(),
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage('assets/images/viewOrder.png'),
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
              child: Text(
                shopName,
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.028,
                  fontFamily: 'Exo2',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 14.0),
              child: Text(
                'Date \t\t\t\t\t\t\t: ' + orderDate.substring(0, 10),
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.02,
                  fontFamily: 'Exo2',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 1.0, left: 14.0),
              child: Text(
                'Payment \t: Rs.' + payment,
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.02,
                  fontFamily: 'Exo2',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 14.0),
              child: Text(
                'Order ID \t\t: $orderID',
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.02,
                  fontFamily: 'Exo2',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget repListBuilder2(
    orderDate,
    String payment,
    String payment_total,
    BuildContext context,
    String paymentMethod,
    shopId,
    String orderID,
    shopName,
    discount,
    time,
    repName,
    repID,
    userRoleDash,
  ) {
    final mediaData = MediaQuery.of(context);

    return GestureDetector(
      onTap: () {
        pushNewScreenWithRouteSettings(
          context,
          settings: RouteSettings(
            name: ViewOrder.id,
          ),
          screen: ViewOrder.credit(
            shopId,
            shopName,
            orderDate,
            time,
            payment,
            payment_total,
            paymentMethod,
            orderID,
            discount,
            repName,
            repID,
            userRoleDash,
          ),
          withNavBar: true,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: mediaData.size.height * 0.015),
        width: mediaData.size.width * 0.95,
        height: mediaData.size.height * 0.15,
        decoration: BoxDecoration(
            boxShadow: boxShadowsReps(),
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage('assets/images/viewOrder.png'),
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
              child: Text(
                shopName,
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.028,
                  fontFamily: 'Exo2',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 14.0),
              child: Text(
                'Date \t\t\t\t\t\t\t: ' + orderDate.substring(0, 10),
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.02,
                  fontFamily: 'Exo2',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 1.0, left: 14.0),
              child: Text(
                'Payment \t: Credit',
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.02,
                  fontFamily: 'Exo2',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 14.0),
              child: Text(
                'Order ID \t\t: $orderID',
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.02,
                  fontFamily: 'Exo2',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
