import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/screens/viewPayment.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'decorations.dart';

// ignore: must_be_immutable
class GetRecentPayments extends StatefulWidget {
  var userRoleDash;

  GetRecentPayments(this.userRoleDash);

  @override
  _GetRecentPaymentsState createState() => _GetRecentPaymentsState();
}

class _GetRecentPaymentsState extends State<GetRecentPayments> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('payments')
          .orderBy('date', descending: false)
          .orderBy('time', descending: false)
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

          if (status == 'enable') {
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
                repID));
          }
        }
        return Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 3 / 2.2,
                crossAxisSpacing: 10,
                crossAxisCount: 2),
            itemCount: orderList.length < 4
                ? orderList.length > 0
                    ? orderList.length
                    : 0
                : 4,
            itemBuilder: (context, index) {
              return Container(
                margin: index % 2 == 0
                    ? EdgeInsets.only(
                        left: mediaData.size.width * 0.04,
                        top: mediaData.size.height * 0.01)
                    : EdgeInsets.only(
                        right: mediaData.size.width * 0.04,
                        top: mediaData.size.height * 0.01),
                child: orderList[index],
              );
            },
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
  ) {
    late List<String> wordList;
    final mediaData = MediaQuery.of(context);
    wordList = repName.split(" ");
    return GestureDetector(
      onTap: () {
        pushNewScreenWithRouteSettings(
          context,
          settings: RouteSettings(
            name: ViewPayment.id,
          ),
          screen: ViewPayment(
            paymentID,
            widget.userRoleDash,
          ),
          withNavBar: true,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: boxShadowsReps(),
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 14.0),
              child: Text(
                shopName,
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.025,
                  fontFamily: 'Exo2',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: mediaData.size.height * 0.01,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: Text(
                'Date \t\t\t\t\t\t\t: ' + paymentDate.substring(0, 10),
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.018,
                  fontFamily: 'Exo2',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 1.0, left: 14.0),
              child: Text(
                'Payment \t: Rs.' + payment,
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.018,
                  fontFamily: 'Exo2',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 14.0),
              child: Text(
                'Rep \t\t\t\t\t\t\t\t : ' + wordList[0],
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.018,
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
