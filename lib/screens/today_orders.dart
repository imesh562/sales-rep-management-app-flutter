import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/screens/view_orders.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

// ignore: must_be_immutable
class TodayOrders extends StatefulWidget {
  static String id = 'today_orders';
  var today;
  TodayOrders(this.today);

  @override
  _TodayOrdersState createState() => _TodayOrdersState();
}

class _TodayOrdersState extends State<TodayOrders> {
  final _firestore = FirebaseFirestore.instance;
  late List events;
  var userRoleDash = 'admin';

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: appBarComponenet(mediaData, 'Today Orders'),
      body: Column(
        children: [
          GetEventsForDay(
            _firestore,
            widget.today.toString().substring(0, 10),
            userRoleDash,
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class GetEventsForDay extends StatelessWidget {
  var controller;
  var firestore;
  var selectedDate;
  var userRoleDash;
  GetEventsForDay(this.firestore, this.selectedDate, this.userRoleDash);

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('orders')
          .where('date', isGreaterThanOrEqualTo: selectedDate.toString())
          .snapshots(),
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
          if (status == 'enable' && selectedDate != null) {
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
            margin: EdgeInsets.only(top: mediaData.size.height * 0.015),
            child: orderList.isNotEmpty
                ? ListView.builder(
                    controller: controller,
                    itemCount: orderList.length,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Align(
                        alignment: Alignment.topCenter,
                        child: orderList[index],
                      );
                    },
                  )
                : Container(
                    child: Center(
                        child: Text(
                      'No orders yet',
                      style: TextStyle(
                        fontFamily: 'Exo2',
                        fontSize: mediaData.size.height * 0.023,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
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
