import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;

User? loggedInUser;

// ignore: must_be_immutable
class AssignHistory extends StatefulWidget {
  static String id = 'rep_profile_assign_history';
  var repID;
  var name;

  AssignHistory(this.repID, this.name);
  @override
  _AssignHistoryState createState() => _AssignHistoryState();
}

class _AssignHistoryState extends State<AssignHistory> {
  bool showSpinnerDash = false;
  late StreamSubscription subscription;
  final _firestore = FirebaseFirestore.instance;
  ScrollController controller = ScrollController();
  DateTime? selectedDate;
  var userRoleDash = 'admin';
  bool closeTopContainers = false;
  Map itemList = {};
  static var minValues = new Map();
  bool showTab = false;

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
    waitingList();
  }

  waitingList() async {
    if (this.mounted)
      setState(() {
        showSpinnerDash = true;
      });
    await getDocs();
    await minItems();
    if (this.mounted)
      setState(() {
        showSpinnerDash = false;
      });
  }

  minItems() async {
    minValues.clear();
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    QuerySnapshot querySnapshot = await _firestore
        .collection("orders")
        .where('date', isEqualTo: today.toString().substring(0, 10))
        .where('rep_id', isEqualTo: widget.repID)
        .get();
    if (querySnapshot.docs.length > 0) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        var a = querySnapshot.docs[i];
        QuerySnapshot totalSnap = await _firestore
            .collection("order_items")
            .where('order_id', isEqualTo: a.reference.id)
            .get();
        for (int i = 0; i < totalSnap.docs.length; i++) {
          var doc = totalSnap.docs[i];
          if (minValues.containsKey(doc['item_id'])) {
            minValues.update(
                doc['item_id'], (dynamic val) => val + doc['quantity']);
          } else {
            minValues[doc['item_id']] = doc['quantity'];
          }
        }
      }
    }
  }

  minItemsSelectedDate(String selDate) async {
    minValues.clear();
    QuerySnapshot querySnapshot = await _firestore
        .collection("orders")
        .where('date', isEqualTo: selDate)
        .where('rep_id', isEqualTo: widget.repID)
        .get();
    if (querySnapshot.docs.length > 0) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        var a = querySnapshot.docs[i];
        QuerySnapshot totalSnap = await _firestore
            .collection("order_items")
            .where('order_id', isEqualTo: a.reference.id)
            .get();
        for (int i = 0; i < totalSnap.docs.length; i++) {
          var doc = totalSnap.docs[i];
          if (minValues.containsKey(doc['item_id'])) {
            minValues.update(
                doc['item_id'], (dynamic val) => val + doc['quantity']);
          } else {
            minValues[doc['item_id']] = doc['quantity'];
          }
        }
      }
    }
  }

  getDocs() async {
    QuerySnapshot querySnapshot = await _firestore.collection("items").get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      var a = querySnapshot.docs[i];
      itemList[a.reference.id] = a['name'];
    }
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
              AbsorbPointer(
                absorbing: showTab,
                child: Opacity(
                  opacity: showTab ? 0.5 : 1,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: closeTopContainers ? 0 : 1,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: mediaData.size.width,
                      alignment: Alignment.topCenter,
                      height: closeTopContainers
                          ? 0
                          : mediaData.size.height * 0.427,
                      child: Container(
                        height: mediaData.size.height * 0.427,
                        margin: EdgeInsets.symmetric(
                            horizontal: mediaData.size.width * 0.04),
                        child: CalendarCarousel<Event>(
                          onDayPressed:
                              (DateTime date, List<Event> events) async {
                            if (this.mounted)
                              setState(() {
                                showTab = true;
                                selectedDate = date;
                              });
                            await minItemsSelectedDate(
                                selectedDate.toString().substring(0, 10));
                            if (this.mounted)
                              setState(() {
                                showTab = false;
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
                            'Today Items',
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
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('daily_items')
          .where('rep_id', isEqualTo: widget.repID)
          .orderBy('date', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final dailyItems = snapshot.data!.docs.reversed;
        List<Widget> orderList = [];
        for (var item in dailyItems) {
          final assignedDate = item['date'];
          final itemID = item['item_id'];
          final quantity = item['quantity'];
          final asiignID = item.reference.id;

          if (selectedDate != null) {
            if (selectedDate.toString().substring(0, 10) == assignedDate) {
              orderList.add(
                repListBuilder(
                  assignedDate,
                  context,
                  itemID,
                  asiignID,
                  quantity,
                  userRoleDash,
                  minValues.containsKey(itemID) ? minValues[itemID] : '0',
                ),
              );
            }
          } else {
            if (assignedDate == today.toString().substring(0, 10)) {
              orderList.add(
                repListBuilder(
                  today.toString().substring(0, 10),
                  context,
                  itemID,
                  asiignID,
                  quantity,
                  userRoleDash,
                  minValues.containsKey(itemID) ? minValues[itemID] : '0',
                ),
              );
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
                    'No Items Assigned',
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
    assignedDate,
    context,
    itemID,
    asiignID,
    quantity,
    userRoleDash,
    minValue,
  ) {
    final mediaData = MediaQuery.of(context);

    return Container(
      margin: EdgeInsets.only(top: mediaData.size.height * 0.015),
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
            child: Text(
              itemList[itemID] == null ? '' : itemList[itemID],
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
              'Date \t\t\t\t\t\t\t: ' + assignedDate.substring(0, 10),
              style: TextStyle(
                fontSize: mediaData.size.height * 0.02,
                fontFamily: 'Exo2',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1.0, left: 14.0),
            child: Text(
              'Quantity \t: ' + quantity.toString(),
              style: TextStyle(
                fontSize: mediaData.size.height * 0.02,
                fontFamily: 'Exo2',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1.0, left: 14.0),
            child: Text(
              'Sold \t: ' + minValue.toString(),
              style: TextStyle(
                fontSize: mediaData.size.height * 0.02,
                fontFamily: 'Exo2',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
