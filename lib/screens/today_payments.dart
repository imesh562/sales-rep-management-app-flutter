import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/screens/viewPayment.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

// ignore: must_be_immutable
class TodayPayments extends StatefulWidget {
  static String id = 'today_orders';
  var today;
  TodayPayments(this.today);

  @override
  _TodayPaymentsState createState() => _TodayPaymentsState();
}

class _TodayPaymentsState extends State<TodayPayments> {
  final _firestore = FirebaseFirestore.instance;
  late List events;
  var userRoleDash = 'admin';

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: appBarComponenet(mediaData, 'Today Payments'),
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
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('payments')
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
          final paymentDate = item['date'];
          final payment = item['payment'];
          final paymentMethod = item['payment_method'];
          final shopId = item['shop_id'];
          final shopName = item['shop_name'];
          final time = item['time'];
          final status = item['status'];
          final repName = item['rep_name'];
          final repID = item['rep_id'];
          final paymentID = item.reference.id;

          if (status == 'enable' && selectedDate != null) {
            if (selectedDate.toString().substring(0, 10) == paymentDate) {
              if (paymentMethod == 'cash') {
                orderList.add(repListBuilder(
                    paymentDate,
                    payment.toString(),
                    context,
                    paymentMethod.toString(),
                    shopId,
                    paymentID,
                    shopName,
                    time,
                    repName,
                    repID,
                    userRoleDash));
              } else {
                orderList.add(repListBuilder1(
                    paymentDate,
                    payment.toString(),
                    context,
                    paymentMethod.toString(),
                    shopId,
                    paymentID,
                    shopName,
                    time,
                    item['bank'],
                    item['cheque_num'],
                    item['withdrawDate'],
                    repName,
                    repID,
                    item['cheque_status'],
                    userRoleDash));
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
    paymentDate,
    payment,
    context,
    paymentMethod,
    shopId,
    paymentID,
    shopName,
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
            name: ViewPayment.id,
          ),
          screen: ViewPayment(
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
              image: AssetImage('assets/images/paymentsBG.png'),
              alignment: Alignment.topRight,
              fit: BoxFit.fitHeight,
              colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.5), BlendMode.dstATop),
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
                'Date \t\t\t\t\t\t\t: ' + paymentDate.substring(0, 10),
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
                'Rep \t\t\t\t\t\t\t\t : $repName',
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
    paymentDate,
    payment,
    context,
    paymentMethod,
    shopId,
    paymentID,
    shopName,
    time,
    bank,
    // ignore: non_constant_identifier_names
    cheque_num,
    withdrawDate,
    repName,
    repID,
    chequeStatus,
    userRoleDash,
  ) {
    final mediaData = MediaQuery.of(context);

    return GestureDetector(
      onTap: () {
        pushNewScreenWithRouteSettings(
          context,
          settings: RouteSettings(
            name: ViewPayment.id,
          ),
          screen: ViewPayment(
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
              image: AssetImage('assets/images/cheque.png'),
              alignment: Alignment.topRight,
              fit: BoxFit.fitHeight,
              colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.2), BlendMode.dstATop),
            )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
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
                if (chequeStatus == 'pending')
                  Icon(
                    Icons.play_circle,
                    color: Color(0xFF04DBDD),
                  ),
                if (chequeStatus == 'returned')
                  Icon(
                    Icons.error,
                    color: Color(0xFFcb2c64),
                  ),
                if (chequeStatus == 'completed')
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[300],
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 14.0),
              child: Text(
                'Date \t\t\t\t\t\t\t: ' + paymentDate.substring(0, 10),
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
                'Rep \t\t\t\t\t\t\t\t : $repName',
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
