import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/data.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/components/get_sections.dart';
import 'package:dk_brothers/components/indicators_widget.dart';
import 'package:dk_brothers/components/item_profile_pie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'line_titles.dart';

User? loggedInUser1;

// ignore: must_be_immutable
class ItemProfile extends StatefulWidget {
  static String id = 'rep_profile';
  var name;
  var price;
  var status;
  var itemID;

  ItemProfile(
    this.name,
    this.price,
    this.status,
    this.itemID,
  );
  @override
  _ItemProfileState createState() => _ItemProfileState();
}

class _ItemProfileState extends State<ItemProfile> {
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
  Color btnColor1 = Color(0xFF955545);
  Color btnColor2 = Colors.black;
  Color btnColor3 = Colors.black;
  List<FlSpot> chartData = [];
  bool chartSpinner = false;
  late int activeIndex = 0;
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
    ItemProfilePieData obj1 = ItemProfilePieData();
    await obj1.getRepPie(widget.itemID);
    await obj1.getItemNames();
    ItemProfilePieData2 obj2 = ItemProfilePieData2();
    await obj2.getRepPie(widget.itemID);
    await obj2.getItemNames();
    await getData();
    if (this.mounted)
      setState(() {
        alldata = obj1.allReps();
        alldata2 = obj2.allShops();
        showSpinner = false;
        chartSpinner = false;
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
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        extendBodyBehindAppBar: false,
        body: SingleChildScrollView(
          controller: controller,
          child: Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: mediaData.size.width * 0.1,
                    left: mediaData.size.width * 0.025,
                  ),
                  child: ClipPath(
                    clipper: ClipperCustom3(),
                    child: Container(
                      width: mediaData.size.width * 0.95,
                      height: mediaData.size.height * 0.4,
                      decoration: shopProfile(
                        'assets/images/bakeryBG.jpg',
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.name,
                            style: TextStyle(
                              fontSize: mediaData.size.height * 0.05,
                              fontFamily: 'Exo2',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF955545),
                            ),
                          ),
                          SizedBox(
                            height: mediaData.size.height * 0.0025,
                          ),
                          Text(
                            'Price: Rs.' + widget.price,
                            style: TextStyle(
                              fontSize: mediaData.size.height * 0.025,
                              fontFamily: 'Exo2',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF955545),
                            ),
                          ),
                          SizedBox(
                            height: mediaData.size.height * 0.0025,
                          ),
                          Text(
                            'Status: ' + widget.status,
                            style: TextStyle(
                              fontSize: mediaData.size.height * 0.025,
                              fontFamily: 'Exo2',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF955545),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                borderRadius: BorderRadius.circular(mediaData.size.width * 0.1),
                color: Color(0xfff8e9d2),
                boxShadow: [
                  BoxShadow(color: Color(0xFF955545), spreadRadius: 3),
                ],
              ),
              width: mediaData.size.width,
              height: mediaData.size.height * 0.59,
              child: chartSpinner
                  ? Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        backgroundColor: Color(0xfff8e9d2),
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
              height: mediaData.size.height * 0.01,
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
                color: Color(0xfff8e9d2),
                boxShadow: [
                  BoxShadow(color: Color(0xFF955545), spreadRadius: 3),
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
                              btnColor1 = Color(0xFF955545);
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
                              btnColor2 = Color(0xFF955545);
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
                              btnColor3 = Color(0xFF955545);
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
        .get();
    QuerySnapshot totalSnap = await _firestore
        .collection("order_items")
        .where('item_id', isEqualTo: widget.itemID)
        .get();
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
        color: Color(0xfff8e9d2),
        boxShadow: [
          BoxShadow(color: Color(0xFF955545), spreadRadius: 3),
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
                    'Top Sellers of this Item',
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
      margin: EdgeInsets.symmetric(vertical: mediaData.size.height * 0.01),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(mediaData.size.width * 0.1),
        color: Color(0xfff8e9d2),
        boxShadow: [
          BoxShadow(color: Color(0xFF955545), spreadRadius: 3),
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
                    'Top Buyers of this Item.',
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
}
