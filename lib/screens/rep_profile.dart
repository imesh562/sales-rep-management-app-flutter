import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/data.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/components/get_sections.dart';
import 'package:dk_brothers/components/indicators_widget.dart';
import 'package:dk_brothers/components/profile_widget.dart';
import 'package:dk_brothers/components/rep_profile_pie.dart';
import 'package:dk_brothers/components/user.dart';
import 'package:dk_brothers/screens/rep_profile_assign_history.dart';
import 'package:dk_brothers/screens/rep_profile_payments.dart';
import 'package:dk_brothers/screens/rep_profile_sales.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'edit_profile.dart';
import 'line_titles.dart';

User? loggedInUser1;

// ignore: must_be_immutable
class RepProfile extends StatefulWidget {
  static String id = 'rep_profile';
  var repID;

  RepProfile(
    this.repID,
  );
  @override
  _RepProfileState createState() => _RepProfileState();
}

class _RepProfileState extends State<RepProfile> {
  late StreamSubscription subscription;
  bool showSpinner = false;
  final _firestore = FirebaseFirestore.instance;
  int touchedIndex = -1;
  List<Data> alldata = [];
  List<Data> alldata2 = [];
  ScrollController controller = ScrollController();
  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  String chartType = 'Monthly';
  Color btnColor1 = Color(0xFF79CCCA);
  Color btnColor2 = Colors.black;
  Color btnColor3 = Colors.black;
  List<FlSpot> chartData = [];
  bool chartSpinner = false;
  late int activeIndex = 0;
  String name = '';
  String email = '';
  String telNumber = '';
  String repStatus = '';
  String imgURL = '';
  String repRole = '';
  bool showTab = false;

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
    if (this.mounted)
      setState(() {
        showSpinner = true;
        chartSpinner = true;
      });
    RepProfilePieData obj1 = RepProfilePieData();
    await obj1.getRepPie(widget.repID);
    await obj1.getItemNames();
    RepProfilePieData2 obj2 = RepProfilePieData2();
    await obj2.getRepPie(widget.repID);
    await obj2.getItemNames();
    await getData();
    await getUserData();
    if (this.mounted)
      setState(() {
        alldata = obj1.allReps();
        alldata2 = obj2.allShops();
        showSpinner = false;
        chartSpinner = false;
      });
  }

  getUserData() async {
    await _firestore.collection("users").doc(widget.repID).get().then((result) {
      if (this.mounted)
        setState(() {
          name = result.get('name');
          email = result.get('email');
          telNumber = result.get('mobile_num');
          repStatus = result.get('status');
          imgURL = result.get('img_url');
          repRole = result.get('role');
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
    UserProfile user = UserProfile(imgURL, name, email, telNumber, repStatus);
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        body: SingleChildScrollView(
          controller: controller,
          child: Container(
            child: Column(
              children: [
                SizedBox(
                  height: mediaData.size.height * 0.05,
                ),
                SizedBox(
                  height: mediaData.size.height * 0.335,
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: [
                      ProfileWidget(
                        imagePath: user.imagePath,
                        onClicked: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(
                                  widget.repID,
                                  name,
                                  email,
                                  telNumber,
                                  imgURL,
                                  repRole),
                            ),
                          );
                          setState(() {
                            waitingList();
                          });
                        },
                      ),
                      SizedBox(
                        height: mediaData.size.height * 0.01,
                      ),
                      buildName(user, mediaData),
                    ],
                  ),
                ),
                SizedBox(
                  height: mediaData.size.height * 0.02,
                ),
                CarouselSlider(
                  items: [
                    carouselList3(mediaData),
                    carouselList2(mediaData),
                    carouselList(mediaData)
                  ],
                  options: CarouselOptions(
                      height: mediaData.size.height * 0.79,
                      pageSnapping: true,
                      enableInfiniteScroll: false,
                      autoPlay: false,
                      enlargeCenterPage: true,
                      viewportFraction: 0.9,
                      aspectRatio: 2.0,
                      onPageChanged: (index, reason) {
                        if (this.mounted)
                          setState(() {
                            activeIndex = index;
                          });
                      }),
                ),
                SizedBox(
                  height: mediaData.size.height * 0.01,
                ),
                buildIndicator(),
                SizedBox(
                  height: mediaData.size.height * 0.02,
                ),
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Color(0xFF79CCCA), spreadRadius: 3),
                        ],
                      ),
                      margin: EdgeInsets.symmetric(
                          horizontal: mediaData.size.width * 0.04),
                      child: ListTile(
                        leading: Icon(
                          Icons.history,
                          color: Colors.black,
                        ),
                        title: Text(
                          'Rep Sales',
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          pushNewScreenWithRouteSettings(
                            context,
                            settings: RouteSettings(
                              name: RepProfileSales.id,
                            ),
                            screen: RepProfileSales(widget.repID, name),
                            withNavBar: true,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: mediaData.size.height * 0.02,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Color(0xFF79CCCA), spreadRadius: 3),
                        ],
                      ),
                      margin: EdgeInsets.symmetric(
                          horizontal: mediaData.size.width * 0.04),
                      child: ListTile(
                        leading: Icon(
                          Icons.payment,
                          color: Colors.black,
                        ),
                        title: Text(
                          'Payments Collected',
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          pushNewScreenWithRouteSettings(
                            context,
                            settings: RouteSettings(
                              name: RepProfilePayments.id,
                            ),
                            screen: RepProfilePayments(widget.repID, name),
                            withNavBar: true,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: mediaData.size.height * 0.02,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Color(0xFF79CCCA), spreadRadius: 3),
                        ],
                      ),
                      margin: EdgeInsets.symmetric(
                          horizontal: mediaData.size.width * 0.04),
                      child: ListTile(
                        leading: Icon(
                          Icons.calendar_today,
                          color: Colors.black,
                        ),
                        title: Text(
                          'Daily Assigned Items',
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          pushNewScreenWithRouteSettings(
                            context,
                            settings: RouteSettings(
                              name: AssignHistory.id,
                            ),
                            screen: AssignHistory(widget.repID, name),
                            withNavBar: true,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: mediaData.size.height * 0.03,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget carouselList(mediaData) {
    List months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'Octomber',
      'November',
      'December'
    ];
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (chartType == 'Monthly')
              Container(
                margin: EdgeInsets.only(bottom: mediaData.size.height * 0.01),
                child: Text(
                  'Sales of year ' + today.year.toString(),
                  style: krepReg.copyWith(
                    color: Colors.black,
                    fontSize: mediaData.size.height * 0.032,
                  ),
                ),
              ),
            if (chartType == 'Weekly')
              Container(
                margin: EdgeInsets.only(bottom: mediaData.size.height * 0.01),
                child: Text(
                  'Sales of ' + months[today.month - 1],
                  style: krepReg.copyWith(
                    color: Colors.black,
                    fontSize: mediaData.size.height * 0.032,
                  ),
                ),
              ),
            if (chartType == 'Daily')
              Container(
                margin: EdgeInsets.only(bottom: mediaData.size.height * 0.01),
                child: Text(
                  'Sales of ' +
                      months[today.month - 1] +
                      ' week ' +
                      getWeekOfMonth(today.toString()).toString(),
                  style: krepReg.copyWith(
                    color: Colors.black,
                    fontSize: mediaData.size.height * 0.032,
                  ),
                ),
              ),
            Container(
              padding: EdgeInsets.only(
                right: mediaData.size.width * 0.06,
                top: mediaData.size.height * 0.05,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Color(0xFF79CCCA), spreadRadius: 3),
                ],
              ),
              width: mediaData.size.width,
              height: mediaData.size.height * 0.59,
              child: chartSpinner
                  ? Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Color(0xFF79CCCA),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: maxX(),
                        minY: 0,
                        maxY: 5,
                        titlesData:
                            LineTitles.titlesShopProfile(mediaData, chartType),
                        gridData: FlGridData(
                          show: true,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: const Color(0xff37434d),
                              strokeWidth: 1,
                            );
                          },
                          drawVerticalLine: true,
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: const Color(0xff37434d),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                              color: const Color(0xff37434d), width: 1),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: chartData,
                            isCurved: false,
                            colors: gradientColors,
                            barWidth: 5,
                            belowBarData: BarAreaData(
                              show: true,
                              colors: gradientColors
                                  .map((color) => color.withOpacity(0.3))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            SizedBox(
              height: mediaData.size.height * 0.015,
            ),
            Container(
              margin:
                  EdgeInsets.symmetric(horizontal: mediaData.size.width * 0.1),
              padding: EdgeInsets.symmetric(
                horizontal: mediaData.size.width * 0.06,
                vertical: mediaData.size.height * 0.01,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(mediaData.size.width * 0.1),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Color(0xFF79CCCA), spreadRadius: 3),
                ],
              ),
              child: AbsorbPointer(
                absorbing: showTab,
                child: Opacity(
                  opacity: showTab ? 0.5 : 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (this.mounted)
                            setState(() {
                              btnColor1 = Color(0xFF79CCCA);
                              btnColor2 = Colors.black;
                              btnColor3 = Colors.black;
                              chartType = 'Monthly';
                            });
                          getData();
                        },
                        child: Text(
                          'Monthly',
                          style: TextStyle(
                            fontFamily: 'Exo2',
                            fontSize: mediaData.size.height * 0.023,
                            fontWeight: FontWeight.bold,
                            color: btnColor1,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (this.mounted)
                            setState(() {
                              btnColor1 = Colors.black;
                              btnColor2 = Color(0xFF79CCCA);
                              btnColor3 = Colors.black;
                              chartType = 'Weekly';
                            });
                          getData();
                        },
                        child: Text(
                          'Weekly',
                          style: TextStyle(
                            fontFamily: 'Exo2',
                            fontSize: mediaData.size.height * 0.023,
                            fontWeight: FontWeight.bold,
                            color: btnColor2,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (this.mounted)
                            setState(() {
                              btnColor1 = Colors.black;
                              btnColor2 = Colors.black;
                              btnColor3 = Color(0xFF79CCCA);
                              chartType = 'Daily';
                            });
                          getData();
                        },
                        child: Text(
                          'Daily',
                          style: TextStyle(
                            fontFamily: 'Exo2',
                            fontSize: mediaData.size.height * 0.023,
                            fontWeight: FontWeight.bold,
                            color: btnColor3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getData() async {
    if (this.mounted)
      setState(() {
        showTab = true;
      });
    chartData.clear();
    double jan = 0;
    double feb = 0;
    double mar = 0;
    double apr = 0;
    double may = 0;
    double jun = 0;
    double jul = 0;
    double aug = 0;
    double sep = 0;
    double oct = 0;
    double nov = 0;
    double dec = 0;
    double w1 = 0;
    double w2 = 0;
    double w3 = 0;
    double w4 = 0;
    double w5 = 0;
    double d1 = 0;
    double d2 = 0;
    double d3 = 0;
    double d4 = 0;
    double d5 = 0;
    double d6 = 0;
    double d7 = 0;
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    QuerySnapshot querySnapshot = await _firestore
        .collection("orders")
        .where('status', isEqualTo: 'enable')
        .where('rep_id', isEqualTo: widget.repID)
        .get();

    QuerySnapshot totalSnap = await _firestore.collection("order_items").get();
    if (querySnapshot.docs.length > 0) {
      if (chartType == 'Monthly') {
        for (int i = 0; i < querySnapshot.docs.length; i++) {
          var a = querySnapshot.docs[i];
          if (date.toString().substring(0, 4) ==
              a['date'].toString().substring(0, 4)) {
            var total = 0.0;
            var discountedTotal = 0.0;
            for (int i = 0; i < totalSnap.docs.length; i++) {
              var doc = totalSnap.docs[i];
              if (doc['order_id'] == a.reference.id) {
                total += doc['price'] * doc['quantity'];
                discountedTotal += (doc['price'] * doc['quantity']) -
                    ((doc['discount'] / 100) *
                        (doc['price'] * doc['quantity']));
              }
            }
            if (a['date'].toString().substring(5, 7) == '01') {
              if (discountedTotal < total && discountedTotal > 0) {
                jan += discountedTotal;
              } else {
                jan += total;
              }
            }
            if (a['date'].toString().substring(5, 7) == '02') {
              if (discountedTotal < total && discountedTotal > 0) {
                feb += discountedTotal;
              } else {
                feb += total;
              }
            }
            if (a['date'].toString().substring(5, 7) == '03') {
              if (discountedTotal < total && discountedTotal > 0) {
                mar += discountedTotal;
              } else {
                mar += total;
              }
            }
            if (a['date'].toString().substring(5, 7) == '04') {
              if (discountedTotal < total && discountedTotal > 0) {
                apr += discountedTotal;
              } else {
                apr += total;
              }
            }
            if (a['date'].toString().substring(5, 7) == '05') {
              if (discountedTotal < total && discountedTotal > 0) {
                may += discountedTotal;
              } else {
                may += total;
              }
            }
            if (a['date'].toString().substring(5, 7) == '06') {
              if (discountedTotal < total && discountedTotal > 0) {
                jun += discountedTotal;
              } else {
                jun += total;
              }
            }
            if (a['date'].toString().substring(5, 7) == '07') {
              if (discountedTotal < total && discountedTotal > 0) {
                jul += discountedTotal;
              } else {
                jul += total;
              }
            }
            if (a['date'].toString().substring(5, 7) == '08') {
              if (discountedTotal < total && discountedTotal > 0) {
                aug += discountedTotal;
              } else {
                aug += total;
              }
            }
            if (a['date'].toString().substring(5, 7) == '09') {
              if (discountedTotal < total && discountedTotal > 0) {
                sep += discountedTotal;
              } else {
                sep += total;
              }
            }
            if (a['date'].toString().substring(5, 7) == '10') {
              if (discountedTotal < total && discountedTotal > 0) {
                oct += discountedTotal;
              } else {
                oct += total;
              }
            }
            if (a['date'].toString().substring(5, 7) == '11') {
              if (discountedTotal < total && discountedTotal > 0) {
                nov += discountedTotal;
              } else {
                nov += total;
              }
            }
            if (a['date'].toString().substring(5, 7) == '12') {
              if (discountedTotal < total && discountedTotal > 0) {
                dec += discountedTotal;
              } else {
                dec += total;
              }
            }
          }
        }
        if (this.mounted)
          setState(() {
            chartData.add(FlSpot(0, jan / 10000));
            chartData.add(FlSpot(1, feb / 10000));
            chartData.add(FlSpot(2, mar / 10000));
            chartData.add(FlSpot(3, apr / 10000));
            chartData.add(FlSpot(4, may / 10000));
            chartData.add(FlSpot(5, jun / 10000));
            chartData.add(FlSpot(6, jul / 10000));
            chartData.add(FlSpot(7, aug / 10000));
            chartData.add(FlSpot(8, sep / 10000));
            chartData.add(FlSpot(9, oct / 10000));
            chartData.add(FlSpot(10, nov / 10000));
            chartData.add(FlSpot(11, dec / 10000));
          });
      }
      if (chartType == 'Weekly') {
        for (int i = 0; i < querySnapshot.docs.length; i++) {
          var a = querySnapshot.docs[i];
          if (date.toString().substring(0, 7) ==
              a['date'].toString().substring(0, 7)) {
            var total = 0.0;
            var discountedTotal = 0.0;
            for (int i = 0; i < totalSnap.docs.length; i++) {
              var doc = totalSnap.docs[i];
              if (doc['order_id'] == a.reference.id) {
                total += doc['price'] * doc['quantity'];
                discountedTotal += (doc['price'] * doc['quantity']) -
                    ((doc['discount'] / 100) *
                        (doc['price'] * doc['quantity']));
              }
            }
            if (getWeekOfMonth(a['date']) == 1) {
              if (discountedTotal < total && discountedTotal > 0) {
                w1 += discountedTotal;
              } else {
                w1 += total;
              }
            }
            if (getWeekOfMonth(a['date']) == 2) {
              if (discountedTotal < total && discountedTotal > 0) {
                w2 += discountedTotal;
              } else {
                w2 += total;
              }
            }
            if (getWeekOfMonth(a['date']) == 3) {
              if (discountedTotal < total && discountedTotal > 0) {
                w3 += discountedTotal;
              } else {
                w3 += total;
              }
            }
            if (getWeekOfMonth(a['date']) == 4) {
              if (discountedTotal < total && discountedTotal > 0) {
                w4 += discountedTotal;
              } else {
                w4 += total;
              }
            }
            if (getWeekOfMonth(a['date']) == 5) {
              if (discountedTotal < total && discountedTotal > 0) {
                w5 += discountedTotal;
              } else {
                w5 += total;
              }
            }
          }
        }
        if (this.mounted)
          setState(() {
            chartData.add(FlSpot(0, w1 / 5000));
            chartData.add(FlSpot(1, w2 / 5000));
            chartData.add(FlSpot(2, w3 / 5000));
            chartData.add(FlSpot(3, w4 / 5000));
            chartData.add(FlSpot(4, w5 / 5000));
          });
      }
      if (chartType == 'Daily') {
        for (int i = 0; i < querySnapshot.docs.length; i++) {
          var a = querySnapshot.docs[i];
          if (date.toString().substring(0, 7) ==
              a['date'].toString().substring(0, 7)) {
            var total = 0.0;
            var discountedTotal = 0.0;
            for (int i = 0; i < totalSnap.docs.length; i++) {
              var doc = totalSnap.docs[i];
              if (doc['order_id'] == a.reference.id) {
                total += doc['price'] * doc['quantity'];
                discountedTotal += (doc['price'] * doc['quantity']) -
                    ((doc['discount'] / 100) *
                        (doc['price'] * doc['quantity']));
              }
            }
            int weekDay = date.weekday;
            DateTime startWeek = date.subtract(Duration(days: weekDay));

            if (a['date'] == startWeek.toString().substring(0, 10)) {
              if (discountedTotal < total && discountedTotal > 0) {
                d1 += discountedTotal;
              } else {
                d1 += total;
              }
            }
            if (a['date'] ==
                startWeek.add(Duration(days: 1)).toString().substring(0, 10)) {
              if (discountedTotal < total && discountedTotal > 0) {
                d2 += discountedTotal;
              } else {
                d2 += total;
              }
            }
            if (a['date'] ==
                startWeek.add(Duration(days: 2)).toString().substring(0, 10)) {
              if (discountedTotal < total && discountedTotal > 0) {
                d3 += discountedTotal;
              } else {
                d3 += total;
              }
            }
            if (a['date'] ==
                startWeek.add(Duration(days: 3)).toString().substring(0, 10)) {
              if (discountedTotal < total && discountedTotal > 0) {
                d4 += discountedTotal;
              } else {
                d4 += total;
              }
            }
            if (a['date'] ==
                startWeek.add(Duration(days: 4)).toString().substring(0, 10)) {
              if (discountedTotal < total && discountedTotal > 0) {
                d5 += discountedTotal;
              } else {
                d5 += total;
              }
            }
            if (a['date'] ==
                startWeek.add(Duration(days: 5)).toString().substring(0, 10)) {
              if (discountedTotal < total && discountedTotal > 0) {
                d6 += discountedTotal;
              } else {
                d6 += total;
              }
            }
            if (a['date'] ==
                startWeek.add(Duration(days: 6)).toString().substring(0, 10)) {
              if (discountedTotal < total && discountedTotal > 0) {
                d7 += discountedTotal;
              } else {
                d7 += total;
              }
            }
          }
        }
        if (this.mounted)
          setState(() {
            chartData.add(FlSpot(0, d1 / 2000));
            chartData.add(FlSpot(1, d2 / 2000));
            chartData.add(FlSpot(2, d3 / 2000));
            chartData.add(FlSpot(3, d4 / 2000));
            chartData.add(FlSpot(4, d5 / 2000));
            chartData.add(FlSpot(5, d6 / 2000));
            chartData.add(FlSpot(6, d7 / 2000));
          });
      }
    }
    if (this.mounted)
      setState(() {
        showTab = false;
      });
  }

  maxX() {
    if (chartType == 'Monthly') {
      return 11.0;
    }
    if (chartType == 'Weekly') {
      return 4.0;
    }
    if (chartType == 'Daily') {
      return 6.0;
    }
  }

  getWeekOfMonth(String date) {
    String firstDay = date.substring(0, 8) + '01' + date.substring(10);
    int weekDay = DateTime.parse(firstDay).weekday;
    DateTime testDate = DateTime.parse(date);
    int weekOfMonth;
    weekDay--;
    weekOfMonth = ((testDate.day + weekDay) / 7).ceil();
    weekDay++;
    if (weekDay == 7) {
      weekDay = 0;
    }
    weekOfMonth = ((testDate.day + weekDay) / 7).ceil();
    return weekOfMonth;
  }

  Widget carouselList2(MediaQueryData mediaData) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: mediaData.size.height * 0.01),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(mediaData.size.width * 0.1),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0xFF79CCCA), spreadRadius: 3),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                  top: mediaData.size.height * 0.02,
                  bottom: mediaData.size.height * 0.04),
              child: Column(
                children: [
                  Text(
                    'Most Sold Items',
                    style: krepReg.copyWith(
                      color: Color(0xff505050),
                      fontSize: mediaData.size.height * 0.032,
                    ),
                  ),
                  Text(
                    '(By Quantity)',
                    style: krepReg.copyWith(
                      color: Color(0xff505050),
                      fontSize: mediaData.size.height * 0.032,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: mediaData.size.height * 0.38,
              width: mediaData.size.width * 0.73,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (flTouchEvent, pieTouchResponse) {
                      if (this.mounted)
                        setState(() {
                          if (pieTouchResponse != null) {
                            if (pieTouchResponse.touchedSection!
                                    .touchedSectionIndex is FlLongPressEnd ||
                                pieTouchResponse.touchedSection!
                                    .touchedSectionIndex is FlPanEndEvent) {
                              touchedIndex = -1;
                            } else {
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            }
                          }
                        });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: mediaData.size.width * 0.1,
                  sections: getSections(touchedIndex, alldata, mediaData),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: mediaData.size.height * 0.035,
                  ),
                  child: IndicatorsWidget(alldata, mediaData, false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget carouselList3(MediaQueryData mediaData) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(mediaData.size.width * 0.1),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0xFF79CCCA), spreadRadius: 3),
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: mediaData.size.height * 0.01),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                  top: mediaData.size.height * 0.02,
                  bottom: mediaData.size.height * 0.04),
              child: Column(
                children: [
                  Text(
                    'Best Selling Shops',
                    style: krepReg.copyWith(
                      color: Color(0xff505050),
                      fontSize: mediaData.size.height * 0.032,
                    ),
                  ),
                  Text(
                    '(By Value)',
                    style: krepReg.copyWith(
                      color: Color(0xff505050),
                      fontSize: mediaData.size.height * 0.032,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: mediaData.size.height * 0.38,
              width: mediaData.size.width * 0.73,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (flTouchEvent, pieTouchResponse) {
                      if (this.mounted)
                        setState(() {
                          if (pieTouchResponse != null) {
                            if (pieTouchResponse.touchedSection!
                                    .touchedSectionIndex is FlLongPressEnd ||
                                pieTouchResponse.touchedSection!
                                    .touchedSectionIndex is FlPanEndEvent) {
                              touchedIndex = -1;
                            } else {
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            }
                          }
                        });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: mediaData.size.width * 0.1,
                  sections: getSections(touchedIndex, alldata2, mediaData),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: mediaData.size.height * 0.035,
                  ),
                  child: IndicatorsWidget(alldata2, mediaData, false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIndicator() {
    return AnimatedSmoothIndicator(
      activeIndex: activeIndex,
      count: 3,
      effect: JumpingDotEffect(),
    );
  }

  buildName(UserProfile user, MediaQueryData mediaData) {
    return Column(
      children: [
        Text(
          user.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: mediaData.size.height * 0.035,
            fontFamily: 'Exo2',
          ),
        ),
        SizedBox(
          height: mediaData.size.height * 0.005,
        ),
        Text(
          user.email,
          style: TextStyle(
            color: Colors.grey,
            fontFamily: 'Exo2',
            fontSize: mediaData.size.height * 0.0225,
          ),
        ),
        SizedBox(
          height: mediaData.size.height * 0.005,
        ),
        Text(
          user.tel,
          style: TextStyle(
            color: Colors.grey,
            fontFamily: 'Exo2',
            fontSize: mediaData.size.height * 0.0225,
          ),
        ),
      ],
    );
  }
}
