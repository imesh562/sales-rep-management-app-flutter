import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/shop_overview_pie.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/data.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/components/get_sections.dart';
import 'package:dk_brothers/components/indicators_widget.dart';
import 'package:dk_brothers/screens/today_orders.dart';
import 'package:dk_brothers/screens/today_payments.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:sortedmap/sortedmap.dart';

User? loggedInUser1;

class ShopOverview extends StatefulWidget {
  static String id = 'shop_overview';
  @override
  _ShopOverviewState createState() => _ShopOverviewState();
}

class _ShopOverviewState extends State<ShopOverview> {
  late StreamSubscription subscription;
  bool showSpinner = false;
  final _firestore = FirebaseFirestore.instance;
  int touchedIndex = -1;
  List<Data> alldata = [];
  ScrollController controller = ScrollController();
  DateTime? startDate, endDate;
  bool endBool = true;
  bool startBool = true;
  Map<String, double> targetResults = SortedMap(Ordering.byValue());
  Map<String, String> shopsMap = {};
  double target = 0;
  bool listSpinner = false;
  TextEditingController targetController = TextEditingController();

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
      });
    PieData obj1 = PieData();
    await obj1.getDataShopPie();
    await obj1.getShopNames();
    await targetCal();
    if (this.mounted)
      setState(() {
        alldata = obj1.allShops();
        showSpinner = false;
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
        body: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: mediaData.size.height * 0.04,
                  horizontal: mediaData.size.height * 0.03,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(mediaData.size.width * 0.1),
                  color: Color(0xff37434d),
                  boxShadow: [
                    BoxShadow(color: Color(0xff02d39a), spreadRadius: 3),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: mediaData.size.height * 0.01,
                          bottom: mediaData.size.height * 0.04),
                      child: Text(
                        'Best Buyers',
                        style: krepReg.copyWith(
                          color: Colors.white,
                          fontSize: mediaData.size.height * 0.032,
                        ),
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
                                                .touchedSectionIndex
                                            is FlLongPressEnd ||
                                        pieTouchResponse.touchedSection!
                                                .touchedSectionIndex
                                            is FlPanEndEvent) {
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
                          sections:
                              getSections(touchedIndex, alldata, mediaData),
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
                          child: IndicatorsWidget(alldata, mediaData, true),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: mediaData.size.height * 0.025,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xff37434d),
                      boxShadow: [
                        BoxShadow(color: Color(0xff02d39a), spreadRadius: 3),
                      ],
                    ),
                    margin: EdgeInsets.symmetric(
                        horizontal: mediaData.size.width * 0.04),
                    child: ListTile(
                      leading: Icon(
                        Icons.history,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Today Sales',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        DateTime now = new DateTime.now();
                        DateTime finalDate =
                            new DateTime(now.year, now.month, now.day);
                        pushNewScreenWithRouteSettings(
                          context,
                          settings: RouteSettings(
                            name: TodayOrders.id,
                          ),
                          screen: TodayOrders(finalDate),
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
                      color: Color(0xff37434d),
                      boxShadow: [
                        BoxShadow(color: Color(0xff02d39a), spreadRadius: 3),
                      ],
                    ),
                    margin: EdgeInsets.symmetric(
                        horizontal: mediaData.size.width * 0.04),
                    child: ListTile(
                      leading: Icon(
                        Icons.payment,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Today Payments',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        DateTime now = new DateTime.now();
                        DateTime finalDate =
                            new DateTime(now.year, now.month, now.day);
                        pushNewScreenWithRouteSettings(
                          context,
                          settings: RouteSettings(
                            name: TodayPayments.id,
                          ),
                          screen: TodayPayments(finalDate),
                          withNavBar: true,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: mediaData.size.height * 0.03,
              ),
              Container(
                margin: EdgeInsets.only(
                  top: mediaData.size.height * 0.02,
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        bottom: mediaData.size.height * 0.03,
                      ),
                      child: Text(
                        'Sales Calculator',
                        style: krepReg.copyWith(
                          color: Colors.black,
                          fontSize: mediaData.size.height * 0.032,
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.only(left: mediaData.size.width * 0.04),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              ElevatedButton(
                                style:
                                    datesButtons(Color(0xff37434d), mediaData),
                                onPressed: () {
                                  _startDate(context);
                                },
                                child: Text(
                                  'Start date',
                                  style: TextStyle(
                                    fontFamily: 'Exo2',
                                    fontSize: mediaData.size.height * 0.023,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              startDate != null
                                  ? startBool
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              top: mediaData.size.height *
                                                  0.015),
                                          child: Text(
                                            startDate
                                                .toString()
                                                .substring(0, 10),
                                            style: TextStyle(
                                              fontFamily: 'Exo2',
                                              fontSize:
                                                  mediaData.size.height * 0.02,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          margin: EdgeInsets.only(
                                              top: mediaData.size.height *
                                                  0.015),
                                          child: Text(
                                            startDate
                                                .toString()
                                                .substring(0, 10),
                                            style: TextStyle(
                                                fontFamily: 'Exo2',
                                                fontSize:
                                                    mediaData.size.height *
                                                        0.02,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red),
                                          ),
                                        )
                                  : Container(
                                      margin: EdgeInsets.only(
                                          top: mediaData.size.height * 0.015),
                                      child: Text(''),
                                    ),
                            ],
                          ),
                          SizedBox(
                            width: mediaData.size.width * 0.025,
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                style:
                                    datesButtons(Color(0xff37434d), mediaData),
                                onPressed: () {
                                  _endDate(context);
                                },
                                child: Text(
                                  'End date',
                                  style: TextStyle(
                                    fontFamily: 'Exo2',
                                    fontSize: mediaData.size.height * 0.023,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              endDate != null
                                  ? endBool
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              top: mediaData.size.height *
                                                  0.015),
                                          child: Text(
                                            endDate.toString().substring(0, 10),
                                            style: TextStyle(
                                                fontFamily: 'Exo2',
                                                fontSize:
                                                    mediaData.size.height *
                                                        0.02,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      : Container(
                                          margin: EdgeInsets.only(
                                              top: mediaData.size.height *
                                                  0.015),
                                          child: Text(
                                            endDate.toString().substring(0, 10),
                                            style: TextStyle(
                                                fontFamily: 'Exo2',
                                                fontSize:
                                                    mediaData.size.height *
                                                        0.02,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red),
                                          ),
                                        )
                                  : Container(
                                      margin: EdgeInsets.only(
                                          top: mediaData.size.height * 0.015),
                                      child: Text(''),
                                    ),
                            ],
                          ),
                          SizedBox(
                            width: mediaData.size.width * 0.025,
                          ),
                          Container(
                            height: mediaData.size.height * 0.1,
                            width: mediaData.size.width * 0.36,
                            child: Form(
                              child: TextFormField(
                                controller: targetController,
                                style: TextStyle(
                                    fontSize: mediaData.size.height * 0.03),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: kTargetField,
                                validator: (value) {
                                  final numericRegex = RegExp(
                                      r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
                                  final numericRegex1 =
                                      RegExp(r'^[0-9]+[0-9]*$');
                                  if (value!.isEmpty) {
                                    return "Enter value";
                                  } else if (!numericRegex.hasMatch(value) ||
                                      !numericRegex1.hasMatch(value)) {
                                    return 'Not valid';
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    if (this.mounted)
                                      setState(() {
                                        target = double.parse(value);
                                      });
                                  } else {
                                    if (this.mounted)
                                      setState(() {
                                        target = 0;
                                      });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    listSpinner
                        ? Center(
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: mediaData.size.height * 0.05),
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.lightBlueAccent,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                                vertical: mediaData.size.height * 0.01),
                            itemCount: targetResults.length,
                            itemBuilder: (context, index) {
                              var keys = targetResults.keys.toList();
                              var val = targetResults[keys[index]];
                              if (val! >= target) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadiusDirectional.circular(25.0),
                                    boxShadow: boxShadowsReps(),
                                    color: Color(0xff37434d),
                                  ),
                                  margin: EdgeInsets.symmetric(
                                    horizontal: mediaData.size.height * 0.02,
                                    vertical: mediaData.size.height * 0.005,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      (shopsMap[keys[index]]).toString(),
                                      style: TextStyle(
                                          fontSize:
                                              mediaData.size.height * 0.023,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    trailing: Text(
                                      'Rs. ' + val.toStringAsFixed(2),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              mediaData.size.height * 0.019,
                                          color: Colors.white),
                                    ),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                  ],
                ),
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
                                endBool = true;
                                endDate = null;
                                startBool = true;
                                startDate = null;
                                targetController.clear();
                              });
                            targetCal();
                          },
                          icon: Icon(Icons.refresh),
                          label: Text(
                            'Reset',
                            style: TextStyle(
                                fontSize: mediaData.size.height * 0.026),
                          ),
                          style: TextButton.styleFrom(
                            side:
                                BorderSide(color: Color(0xff02d39a), width: 3),
                            primary: Colors.white,
                            backgroundColor: Color(0xff37434d),
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

  _startDate(BuildContext context) async {
    DateTime now = new DateTime.now();
    DateTime finalDate = new DateTime(now.year, now.month, now.day);
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: finalDate,
      firstDate: DateTime(2021 - 01 - 01),
      currentDate: finalDate,
      lastDate: finalDate,
    );
    if (selected != null) {
      if (endDate != null) {
        if (selected.isBefore(endDate!) ||
            selected.isAtSameMomentAs(endDate!)) {
          if (this.mounted)
            setState(() {
              startDate = selected;
              startBool = true;
              endBool = true;
            });
          await targetCal();
        } else {
          if (this.mounted)
            setState(() {
              startBool = false;
              startDate = selected;
            });
        }
      } else {
        if (this.mounted)
          setState(() {
            startDate = selected;
          });
      }
    }
  }

  _endDate(BuildContext context) async {
    DateTime now = new DateTime.now();
    DateTime finalDate = new DateTime(now.year, now.month, now.day);
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: finalDate,
      firstDate: DateTime(2021 - 01 - 01),
      currentDate: finalDate,
      lastDate: finalDate,
    );
    if (selected != null) {
      if (startDate != null) {
        if (selected.isAfter(startDate!) ||
            selected.isAtSameMomentAs(startDate!)) {
          if (this.mounted)
            setState(() {
              endDate = selected;
              endBool = true;
              startBool = true;
            });
          await targetCal();
        } else {
          if (this.mounted)
            setState(() {
              endDate = selected;
              endBool = false;
            });
        }
      } else {
        if (this.mounted)
          setState(() {
            endDate = selected;
          });
      }
    }
  }

  targetCal() async {
    if (this.mounted)
      setState(() {
        listSpinner = true;
      });
    targetResults.clear();
    QuerySnapshot querySnapshot = await _firestore
        .collection("orders")
        .where('status', isEqualTo: 'enable')
        .get();
    if (querySnapshot.docs.length > 0) {
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        var a = querySnapshot.docs[i];
        var shopID = a['shop_id'];
        var shopName = a['shop_name'];
        var date = DateTime.parse(a['date']);
        var total = 0.0;
        var discountedTotal = 0.0;
        if (startDate == null && endDate == null) {
          QuerySnapshot totalSnap = await _firestore
              .collection("order_items")
              .where('order_id', isEqualTo: a.reference.id)
              .get();
          for (int i = 0; i < totalSnap.docs.length; i++) {
            var doc = totalSnap.docs[i];
            total += doc['price'] * doc['quantity'];
            discountedTotal += (doc['price'] * doc['quantity']) -
                ((doc['discount'] / 100) * (doc['price'] * doc['quantity']));
          }
          if (targetResults.containsKey(shopID)) {
            if (discountedTotal < total && discountedTotal > 0) {
              targetResults.update(
                  shopID, (dynamic val) => val + discountedTotal);
            } else {
              targetResults.update(shopID, (dynamic val) => val + total);
            }
          } else {
            if (discountedTotal < total && discountedTotal > 0) {
              targetResults[shopID] = discountedTotal;
              shopsMap[shopID] = shopName;
            } else {
              targetResults[shopID] = total;
              shopsMap[shopID] = shopName;
            }
          }
        }
        if (startDate != null && endDate != null && startBool && endBool) {
          if ((date.isBefore(endDate!) || date.isAtSameMomentAs(endDate!)) &&
              (date.isAfter(startDate!) || date.isAtSameMomentAs(startDate!))) {
            QuerySnapshot totalSnap = await _firestore
                .collection("order_items")
                .where('order_id', isEqualTo: a.reference.id)
                .get();
            for (int i = 0; i < totalSnap.docs.length; i++) {
              var doc = totalSnap.docs[i];
              total += doc['price'] * doc['quantity'];
              discountedTotal += (doc['price'] * doc['quantity']) -
                  ((doc['discount'] / 100) * (doc['price'] * doc['quantity']));
            }
            if (targetResults.containsKey(shopID)) {
              if (discountedTotal < total && discountedTotal > 0) {
                targetResults.update(
                    shopID, (dynamic val) => val + discountedTotal);
              } else {
                targetResults.update(shopID, (dynamic val) => val + total);
              }
            } else {
              if (discountedTotal < total && discountedTotal > 0) {
                targetResults[shopID] = discountedTotal;
                shopsMap[shopID] = shopName;
              } else {
                targetResults[shopID] = total;
                shopsMap[shopID] = shopName;
              }
            }
          }
        }
      }
    }
    if (this.mounted)
      setState(() {
        listSpinner = false;
      });
  }
}
