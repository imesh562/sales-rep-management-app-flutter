import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/screens/item_overview.dart';
import 'package:dk_brothers/screens/rep_analysis.dart';
import 'package:dk_brothers/screens/shop_analysis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'line_titles.dart';

User? loggedInUser;
final _firestore = FirebaseFirestore.instance;

class Analysis extends StatefulWidget {
  static String id = 'analysis';
  @override
  _AnalysisState createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {
  bool showSpinner = false;
  bool chartSpinner = false;
  late StreamSubscription subscription;
  int items = 0;
  int shops = 0;
  int users = 0;
  String chartType = 'Monthly';
  Color btnColor1 = Color(0xff02d39a);
  Color btnColor2 = Colors.white;
  Color btnColor3 = Colors.white;
  List<FlSpot> chartData = [];
  RefreshController refreshCon = RefreshController();
  bool showTab = false;

  @override
  void initState() {
    super.initState();
    subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      checkConnection(hasInternet, context);
    });
    waitingList();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  @override
  Widget build(BuildContext context) {
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
    final mediaData = MediaQuery.of(context);
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: appBarComponenet(mediaData, 'Analysis'),
      body: SmartRefresher(
        onRefresh: waitingList,
        controller: refreshCon,
        child: Container(
          margin: EdgeInsets.symmetric(
            vertical: mediaData.size.height * 0.01,
            horizontal: mediaData.size.width * 0.04,
          ),
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
                  borderRadius:
                      BorderRadius.circular(mediaData.size.width * 0.1),
                  color: Color(0xff010429),
                ),
                width: mediaData.size.width,
                height: mediaData.size.height * 0.485,
                child: chartSpinner
                    ? Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.lightBlueAccent,
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          backgroundColor: Color(0xff010429),
                          minX: 0,
                          maxX: maxX(),
                          minY: 0,
                          maxY: 5,
                          titlesData:
                              LineTitles.getTitleData(mediaData, chartType),
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
                height: mediaData.size.height * 0.005,
              ),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: mediaData.size.width * 0.1),
                padding: EdgeInsets.symmetric(
                  horizontal: mediaData.size.width * 0.06,
                  vertical: mediaData.size.height * 0.01,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(mediaData.size.width * 0.1),
                  color: Color(0xff010429),
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
                                btnColor1 = Color(0xff02d39a);
                                btnColor2 = Colors.white;
                                btnColor3 = Colors.white;
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
                                btnColor1 = Colors.white;
                                btnColor2 = Color(0xff02d39a);
                                btnColor3 = Colors.white;
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
                                btnColor1 = Colors.white;
                                btnColor2 = Colors.white;
                                btnColor3 = Color(0xff02d39a);
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
              SizedBox(
                height: mediaData.size.height * 0.01,
              ),
              Row(
                children: [
                  DashItem(
                    mediaData,
                    'Total\nReps',
                    users,
                    'rep',
                  ),
                  SizedBox(
                    width: mediaData.size.width * 0.01,
                  ),
                  DashItem(
                    mediaData,
                    'Total\nShops',
                    shops,
                    'shop',
                  ),
                  SizedBox(
                    width: mediaData.size.width * 0.01,
                  ),
                  DashItem(
                    mediaData,
                    'Total\nItems',
                    items,
                    'item',
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  waitingList() async {
    if (this.mounted)
      setState(() {
        chartSpinner = true;
        shops = 0;
        items = 0;
        users = 0;
      });
    await getNumbers();
    await getData();
    if (this.mounted)
      setState(() {
        chartSpinner = false;
      });

    refreshCon.refreshCompleted();
  }

  getNumbers() async {
    QuerySnapshot qSnap1 = await _firestore
        .collection('items')
        .where('status', isEqualTo: 'enable')
        .get();
    int mockItems = qSnap1.docs.length;
    QuerySnapshot qSnap2 = await _firestore
        .collection('shops')
        .where('status', isEqualTo: 'enable')
        .get();
    int mockShops = qSnap2.docs.length;
    QuerySnapshot qSnap3 = await _firestore
        .collection('users')
        .where('status', isEqualTo: 'enable')
        .where('role', isEqualTo: 'rep')
        .get();
    int mockUsers = qSnap3.docs.length;
    if (this.mounted)
      setState(() {
        items = mockItems;
        shops = mockShops;
        users = mockUsers;
      });
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
            chartData.add(FlSpot(0, jan / 40000));
            chartData.add(FlSpot(1, feb / 40000));
            chartData.add(FlSpot(2, mar / 40000));
            chartData.add(FlSpot(3, apr / 40000));
            chartData.add(FlSpot(4, may / 40000));
            chartData.add(FlSpot(5, jun / 40000));
            chartData.add(FlSpot(6, jul / 40000));
            chartData.add(FlSpot(7, aug / 40000));
            chartData.add(FlSpot(8, sep / 40000));
            chartData.add(FlSpot(9, oct / 40000));
            chartData.add(FlSpot(10, nov / 40000));
            chartData.add(FlSpot(11, dec / 40000));
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
              total += doc['price'] * doc['quantity'];
              if (doc['order_id'] == a.reference.id) {
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
            chartData.add(FlSpot(0, w1 / 20000));
            chartData.add(FlSpot(1, w2 / 20000));
            chartData.add(FlSpot(2, w3 / 20000));
            chartData.add(FlSpot(3, w4 / 20000));
            chartData.add(FlSpot(4, w5 / 20000));
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
            chartData.add(FlSpot(0, d1 / 10000));
            chartData.add(FlSpot(1, d2 / 10000));
            chartData.add(FlSpot(2, d3 / 10000));
            chartData.add(FlSpot(3, d4 / 10000));
            chartData.add(FlSpot(4, d5 / 10000));
            chartData.add(FlSpot(5, d6 / 10000));
            chartData.add(FlSpot(6, d7 / 10000));
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
}

class DashItem extends StatefulWidget {
  const DashItem(this.mediaData, this.text, this.subText, this.category);
  final MediaQueryData mediaData;
  final text;
  final subText;
  final category;
  @override
  _DashItemState createState() => _DashItemState();
}

class _DashItemState extends State<DashItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.category == 'rep') {
          pushNewScreenWithRouteSettings(
            context,
            settings: RouteSettings(
              name: RepAnalysis.id,
            ),
            screen: RepAnalysis(0),
            withNavBar: true,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        }
        if (widget.category == 'shop') {
          pushNewScreenWithRouteSettings(
            context,
            settings: RouteSettings(
              name: ShopAnalysis.id,
            ),
            screen: ShopAnalysis(0),
            withNavBar: true,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        }
        if (widget.category == 'item') {
          pushNewScreenWithRouteSettings(
            context,
            settings: RouteSettings(
              name: ItemOverview.id,
            ),
            screen: ItemOverview(),
            withNavBar: true,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        }
      },
      child: Container(
        height: widget.mediaData.size.height * 0.17,
        width: widget.mediaData.size.width * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadiusDirectional.circular(25.0),
          color: Color(0xff010429),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: widget.mediaData.size.height * 0.005),
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: krepReg.copyWith(
                      color: Colors.white,
                      fontSize: widget.mediaData.size.height * 0.028,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: widget.mediaData.size.height * 0.005),
                  child: widget.subText != 0
                      ? Text(
                          widget.subText.toString(),
                          textAlign: TextAlign.center,
                          style: krepReg.copyWith(
                            color: Color(0xff02d39a),
                            fontSize: widget.mediaData.size.height * 0.05,
                          ),
                        )
                      : Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.lightBlueAccent,
                          ),
                        ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View Info',
                  textAlign: TextAlign.center,
                  style: krepReg.copyWith(
                    color: Colors.white,
                    fontSize: widget.mediaData.size.height * 0.02,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
