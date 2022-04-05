import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/screens/viewPayment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

User? loggedInUser;

// ignore: must_be_immutable
class ShopProfilePayments extends StatefulWidget {
  static String id = 'shop_profile_sales';
  var shopID;
  var name;

  ShopProfilePayments(this.shopID, this.name);
  @override
  _ShopProfilePaymentsState createState() => _ShopProfilePaymentsState();
}

class _ShopProfilePaymentsState extends State<ShopProfilePayments> {
  bool showSpinnerDash = false;
  late StreamSubscription subscription;
  final _firestore = FirebaseFirestore.instance;
  ScrollController controller = ScrollController();
  DateTime? selectedDate;
  var userRoleDash = 'admin';
  bool closeTopContainers = false;

  @override
  void initState() {
    loggedInUser = FirebaseAuth.instance.currentUser;
    super.initState();
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
      appBar: appBarComponenet(mediaData, widget.name),
      body: ModalProgressHUD(
        inAsyncCall: showSpinnerDash,
        child: Container(
          child: Column(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: closeTopContainers ? 0 : 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: mediaData.size.width,
                  alignment: Alignment.topCenter,
                  height:
                      closeTopContainers ? 0 : mediaData.size.height * 0.427,
                  child: Container(
                    height: mediaData.size.height * 0.427,
                    margin: EdgeInsets.symmetric(
                        horizontal: mediaData.size.width * 0.04),
                    child: CalendarCarousel<Event>(
                      onDayPressed: (DateTime date, List<Event> events) {
                        if (this.mounted)
                          setState(() {
                            selectedDate = date;
                          });
                      },
                      weekendTextStyle: TextStyle(
                        color: Color(0xFFcb2c64),
                      ),
                      selectedDayButtonColor: Color(0xFF5B9FDE),
                      selectedDayBorderColor: Color(0xFF5B9FDE),
                      todayBorderColor: Color(0xFFcb2c64),
                      todayButtonColor: Color(0xFFcb2c64),
                      headerMargin: EdgeInsets.all(0),
                      scrollDirection: Axis.horizontal,
                      thisMonthDayBorderColor: Colors.grey,
                      selectedDateTime: selectedDate,
                      daysHaveCircularBorder: false,
                      weekDayMargin: EdgeInsets.all(0),
                      weekDayPadding: EdgeInsets.all(0),
                    ),
                  ),
                ),
              ),
              paymentList(mediaData),
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
                            style: TextStyle(
                                fontSize: mediaData.size.height * 0.026),
                          ),
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Color(0xFFcb2c64),
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

  Widget paymentList(mediaData) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('payments')
          .where('shop_id', isEqualTo: widget.shopID)
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

          if (selectedDate == null && status == 'enable') {
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
          } else if (status == 'enable') {
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
        return orderList.isNotEmpty
            ? Expanded(
                child: Container(
                  child: ListView.builder(
                    controller: controller,
                    physics: BouncingScrollPhysics(),
                    itemCount: orderList.length,
                    itemBuilder: (context, index) {
                      return Align(
                        alignment: Alignment.topCenter,
                        child: orderList[index],
                      );
                    },
                  ),
                ),
              )
            : Expanded(
                child: Container(
                  child: Center(
                      child: Text(
                    'No payments yet',
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
