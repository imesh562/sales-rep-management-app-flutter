import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dk_brothers/components/indicators_widget.dart';
import 'package:dk_brothers/components/components.dart';
import 'package:dk_brothers/components/data.dart';
import 'package:dk_brothers/components/decorations.dart';
import 'package:dk_brothers/components/get_sections.dart';
import 'package:dk_brothers/components/item_review_pie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_alt/modal_progress_hud_alt.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:sortedmap/sortedmap.dart';

import 'item_profile.dart';

User? loggedInUser1;

class ItemOverview extends StatefulWidget {
  static String id = 'rep_overview';
  @override
  _ItemOverviewState createState() => _ItemOverviewState();
}

class _ItemOverviewState extends State<ItemOverview> {
  late StreamSubscription subscription;
  bool showSpinner = false;
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
  String searchText = "";
  int orderBy = 1;
  var orderByText = 'Name';

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
    RepOverviewData obj1 = RepOverviewData();
    await obj1.getDataItemPie();
    await obj1.getItemNames();
    if (this.mounted)
      setState(() {
        alldata = obj1.allItems();
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
        extendBodyBehindAppBar: false,
        appBar: appBarComponenet(mediaData, 'Items Overview'),
        body: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: mediaData.size.height * 0.03,
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
                        'Best Selling Items',
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
                            bottom: mediaData.size.height * 0.015,
                          ),
                          child: IndicatorsWidget(alldata, mediaData, true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  bottom: mediaData.size.height * 0.03,
                ),
                child: Text(
                  'Item List',
                  style: krepReg.copyWith(
                    color: Colors.black,
                    fontSize: mediaData.size.height * 0.032,
                  ),
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.only(left: 14.0),
                          width: mediaData.size.width * 0.7,
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Search',
                              labelStyle: loginCredentials,
                              prefixIcon: Icon(
                                FontAwesomeIcons.search,
                                color: Color(0xFF9A57B4),
                              ),
                              errorStyle: TextStyle(fontSize: 12, height: 0.3),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFF9A57B4)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(32.0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFF9A57B4)),
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
                      ),
                      Container(
                        padding: EdgeInsets.all(20.0),
                        child: DropdownButton(
                            value: orderBy,
                            autofocus: true,
                            items: [
                              DropdownMenuItem(
                                child: Text("Name"),
                                value: 1,
                              ),
                              DropdownMenuItem(
                                child: Text("Date"),
                                value: 2,
                              ),
                              DropdownMenuItem(
                                child: Text("Disabled"),
                                value: 3,
                              ),
                            ],
                            onChanged: (value) {
                              if (value == 1) {
                                if (this.mounted)
                                  setState(() {
                                    orderBy = 1;
                                    orderByText = 'Name';
                                  });
                              } else if (value == 2) {
                                if (this.mounted)
                                  setState(() {
                                    orderBy = 2;
                                    orderByText = 'Date';
                                  });
                              } else {
                                if (this.mounted)
                                  setState(() {
                                    orderBy = 3;
                                    orderByText = 'Removed';
                                  });
                              }
                            }),
                      ),
                    ],
                  ),
                  RepsStream(controller, searchText, orderByText),
                  SizedBox(
                    height: mediaData.size.height * 0.015,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class RepsStream extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;
  var controller;
  String searchText;
  String orderByText;
  RepsStream(this.controller, this.searchText, this.orderByText);
  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    return StreamBuilder<QuerySnapshot>(
      // ignore: unnecessary_null_comparison
      stream: (searchText != "")
          ? searchData(searchText, orderByText)
          : orderByText == 'Name'
              ? _firestore
                  .collection('items')
                  .orderBy('name', descending: true)
                  .snapshots()
              : orderByText == 'Date'
                  ? _firestore
                      .collection('items')
                      .orderBy('timestamp', descending: false)
                      .snapshots()
                  : _firestore
                      .collection('items')
                      .orderBy('status', descending: true)
                      .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final items = snapshot.data!.docs.reversed;
        List<Widget> repList = [];
        for (var item in items) {
          final itemName = item['name'];
          final itemEnglishName = item['english_name'];
          final itemPrice = item['price'];
          final itemStatus = item['status'];
          final itemID = item.reference.id;

          repList.add(repListBuilder(itemName, itemPrice.toString(), mediaData,
              context, itemStatus, itemID, itemEnglishName.toString()));
        }
        return ListView.builder(
          controller: controller,
          itemCount: repList.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Align(
              heightFactor: 0.8,
              alignment: Alignment.topCenter,
              child: repList[index],
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> searchData(String string, String orderByText) async* {
    var _search = _firestore
        .collection('items')
        .where('name', isGreaterThanOrEqualTo: string)
        .where('name', isLessThan: string + 'z')
        .orderBy('name', descending: true)
        .snapshots();
    yield* _search;
  }

  Widget repListBuilder(String name, String price, MediaQueryData mediaData,
      BuildContext context, String status, String itemID, String englishName) {
    return GestureDetector(
      onTap: () {
        pushNewScreenWithRouteSettings(
          context,
          settings: RouteSettings(
            name: ItemProfile.id,
          ),
          screen: ItemProfile(
            name,
            price,
            status,
            itemID,
          ),
          withNavBar: true,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: 10.0),
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
              child: Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: mediaData.size.height * 0.028,
                      fontFamily: 'Exo2',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  status == 'enable'
                      ? Icon(
                          Icons.play_circle,
                          color: Color(0xFF9A57B4),
                        )
                      : Icon(
                          Icons.pause_circle,
                          color: Colors.red,
                        ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 14.0),
              child: Text(
                'Rs.$price',
                style: TextStyle(
                  fontSize: mediaData.size.height * 0.025,
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
