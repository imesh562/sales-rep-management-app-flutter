import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/screens/viewPayment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

User? loggedInUser;

// ignore: must_be_immutable
class ChequeDiary extends StatefulWidget {
  static String id = 'cheque_diary';
  @override
  _ChequeDiaryState createState() => _ChequeDiaryState();
}

class _ChequeDiaryState extends State<ChequeDiary> {
  bool showSpinnerDash = false;
  late StreamSubscription subscription;
  final _firestore = FirebaseFirestore.instance;

  ScrollController _scrollController = ScrollController();
  ScrollController controller = ScrollController();
  DateTime? calendarDate;
  String searchText = "";
  int orderBy = 1;
  var orderByText = 'all';
  var userRoleDiary = 'rep';

  @override
  void initState() {
    loggedInUser = FirebaseAuth.instance.currentUser;
    super.initState();
    subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      checkConnection(hasInternet, context);
    });
    getUserRole();
  }

  getUserRole() async {
    await _firestore
        .collection("users")
        .doc(loggedInUser!.uid)
        .get()
        .then((result) {
      var role = result.get('role');
      if (this.mounted)
        setState(() {
          userRoleDiary = role;
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
      appBar: appBarComponenet(mediaData, 'Cheque Diary'),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: ScrollPhysics(),
        child: ModalProgressHUD(
          inAsyncCall: showSpinnerDash,
          child: Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: mediaData.size.width * 0.03,
                    left: mediaData.size.width * 0.025,
                  ),
                  child: ClipPath(
                    clipper: ClipperCustom3(),
                    child: Container(
                      width: mediaData.size.width * 0.95,
                      height: mediaData.size.height * 0.35,
                      decoration: topCardsBG(
                        Color(0xFFCBE3FF),
                        Color(0xFF5B9FDE),
                      ),
                      child: Image.asset(
                        'assets/images/diary.png',
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: mediaData.size.height * 0.427,
                  margin: EdgeInsets.symmetric(
                      horizontal: mediaData.size.width * 0.04),
                  child: CalendarCarousel<Event>(
                    onDayPressed: (DateTime date, List<Event> events) {
                      if (this.mounted)
                        setState(() {
                          calendarDate = date;
                          _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 1000),
                              curve: Curves.easeInOut);
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
                    selectedDateTime: calendarDate,
                    daysHaveCircularBorder: false,
                    weekDayMargin: EdgeInsets.all(0),
                    weekDayPadding: EdgeInsets.all(0),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        top: mediaData.size.height * 0.01,
                        left: mediaData.size.width * 0.04,
                      ),
                      width: mediaData.size.width * 0.625,
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Search',
                          labelStyle: loginCredentials,
                          prefixIcon: Icon(
                            FontAwesomeIcons.search,
                            color: Color(0xFFcb2c64),
                          ),
                          errorStyle: TextStyle(fontSize: 12, height: 0.3),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFcb2c64),
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFcb2c64),
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
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
                    Container(
                      padding: EdgeInsets.all(10.0),
                      child: DropdownButton(
                          value: orderBy,
                          autofocus: true,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: mediaData.size.height * 0.018),
                          items: [
                            DropdownMenuItem(
                              child: Text("All"),
                              value: 1,
                            ),
                            DropdownMenuItem(
                              child: Text("Pending"),
                              value: 2,
                            ),
                            DropdownMenuItem(
                              child: Text("Returned"),
                              value: 3,
                            ),
                            DropdownMenuItem(
                              child: Text("Completed"),
                              value: 4,
                            ),
                          ],
                          onChanged: (value) {
                            if (value == 1) {
                              if (this.mounted)
                                setState(() {
                                  orderBy = 1;
                                  orderByText = 'all';
                                });
                            }
                            if (value == 2) {
                              if (this.mounted)
                                setState(() {
                                  orderBy = 2;
                                  orderByText = 'pending';
                                });
                            }
                            if (value == 3) {
                              if (this.mounted)
                                setState(() {
                                  orderBy = 3;
                                  orderByText = 'returned';
                                });
                            }
                            if (value == 4) {
                              if (this.mounted)
                                setState(() {
                                  orderBy = 4;
                                  orderByText = 'completed';
                                });
                            }
                          }),
                    ),
                  ],
                ),
                StreamBuilder<QuerySnapshot>(
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
                      if (item['status'] == 'enable' &&
                          item['payment_method'] == 'cheque') {
                        final paymentDate = item['date'];
                        final payment = item['payment'];
                        final paymentMethod = item['payment_method'];
                        final shopId = item['shop_id'];
                        final shopName = item['shop_name'];
                        final time = item['time'];
                        final repName = item['rep_name'];
                        final repID = item['rep_id'];
                        final bank = item['bank'];
                        // ignore: non_constant_identifier_names
                        final cheque_num = item['cheque_num'];
                        final withdrawDate = item['withdrawDate'];
                        final chequeStatus = item['cheque_status'];
                        final paymentID = item.reference.id;
                        final date = DateTime.fromMicrosecondsSinceEpoch(
                                withdrawDate.microsecondsSinceEpoch)
                            .toString()
                            .substring(0, 10);

                        if (orderByText == 'all') {
                          if (calendarDate == null) {
                            orderList.add(repListBuilder1(
                                paymentDate,
                                payment.toString(),
                                context,
                                paymentMethod.toString(),
                                shopId,
                                paymentID,
                                shopName,
                                time,
                                bank,
                                cheque_num,
                                date,
                                repName,
                                repID,
                                chequeStatus));
                          } else {
                            if (calendarDate.toString().substring(0, 10) ==
                                date) {
                              orderList.add(repListBuilder1(
                                  paymentDate,
                                  payment.toString(),
                                  context,
                                  paymentMethod.toString(),
                                  shopId,
                                  paymentID,
                                  shopName,
                                  time,
                                  bank,
                                  cheque_num,
                                  date,
                                  repName,
                                  repID,
                                  chequeStatus));
                            }
                          }
                        }
                        if (orderByText == "pending" &&
                            orderByText == chequeStatus) {
                          if (calendarDate == null) {
                            orderList.add(repListBuilder1(
                                paymentDate,
                                payment.toString(),
                                context,
                                paymentMethod.toString(),
                                shopId,
                                paymentID,
                                shopName,
                                time,
                                bank,
                                cheque_num,
                                date,
                                repName,
                                repID,
                                chequeStatus));
                          } else {
                            if (calendarDate.toString().substring(0, 10) ==
                                date) {
                              orderList.add(repListBuilder1(
                                  paymentDate,
                                  payment.toString(),
                                  context,
                                  paymentMethod.toString(),
                                  shopId,
                                  paymentID,
                                  shopName,
                                  time,
                                  bank,
                                  cheque_num,
                                  date,
                                  repName,
                                  repID,
                                  chequeStatus));
                            }
                          }
                        }
                        if (orderByText == "returned" &&
                            orderByText == chequeStatus) {
                          if (calendarDate == null) {
                            orderList.add(repListBuilder1(
                                paymentDate,
                                payment.toString(),
                                context,
                                paymentMethod.toString(),
                                shopId,
                                paymentID,
                                shopName,
                                time,
                                bank,
                                cheque_num,
                                date,
                                repName,
                                repID,
                                chequeStatus));
                          } else {
                            if (calendarDate.toString().substring(0, 10) ==
                                date) {
                              orderList.add(repListBuilder1(
                                  paymentDate,
                                  payment.toString(),
                                  context,
                                  paymentMethod.toString(),
                                  shopId,
                                  paymentID,
                                  shopName,
                                  time,
                                  bank,
                                  cheque_num,
                                  date,
                                  repName,
                                  repID,
                                  chequeStatus));
                            }
                          }
                        }
                        if (orderByText == "completed" &&
                            orderByText == chequeStatus) {
                          if (calendarDate == null) {
                            orderList.add(repListBuilder1(
                                paymentDate,
                                payment.toString(),
                                context,
                                paymentMethod.toString(),
                                shopId,
                                paymentID,
                                shopName,
                                time,
                                bank,
                                cheque_num,
                                date,
                                repName,
                                repID,
                                chequeStatus));
                          } else {
                            if (calendarDate.toString().substring(0, 10) ==
                                date) {
                              orderList.add(repListBuilder1(
                                  paymentDate,
                                  payment.toString(),
                                  context,
                                  paymentMethod.toString(),
                                  shopId,
                                  paymentID,
                                  shopName,
                                  time,
                                  bank,
                                  cheque_num,
                                  date,
                                  repName,
                                  repID,
                                  chequeStatus));
                            }
                          }
                        }
                      }
                    }
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      controller: controller,
                      itemCount: orderList.length,
                      itemBuilder: (context, index) {
                        return Align(
                          alignment: Alignment.topCenter,
                          child: orderList[index],
                        );
                      },
                    );
                  },
                ),
                SizedBox(
                  height: mediaData.size.height * 0.02,
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
                                  calendarDate = null;
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
      ),
    );
  }

  Stream<QuerySnapshot> searchData() async* {
    if (searchText != "" && calendarDate != null) {
      var _search = _firestore
          .collection('payments')
          .where('shop_name', isGreaterThanOrEqualTo: searchText)
          .where('shop_name', isLessThan: searchText + 'z')
          .orderBy('shop_name', descending: false)
          .snapshots();
      yield* _search;
    }

    if (searchText != "" && calendarDate == null) {
      var _search = _firestore
          .collection('payments')
          .where('shop_name', isGreaterThanOrEqualTo: searchText)
          .where('shop_name', isLessThan: searchText + 'z')
          .orderBy('shop_name', descending: false)
          .snapshots();
      yield* _search;
    }

    if (calendarDate != null && searchText == "") {
      var _search1 = _firestore
          .collection('payments')
          .orderBy('date', descending: false)
          .orderBy('time', descending: false)
          .snapshots();
      yield* _search1;
    }

    if (searchText == "" && calendarDate == null) {
      var _search2 = _firestore
          .collection('payments')
          .orderBy('date', descending: false)
          .orderBy('time', descending: false)
          .snapshots();
      yield* _search2;
    }
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
            userRoleDiary,
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
                'Bank \t\t\t\t\t\t\t\t\t\t\t\t\t\t\t : ' + bank,
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.02,
                  fontFamily: 'Exo2',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 14.0),
              child: Text(
                'Amount \t\t\t\t\t\t\t\t\t\t  : $payment',
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.02,
                  fontFamily: 'Exo2',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 1.0, left: 14.0),
              child: Text(
                'Withdraw Date \t: ' +
                    (withdrawDate.toString()).substring(0, 10),
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
